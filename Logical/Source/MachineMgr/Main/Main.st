(***************************************************************************************
 * Main task
 *
 * This task (program) provides a state machine for controlling any and all hardware 
 * connected to the B&R PC. SuperTrak (Target) release code is demonstrated in the
 * MAIN_STATE_RUN (Running) state of this state machine. 
 *
 * Other tasks can interface with this one via the global variable "gMachine".
 *
 * File: Main.st
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *  Bryan Olson, B&R Industrial Automation
 *
***************************************************************************************)

PROGRAM _INIT
	
    // Set simulated station timer values
    SimulatedProcessTimes[ST_TARGET_LOAD] := T#1s;
    SimulatedProcessTimes[ST_TARGET_QUEUE] := T#100ms;
    SimulatedProcessTimes[ST_TARGET_PROCESS] := T#500ms;
    SimulatedProcessTimes[ST_TARGET_UNLOAD] := T#1s;

END_PROGRAM

PROGRAM _CYCLIC	
    
    // Copy inputs
    Interface.Cmd := gMachine.Cmd;
    Interface.Par := gMachine.Par;
    
    // Check for command edges
    r_trig_Power(CLK := Interface.Cmd.Power);
    r_trig_Run(CLK := Interface.Cmd.Run);
		
    // Translate Errors
    GetErrorType;
    GetTrakMasterWarningsAndErrors;
    // Catch SuperTrak Errors
    IF gSuperTrak.System.Status.Error OR gSuperTrak.System.Info.FaultPresent 
        OR gSuperTrak.Sections.Status.Error OR (gSuperTrak.Sections.Status.SectionError <> 0)
        OR TargetErrorPresent OR ShuttleErrorPresent THEN
		
        // Set Diag Index once
        IF MainState <> MAIN_STATE_ERROR THEN
            IF gSuperTrak.System.Info.FaultPresent THEN
                Interface.Status.SuperTrakDiag.SuperTrakDiagIndex:= 0;
            ELSE
                FOR i:= 1 TO SIZEOF(gSuperTrak.Sections.Info)/SIZEOF(gSuperTrak.Sections.Info[1]) DO
                    IF gSuperTrak.Sections.Info[i].FaultPresent THEN
                        Interface.Status.SuperTrakDiag.SuperTrakDiagIndex:= i;
                        EXIT;
                    END_IF
                END_FOR
            END_IF
        END_IF
		
        // Then go to Error State
        MainState := MAIN_STATE_ERROR;
		
    END_IF;
    // Reset Errors
    gSuperTrak.System.Cmd.Reset := Interface.Cmd.ErrorReset;
    
    // Disable handling
    // Go to the Disabled state whenever gSuperTrak.System.Status.Active drops, but only respond to
    // Interface.Command.Run if ConfigUseExternalControl is false
    IF ((NOT ConfigUseExternalControl AND NOT Interface.Cmd.Power) OR NOT gSuperTrak.System.Status.Active) 
        AND (MainState > MAIN_STATE_DISABLED) AND (MainState < MAIN_STATE_DISABLING) THEN
        MainState := MAIN_STATE_DISABLING;
    END_IF;
    
    // Main State Machine
    // State machine is passive if main logic is external
    // States will reflect overall machine status, but will not
    // control the SuperTrak
    CASE MainState OF
        MAIN_STATE_OFF:
            IF NOT ConfigUseExternalControl THEN
                gSuperTrak.System.Cmd.PowerAllSections := FALSE;
            END_IF;
            
            // Wait for System and Sections to be Active
            IF gSuperTrak.System.Status.Active AND gSuperTrak.Sections.Status.Active THEN
                MainState := MAIN_STATE_DISABLED;
            END_IF;
            
        MAIN_STATE_DISABLED:
            // Reset commands and timers
            IF NOT ConfigUseExternalControl THEN
                ResetTargetRelease;
                ResetShuttleRelease;
                ResetProcessTimer;
            END_IF; 
            
            IF r_trig_Power.Q AND gSuperTrak.System.Status.Ready AND NOT ConfigUseExternalControl THEN
                MainState := MAIN_STATE_POWER_SECTIONS;
            ELSIF ConfigUseExternalControl AND gSuperTrak.System.Info.SectionsEnabled THEN
                MainState := MAIN_STATE_READY; // Power and Recovery steps should be handled externally
            END_IF; 
            
        MAIN_STATE_POWER_SECTIONS:      
            IF NOT ConfigUseExternalControl THEN
                gSuperTrak.System.Cmd.PowerAllSections := TRUE;
            END_IF;
                
            IF gSuperTrak.System.Info.SectionsEnabled THEN
                MainState := MAIN_STATE_RECOVER;
            END_IF;
            
        MAIN_STATE_RECOVER:
            GetTargetsReleased; 
            GetShuttlesReleased;
            IF TargetsReleased AND ShuttlesReleased AND gSuperTrak.System.Status.PowerOn THEN // Recovered and at standstill
                // Add conditions to satisfy process recovery
                MainState := MAIN_STATE_READY;
            END_IF
            
        MAIN_STATE_READY:
            IF r_trig_Run.Q AND NOT ConfigUseExternalControl THEN
                MainState := MAIN_STATE_RUN;
            END_IF;
            
        MAIN_STATE_RUN:
            IF ConfigUseExternalControl OR NOT Interface.Cmd.Run THEN
                MainState := MAIN_STATE_READY;
            ELSE
                MainLogic; // Target release code goes in this Action
            END_IF
            
        MAIN_STATE_DISABLING:
            IF NOT ConfigUseExternalControl THEN
                gSuperTrak.System.Cmd.PowerAllSections := FALSE;
            END_IF;
            
            IF gSuperTrak.System.Info.SectionsDisabled THEN
                MainState := MAIN_STATE_DISABLED;
            END_IF;
        
        MAIN_STATE_ERROR:
            IF NOT ConfigUseExternalControl THEN
                gSuperTrak.System.Cmd.PowerAllSections := FALSE;
                
                // Reset commands and timers
                ResetTargetRelease;
                ResetShuttleRelease;
                ResetProcessTimer;
            END_IF;
            
            IF Interface.Cmd.ErrorReset
                AND NOT gSuperTrak.System.Status.Error AND (gSuperTrak.Sections.Status.SectionError = 0)
                AND NOT TargetErrorPresent AND NOT ShuttleErrorPresent THEN
                MainState := MAIN_STATE_OFF;
            END_IF;
    END_CASE;
    
    // Call function blocks
    fb_ArTextSysGetText.Namespace := ADR('User/SuperTrakErrors');
    fb_ArTextSysGetText.LanguageCode := 'en';
    fb_ArTextSysGetText.TextBuffer := ADR(Interface.Status.ErrorText);
    fb_ArTextSysGetText.TextBufferSize := SIZEOF(Interface.Status.ErrorText);
    fb_ArTextSysGetText();
    IF fb_ArTextSysGetText.Done THEN
        fb_ArTextSysGetText.Execute := FALSE; 
    END_IF;

    // Set statuses
    Interface.Status.PowerOn := ((Interface.Cmd.Power) AND (MainState > MAIN_STATE_DISABLED));
    Interface.Status.Ready := (MainState = MAIN_STATE_READY);
    Interface.Status.Error := (MainState = MAIN_STATE_ERROR);
    
    // Copy outputs
    gMachine.Status := Interface.Status;
	 
END_PROGRAM
