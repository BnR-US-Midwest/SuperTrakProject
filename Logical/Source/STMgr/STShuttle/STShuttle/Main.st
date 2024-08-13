
PROGRAM _INIT
	 
END_PROGRAM

PROGRAM _CYCLIC
            
    // Get data for all shuttles when the system is active
    IF gSuperTrak.System.Status.Active THEN
        // Call SuperTrakGetPalletInfo function
        SuperTrakGetPalletInfo(ADR(ShuttleInfo), SIZEOF(ShuttleInfo)/SIZEOF(ShuttleInfo[1]), FALSE); // FALSE - Return actual positions of shuttles
        
        // Read additional parameters via the Service Channel
        SuperTrakServChanRead(0, 1314, 0, 256, ADR(ActualVelocity), SIZEOF(ActualVelocity));
        SuperTrakServChanRead(0, 1339, 0, 256, ADR(DestinationTarget), SIZEOF(DestinationTarget));
        SuperTrakServChanRead(0, 1306, 0, 256, ADR(SectionSetpoint), SIZEOF(SectionSetpoint));
        SuperTrakServChanRead(0, 1311, 0, 256, ADR(PositionSetpoint), SIZEOF(PositionSetpoint));
        SuperTrakServChanRead(0, 1313, 0, 256, ADR(VelocitySetpoint), SIZEOF(VelocitySetpoint));
        SuperTrakServChanRead(0, 1312, 0, 256, ADR(AccelerationSetpoint), SIZEOF(AccelerationSetpoint));
    END_IF;
    
    FOR Index := 1 TO ST_SHUTTLE_MAX DO
        // Read global inputs
        Interface[Index].Cmd := gSuperTrak.Shuttle[Index].Cmd;
        Interface[Index].Par := gSuperTrak.Shuttle[Index].Par;
        
        // Link parameters
        ShuttleParameters.AdvancedReleaseConfig.DestinationTarget := Interface[Index].Par.DestinationTarget;
        ShuttleParameters.AdvancedReleaseConfig.IncrementalOffset := Interface[Index].Par.IncrementalOffset;
        ShuttleParameters.AdvancedReleaseConfig.TargetOffset := Interface[Index].Par.TargetOffset;
        ShuttleParameters.AdvancedReleaseConfig.Direction := Interface[Index].Par.Direction;
        ShuttleParameters.PalletConfig.Motion.Acceleration := REAL_TO_UINT(Interface[Index].Par.Acceleration);
        ShuttleParameters.PalletConfig.Motion.Velocity := REAL_TO_UINT(Interface[Index].Par.Velocity);
	    
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
        
        // Read function outputs
        Interface[Index].Status.ShuttleID := ShuttleInfo[Index].palletID;
        Interface[Index].Status.Present := ShuttleInfo[Index].status.stPALLET_PRESENT;
        Interface[Index].Status.Recovering := ShuttleInfo[Index].status.stPALLET_RECOVERING;
        Interface[Index].Status.AtTarget := ShuttleInfo[Index].status.stPALLET_AT_TARGET;
        Interface[Index].Status.InPosition := ShuttleInfo[Index].status.stPALLET_IN_POSITION;
        Interface[Index].Status.ServoEnabled := ShuttleInfo[Index].status.stPALLET_SERVO_ENABLED;
        Interface[Index].Status.Initializing := ShuttleInfo[Index].status.stPALLET_INITIALIZING;
        Interface[Index].Status.Lost := ShuttleInfo[Index].status.stPALLET_LOST;
        Interface[Index].Status.ControlMode := ShuttleInfo[Index].controlMode;
        Interface[Index].Status.Section := ShuttleInfo[Index].section;
        Interface[Index].Status.PositionMicrons := ShuttleInfo[Index].position;
        Interface[Index].Status.Position := DINT_TO_REAL(Interface[Index].Status.PositionMicrons)/1000.0;
        Interface[Index].Status.Velocity := INT_TO_REAL(ActualVelocity[Index]);
        Interface[Index].Status.DestinationTarget := UINT_TO_USINT(DestinationTarget[Index]);
        Interface[Index].Status.SetSection := UINT_TO_USINT(SectionSetpoint[Index]);
        Interface[Index].Status.SetPositionMicrons := PositionSetpoint[Index];
        Interface[Index].Status.SetPosition := DINT_TO_REAL(Interface[Index].Status.SetPositionMicrons)/1000.0;
        Interface[Index].Status.SetVelocity := VelocitySetpoint[Index];
        Interface[Index].Status.SetAcceleration := AccelerationSetpoint[Index];
        
        // Write global outputs
        gSuperTrak.Shuttle[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

