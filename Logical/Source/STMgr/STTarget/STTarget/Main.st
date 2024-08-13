
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
        TargetParameters.AdvancedReleaseConfig.DestinationTarget := Interface[Index].Par.DestinationTarget;
        TargetParameters.AdvancedReleaseConfig.IncrementalOffset := Interface[Index].Par.IncrementalOffset;
        TargetParameters.AdvancedReleaseConfig.TargetOffset := Interface[Index].Par.TargetOffset;
        TargetParameters.AdvancedReleaseConfig.Direction := Interface[Index].Par.Direction;
        TargetParameters.PalletConfig.Motion.Acceleration := REAL_TO_UINT(Interface[Index].Par.Acceleration);
        TargetParameters.PalletConfig.Motion.Velocity := REAL_TO_UINT(Interface[Index].Par.Velocity);
	    
        // StTargetExt function block inputs
        ControlTarget[Index].StLink := ADR(gSTSystemLink);
        ControlTarget[Index].Enable := gSuperTrak.System.Status.Active;
        ControlTarget[Index].ErrorReset := gSuperTrak.System.Cmd.Reset AND ControlTarget[Index].Error;
        ControlTarget[Index].Parameters := ADR(TargetParameters);
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
    
        // Write global outputs
        gSuperTrak.Target[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

