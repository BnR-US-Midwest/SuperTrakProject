
PROGRAM _INIT
	 
END_PROGRAM

PROGRAM _CYCLIC
    
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
        Interface[Index].Status.PalletID := ControlTarget[Index].PalletID;
        Interface[Index].Status.PalletOffsetIndex := ControlTarget[Index].PalletOffsetIdx;
        Interface[Index].Status.PalletPresent := ControlTarget[Index].PalletPresent;
        Interface[Index].Status.PalletInPosition := ControlTarget[Index].PalletInPosition;
        Interface[Index].Status.PalletPreArrival := ControlTarget[Index].PalletPreArrival;
        Interface[Index].Status.PalletOverTarget := ControlTarget[Index].PalletOverTarget;
    
        // Write global outputs
        gSuperTrak.Target[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

