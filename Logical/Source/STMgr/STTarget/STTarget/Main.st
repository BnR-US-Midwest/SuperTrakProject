
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
        TargetParameters[Index].AdvancedReleaseConfig.DestinationTarget := Interface[Index].Par.DestinationTarget;
        TargetParameters[Index].AdvancedReleaseConfig.IncrementalOffset := Interface[Index].Par.IncrementalOffset;
        TargetParameters[Index].AdvancedReleaseConfig.TargetOffset := Interface[Index].Par.TargetOffset;
        TargetParameters[Index].AdvancedReleaseConfig.Direction := Interface[Index].Par.Direction;
        TargetParameters[Index].PalletConfig.Motion.Acceleration := REAL_TO_UINT(Interface[Index].Par.Acceleration);
        TargetParameters[Index].PalletConfig.Motion.Velocity := REAL_TO_UINT(Interface[Index].Par.Velocity);
	    
        // StTargetExt function block inputs
        ControlTarget[Index].StLink := ADR(gSTSystemLink);
        ControlTarget[Index].Enable := gSuperTrak.System.Status.Active;
        ControlTarget[Index].ErrorReset := gSuperTrak.System.Cmd.Reset AND ControlTarget[Index].Error;
        ControlTarget[Index].Parameters := ADR(TargetParameters[Index]);
        ControlTarget[Index].Target := Index;
        
        ControlTarget[Index].ReleaseToTarget := Interface[Index].Cmd.ReleaseToTarget;
        ControlTarget[Index].ReleaseToOffset := Interface[Index].Cmd.ReleaseToOffset;
        ControlTarget[Index].IncrementOffset := Interface[Index].Cmd.IncrementOffset;
        
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
        r_trig_ShuttleRelease[Index].CLK := (Interface[Index].Cmd.ReleaseToTarget OR Interface[Index].Cmd.ReleaseToOffset OR Interface[Index].Cmd.IncrementOffset);
        r_trig_ShuttleRelease[Index]();
        
        IF r_trig_ShuttleRelease[Index].Q THEN
            // Decrement this target's shuttle count
            IF Interface[Index].Status.ShuttleCount > 0 THEN
                Interface[Index].Status.ShuttleCount := Interface[Index].Status.ShuttleCount - 1;
            END_IF;
            // Increment destination target's shuttle count
            IF Interface[Index].Par.DestinationTarget > 0 AND Interface[Index].Par.DestinationTarget < ST_TARGET_MAX THEN
                Interface[Interface[Index].Par.DestinationTarget].Status.ShuttleCount := Interface[Interface[Index].Par.DestinationTarget].Status.ShuttleCount + 1;
            END_IF;
        END_IF;
            
        // Write global outputs
        gSuperTrak.Target[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

