
PROGRAM _INIT
	(* Insert code here *)

END_PROGRAM

PROGRAM _CYCLIC
	
    // Copy commands
    Interface.Cmd := gMachine.Cmd;
    
    // Edge triggers
    EnableTrigger(CLK := Interface.Cmd.Enable);
    RunTrigger(CLK := Interface.Cmd.Run);
    
    // Error Handling
    IF gSTSystem.Status.Error OR gSTSection.Status.Error THEN
        MainState := MAIN_STATE_ERROR;
    END_IF;
    
    // Main state machine
    CASE MainState OF
        MAIN_STATE_OFF:
            IF EnableTrigger.Q THEN
                gSTSystem.Cmd.Enable := TRUE;
            END_IF;

            IF gSTSystem.Status.Active THEN
                MainState := MAIN_STATE_INITIALIZE;
            END_IF;

        MAIN_STATE_INITIALIZE:  
            gSTSection.Cmd.Enable := TRUE;
            
            IF gSTSection.Status.Active THEN
                MainState := MAIN_STATE_IDLE;
            END_IF;  
            
        MAIN_STATE_IDLE:
            IF RunTrigger.Q THEN
                MainState := MAIN_STATE_ENABLE_SECTIONS;
            END_IF; 
            
        MAIN_STATE_ENABLE_SECTIONS:      
            AllSectionsEnabled := TRUE; // Set True now, set False later if any section isn't ready
            FOR LoopSection := 1 TO ST_SECTION_MAX DO
                gSTSection.Cmd.EnableSection[LoopSection] := TRUE; 
                IF NOT gSTSection.Status.SectionEnabled[LoopSection] THEN
                    AllSectionsEnabled := FALSE;
                END_IF;
            END_FOR;
            
            IF AllSectionsEnabled THEN
                MainState := MAIN_STATE_RUNNING;
            END_IF;
            
        MAIN_STATE_RUNNING:
            IF NOT Interface.Cmd.Run THEN
                MainState := MAIN_STATE_STOPPING;
            END_IF;
            
        MAIN_STATE_STOPPING:
            
        
        MAIN_STATE_ERROR:
            gSTSystem.Cmd.Enable := FALSE;
            gSTSystem.Cmd.Run := FALSE;
        
            gSTSection.Cmd.Enable := FALSE;
            FOR LoopSection := 1 TO ST_SECTION_MAX DO
                gSTSection.Cmd.EnableSection[LoopSection] := FALSE; 
            END_FOR;
    END_CASE;
    
    // Copy statuses
    gMachine.Status := Interface.Status;
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

