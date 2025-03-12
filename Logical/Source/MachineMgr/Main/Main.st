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
		
	// Translate Errors
	GetErrorType;
	GetTrakMasterWarningsAndErrors;
	// Catch SuperTrak Errors
	IF gSuperTrak.System.Status.Error OR gSuperTrak.System.Info.FaultPresent 
		OR gSuperTrak.Sections.Status.Error OR gSuperTrak.Sections.Status.SectionError THEN
		
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
	gSuperTrak.Sections.Cmd.Reset := Interface.Cmd.ErrorReset;
    
    // Disable handling
    IF (NOT Interface.Cmd.Power OR NOT gSuperTrak.System.Status.Active) 
        AND (MainState > MAIN_STATE_DISABLED) AND (MainState < MAIN_STATE_DISABLING) THEN
        MainState := MAIN_STATE_DISABLING;
    END_IF;
    
    // Main state machine
    CASE MainState OF
		MAIN_STATE_OFF:
            // Wait for System and Sections to be Active
            IF gSuperTrak.System.Status.Active AND gSuperTrak.Sections.Status.Active THEN
                MainState := MAIN_STATE_DISABLED;
            END_IF;
            
        MAIN_STATE_DISABLED:
            // Reset commands and timers
            ResetTargetRelease;
            ResetShuttleRelease;
            ResetProcessTimer;
            
            IF r_trig_Power.Q AND gSuperTrak.System.Status.Ready THEN
                MainState := MAIN_STATE_POWER_SECTIONS;
            END_IF; 
            
        MAIN_STATE_POWER_SECTIONS:      
            gSuperTrak.System.Cmd.PowerAllSections := TRUE;
            
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
            IF Interface.Cmd.Run THEN
                MainState := MAIN_STATE_RUN;
            END_IF;
            
        MAIN_STATE_RUN:
            IF NOT Interface.Cmd.Run THEN
                MainState := MAIN_STATE_READY;
            END_IF;
            
            (*******************************************************
             *******************************************************
                        Target control code goes here 
            *******************************************************
            *******************************************************)
            
            FOR LoopTarget := 1 TO ST_TARGET_MAX DO
                ProcessTimer[LoopTarget].IN := gSuperTrak.Target[LoopTarget].Status.ShuttlePresent;
                ProcessTimer[LoopTarget].PT := SimulatedProcessTimes[LoopTarget];
                ProcessTimer[LoopTarget]();
            END_FOR;
            
            // Target 1: Load
            IF ProcessTimer[ST_TARGET_LOAD].Q THEN
                IF gSuperTrak.Target[ST_TARGET_LOAD].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
                    gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.Velocity := Interface.Par.Velocity;
                    gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.Acceleration := Interface.Par.Acceleration;
                    gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
                    gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.DestinationTarget := ST_TARGET_QUEUE;
                    gSuperTrak.Target[ST_TARGET_LOAD].Cmd.Release.ReleaseToTarget := TRUE;
                END_IF
            END_IF   
            
            // Target 2: Queue
            IF ProcessTimer[ST_TARGET_QUEUE].Q AND gSuperTrak.Target[ST_TARGET_PROCESS].Status.ShuttleCount = 0 THEN
                IF gSuperTrak.Target[ST_TARGET_QUEUE].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
                    gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.Velocity := Interface.Par.Velocity;
                    gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.Acceleration := Interface.Par.Acceleration;
                    gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
                    gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.DestinationTarget := ST_TARGET_PROCESS;
                    gSuperTrak.Target[ST_TARGET_QUEUE].Cmd.Release.ReleaseToTarget := TRUE;
                END_IF
            END_IF 
            
            // Target 3: Process
            IF ProcessTimer[ST_TARGET_PROCESS].Q THEN
                IF gSuperTrak.Target[ST_TARGET_PROCESS].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
                    gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.Velocity := Interface.Par.Velocity;
                    gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.Acceleration := Interface.Par.Acceleration;
                    gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
                    gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.DestinationTarget := ST_TARGET_UNLOAD;
                    gSuperTrak.Target[ST_TARGET_PROCESS].Cmd.Release.ReleaseToTarget := TRUE;
                END_IF
            END_IF   
            
            // Target 4: Unload
            IF ProcessTimer[ST_TARGET_UNLOAD].Q THEN
                IF gSuperTrak.Target[ST_TARGET_UNLOAD].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
                    gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.Velocity := Interface.Par.Velocity;
                    gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.Acceleration := Interface.Par.Acceleration;
                    gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
                    gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.DestinationTarget := ST_TARGET_LOAD;
                    gSuperTrak.Target[ST_TARGET_UNLOAD].Cmd.Release.ReleaseToTarget := TRUE;
                END_IF
            END_IF   
            
            // Reset commands
            FOR LoopTarget := 1 TO ST_TARGET_MAX DO
                IF gSuperTrak.Target[LoopTarget].Status.ShuttleReleased THEN
                    brsmemset(ADR(gSuperTrak.Target[LoopTarget].Cmd), 0, SIZEOF(gSuperTrak.Target[LoopTarget].Cmd));
                END_IF
            END_FOR
            
        MAIN_STATE_DISABLING:
            gSuperTrak.System.Cmd.PowerAllSections := FALSE;
            
            IF gSuperTrak.System.Info.SectionsDisabled THEN
                MainState := MAIN_STATE_DISABLED;
            END_IF;
        
        MAIN_STATE_ERROR:
			gSuperTrak.System.Cmd.PowerAllSections := FALSE;
			
            // Reset commands and timers
            ResetTargetRelease;
            ResetShuttleRelease;
            ResetProcessTimer;
			
			IF NOT gSuperTrak.System.Status.Error AND NOT gSuperTrak.Sections.Status.SectionError AND Interface.Cmd.ErrorReset THEN
				MainState := MAIN_STATE_OFF;
			END_IF;
		
	END_CASE;
    
	// Set statuses
	Interface.Status.PowerOn := ((Interface.Cmd.Power) AND (MainState > MAIN_STATE_DISABLED));
	Interface.Status.Ready := (MainState = MAIN_STATE_READY);
    Interface.Status.Error := (MainState = MAIN_STATE_ERROR);
    
    // Copy outputs
    gMachine.Status := Interface.Status;
	 
END_PROGRAM
