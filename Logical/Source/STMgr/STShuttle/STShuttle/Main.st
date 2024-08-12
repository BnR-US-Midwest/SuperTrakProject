
PROGRAM _INIT
	 
END_PROGRAM

PROGRAM _CYCLIC
    
    FOR Index := 1 TO ST_SHUTTLE_MAX DO
        // Read global inputs
        Interface[Index].Cmd := gSuperTrak.Shuttle[Index].Cmd;
        Interface[Index].Par := gSuperTrak.Shuttle[Index].Par;
        
        // Link parameters
        ShuttleParameters.AdvancedReleaseConfig.DestinationTarget := Interface[Index].Par.DestinationTarget;
        ShuttleParameters.AdvancedReleaseConfig.IncrementalOffset := Interface[Index].Par.IncrementalOffset;
        ShuttleParameters.AdvancedReleaseConfig.TargetOffset := Interface[Index].Par.TargetOffset;
        ShuttleParameters.AdvancedReleaseConfig.Direction := Interface[Index].Par.Direction;
        ShuttleParameters.PalletConfig.Motion.Acceleration := Interface[Index].Par.Acceleration;
        ShuttleParameters.PalletConfig.Motion.Velocity := Interface[Index].Par.Velocity;
	    
        // StShuttleExt function block inputs
        ControlShuttle[Index].StLink := ADR(gSTSystemLink);
        ControlShuttle[Index].Enable := gSuperTrak.System.Status.Active;
        ControlShuttle[Index].ErrorReset := gSuperTrak.System.Cmd.Reset AND ControlShuttle[Index].Error;
        ControlShuttle[Index].Parameters := ADR(ShuttleParameters);
        ControlShuttle[Index].PalletID := Index;
        
        ControlShuttle[Index].ReleaseToTarget := Interface[Index].Cmd.ReleaseToTarget;
        ControlShuttle[Index].ReleaseToOffset := Interface[Index].Cmd.ReleaseToOffset;
        ControlShuttle[Index].IncrementOffset := Interface[Index].Cmd.IncrementOffset;
        
        // Call StShuttleExt function block
        ControlShuttle[Index]();
        
        // Read StShuttleExt function block outputs
    
        // Write global outputs
        gSuperTrak.Shuttle[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

