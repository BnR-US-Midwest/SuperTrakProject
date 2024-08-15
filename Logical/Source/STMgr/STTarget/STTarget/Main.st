
PROGRAM _INIT
	 
END_PROGRAM

PROGRAM _CYCLIC
    
    // Get data for all targets when the system is active
    IF gSuperTrak.System.Status.Active THEN 
        SuperTrakServChanRead(0, 1650, 0, 256, ADR(Sections), SIZEOF(Sections));
        SuperTrakServChanRead(0, 1651, 0, 256, ADR(Positions), SIZEOF(Positions));
    END_IF;
    
    FOR Index := 1 TO ST_TARGET_MAX DO
        // Read global inputs
        Interface[Index].Cmd := gSuperTrak.Target[Index].Cmd;
        Interface[Index].Par := gSuperTrak.Target[Index].Par;
        
        // Link parameters
        TargetParameters[Index].AdvancedReleaseConfig.DestinationTarget := Interface[Index].Par.Release.DestinationTarget;
        TargetParameters[Index].AdvancedReleaseConfig.IncrementalOffset := Interface[Index].Par.Release.IncrementalOffset;
        TargetParameters[Index].AdvancedReleaseConfig.TargetOffset := Interface[Index].Par.Release.TargetOffset;
        TargetParameters[Index].AdvancedReleaseConfig.Direction := Interface[Index].Par.Release.Direction;
        TargetParameters[Index].PalletConfig.Motion.Acceleration := REAL_TO_UINT(Interface[Index].Par.Release.Acceleration);
        TargetParameters[Index].PalletConfig.Motion.Velocity := REAL_TO_UINT(Interface[Index].Par.Release.Velocity);
        TargetParameters[Index].PalletConfig.ID := Interface[Index].Par.SetShuttleID;
	    
        // StTargetExt function block inputs
        ControlTarget[Index].StLink := ADR(gSTSystemLink);
        ControlTarget[Index].Enable := gSuperTrak.System.Status.Active;
        ControlTarget[Index].ErrorReset := gSuperTrak.System.Cmd.Reset AND ControlTarget[Index].Error;
        ControlTarget[Index].Parameters := ADR(TargetParameters[Index]);
        ControlTarget[Index].Target := Index;
        
        CASE TargetControlState[Index] OF
            TARGET_STATE_WAIT_FOR_SHUTTLE:
                IF ControlTarget[Index].PalletPresent THEN
                    TargetControlState[Index] := TARGET_STATE_SHUTTLE_PRESENT;
                END_IF;
            
            TARGET_STATE_SHUTTLE_PRESENT:
                IF Interface[Index].Cmd.SetShuttleID THEN
                    TargetControlState[Index] := TARGET_STATE_SET_SHUTTLE_ID;
                ELSIF Interface[Index].Cmd.Release.ReleaseToTarget OR Interface[Index].Cmd.Release.ReleaseToOffset OR Interface[Index].Cmd.Release.IncrementOffset THEN
                    TargetControlState[Index] := TARGET_STATE_SET_MOTION_PARS;
                END_IF;
                
            TARGET_STATE_SET_SHUTTLE_ID:
                ControlTarget[Index].SetPalletID := TRUE;
                IF ControlTarget[Index].CommandDone THEN
                    ControlTarget[Index].SetPalletID := FALSE;
                    Interface[Index].Status.ShuttleIDSet := TRUE;
                    TargetControlState[Index] := TARGET_STATE_WAIT_FOR_CMD_RESET;
                END_IF;
            
            TARGET_STATE_SET_MOTION_PARS:
                ControlTarget[Index].SetPalletMotionPar := TRUE;
                IF ControlTarget[Index].CommandDone THEN
                    ControlTarget[Index].SetPalletMotionPar := FALSE;
                    TargetControlState[Index] := TARGET_STATE_RELEASE_SHUTTLE;
                END_IF;
            
            TARGET_STATE_RELEASE_SHUTTLE:
                ControlTarget[Index].ReleaseToTarget := Interface[Index].Cmd.Release.ReleaseToTarget; // Trust that the user won't set more than 
                ControlTarget[Index].ReleaseToOffset := Interface[Index].Cmd.Release.ReleaseToOffset; // one of these at the same time
                ControlTarget[Index].IncrementOffset := Interface[Index].Cmd.Release.IncrementOffset; // Not sure what would happen in that case
                TargetControlState[Index] := TARGET_STATE_WAIT_FOR_RELEASE;
            
            TARGET_STATE_WAIT_FOR_RELEASE:
                IF NOT ControlTarget[Index].PalletPresent THEN
                    ControlTarget[Index].ReleaseToTarget := FALSE;
                    ControlTarget[Index].ReleaseToOffset := FALSE;
                    ControlTarget[Index].IncrementOffset := FALSE;
                    Interface[Index].Status.ShuttleReleased := TRUE;
                    TargetControlState[Index] := TARGET_STATE_WAIT_FOR_CMD_RESET;
                END_IF;
            
            TARGET_STATE_WAIT_FOR_CMD_RESET:
                IF NOT (Interface[Index].Cmd.SetShuttleID OR Interface[Index].Cmd.Release.ReleaseToTarget 
                    OR Interface[Index].Cmd.Release.ReleaseToOffset OR Interface[Index].Cmd.Release.IncrementOffset) THEN
                    Interface[Index].Status.ShuttleReleased := FALSE;
                    Interface[Index].Status.ShuttleIDSet := FALSE; // Reset all "Command Done" Statuses
                    TargetControlState[Index] := TARGET_STATE_WAIT_FOR_SHUTTLE;
                END_IF;
        END_CASE;

        // Call StTargetExt function block
        ControlTarget[Index]();
        
        // Read StTargetExt function block outputs
        Interface[Index].Status.ShuttleID := ControlTarget[Index].PalletID;
        Interface[Index].Status.ShuttleOffsetIndex := ControlTarget[Index].PalletOffsetIdx;
        Interface[Index].Status.ShuttlePresent := ControlTarget[Index].PalletPresent;
        Interface[Index].Status.ShuttleInPosition := ControlTarget[Index].PalletInPosition;
        Interface[Index].Status.ShuttlePreArrival := ControlTarget[Index].PalletPreArrival;
        Interface[Index].Status.ShuttleOverTarget := ControlTarget[Index].PalletOverTarget;
        Interface[Index].Status.Section := UINT_TO_USINT(Sections[Index]);
        Interface[Index].Status.PositionMicrons := Positions[Index];
        Interface[Index].Status.Position := DINT_TO_REAL(Interface[Index].Status.PositionMicrons)/1000.0;
        
        // Check for release commands and update ShuttleCount status
        r_trig_ShuttleRelease[Index].CLK := (Interface[Index].Cmd.Release.ReleaseToTarget 
        OR Interface[Index].Cmd.Release.ReleaseToOffset OR Interface[Index].Cmd.Release.IncrementOffset);
        r_trig_ShuttleRelease[Index]();
        
        IF r_trig_ShuttleRelease[Index].Q THEN
            // Decrement this target's shuttle count
            IF Interface[Index].Status.ShuttleCount > 0 THEN
                Interface[Index].Status.ShuttleCount := Interface[Index].Status.ShuttleCount - 1;
            END_IF;
            // Increment destination target's shuttle count
            IF Interface[Index].Par.Release.DestinationTarget > 0 AND Interface[Index].Par.Release.DestinationTarget < ST_TARGET_MAX THEN
                Interface[Interface[Index].Par.Release.DestinationTarget].Status.ShuttleCount := 
                Interface[Interface[Index].Par.Release.DestinationTarget].Status.ShuttleCount + 1;
            END_IF;
        END_IF;
            
        // Write global outputs
        gSuperTrak.Target[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

