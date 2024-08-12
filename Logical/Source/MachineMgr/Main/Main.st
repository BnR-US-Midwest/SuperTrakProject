
PROGRAM _INIT
	(* Insert code here *)

END_PROGRAM

PROGRAM _CYCLIC
	
    // Copy commands
    Interface.Cmd := gMachine.Cmd;
    
    // Edge triggers
    EnableTrigger(CLK := Interface.Cmd.Enable);
    RunTrigger(CLK := Interface.Cmd.Run);
    ResetTrigger(CLK := Interface.Cmd.ErrorReset);
    
    // Error Handling
    IF gSuperTrak.System.Status.Error OR gSuperTrak.Sections.Status.Error THEN
        MainState := MAIN_STATE_ERROR;
    END_IF;
    
    // Disable handling
    IF (NOT Interface.Cmd.Enable) AND (MainState > MAIN_STATE_DISABLED) AND (MainState < MAIN_STATE_DISABLING) THEN
        MainState := MAIN_STATE_DISABLING;
    END_IF;
    
    // Main state machine
    CASE MainState OF
        MAIN_STATE_OFF:
            gSuperTrak.System.Cmd.Enable := TRUE;
            gSuperTrak.Sections.Cmd.Enable := gSuperTrak.System.Status.Active;

            IF gSuperTrak.System.Status.Active AND gSuperTrak.Sections.Status.Active THEN
                MainState := MAIN_STATE_DISABLED;
            END_IF;
            
        MAIN_STATE_DISABLED:
            IF EnableTrigger.Q AND gSuperTrak.System.Status.Ready THEN
                MainState := MAIN_STATE_ENABLE_SECTIONS;
            END_IF; 
            
        MAIN_STATE_ENABLE_SECTIONS:      
           (* AllSectionsEnabled := TRUE; // Set True now, set False later if any section isn't ready
            FOR LoopSection := 1 TO ST_SECTION_MAX DO
                gSuperTrak.Sections.Cmd.EnableSection[LoopSection] := TRUE; 
                IF NOT gSuperTrak.Sections.Status.SectionEnabled[LoopSection] THEN
                    AllSectionsEnabled := FALSE;
                END_IF;
            END_FOR;
            
            IF AllSectionsEnabled THEN
                MainState := MAIN_STATE_RECOVER;
            END_IF;*)
            
            gSuperTrak.System.Cmd.Run := TRUE;
            
            IF gSuperTrak.System.Info.SectionsEnabled THEN
                MainState := MAIN_STATE_RECOVER;
            END_IF;
            
        MAIN_STATE_RECOVER:
            GetTargetsReleased; 
            GetShuttlesReleased;
            IF TargetsReleased AND ShuttlesReleased AND gSuperTrak.System.Status.Running THEN // Recovered and at standstill
                // Add conditions to satisfy process recovery
                MainState := MAIN_STATE_READY;
            END_IF
            
        MAIN_STATE_READY:
            IF RunTrigger.Q THEN
                MainState := MAIN_STATE_RUN;
            END_IF;
            
        MAIN_STATE_RUN:
            IF NOT Interface.Cmd.Run THEN
                MainState := MAIN_STATE_STOP;
            END_IF;
            
            // Target control code goes here //
            
        MAIN_STATE_STOP:
            IF NOT gSuperTrak.System.Status.Stopped THEN
                MainState := MAIN_STATE_READY;
            END_IF;
            
        MAIN_STATE_DISABLING:
            gSuperTrak.System.Cmd.Run := FALSE;
            gSuperTrak.System.Cmd.Stop := TRUE;
            
            IF gSuperTrak.System.Info.SectionsDisabled THEN
                gSuperTrak.System.Cmd.Stop := FALSE;
                MainState := MAIN_STATE_DISABLED;
            END_IF;
        
        MAIN_STATE_ERROR:
            gSuperTrak.System.Cmd.Run := FALSE;
            
            IF ResetTrigger.Q THEN
                MainState := MAIN_STATE_RESET;
            END_IF;
        
        MAIN_STATE_RESET:
            gSuperTrak.System.Cmd.Reset := TRUE;
            IF NOT gSuperTrak.System.Status.Error THEN
                gSuperTrak.System.Cmd.Reset := FALSE;
                MainState := MAIN_STATE_OFF;
            END_IF;
    END_CASE;
    
    // Copy statuses
    gMachine.Status := Interface.Status;
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

