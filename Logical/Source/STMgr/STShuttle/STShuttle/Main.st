(*******************************************************************************************
 * STShuttle task
 *
 * This task provides a state machine for controlling and monitoring 
 * SuperTrak Shuttles. This task can be interfaced with via gSuperTrak.Shuttle[Shuttle #]
 * where "Shuttle #" is an array value indexed starting at 1 (see: Trakmaster shuttles)
 *
 * File: STShuttle.st
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
*******************************************************************************************)

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
        ShuttleParameters[Index].AdvancedReleaseConfig.DestinationTarget := Interface[Index].Par.DestinationTarget;
        ShuttleParameters[Index].AdvancedReleaseConfig.IncrementalOffset := Interface[Index].Par.IncrementalOffset;
        ShuttleParameters[Index].AdvancedReleaseConfig.TargetOffset := Interface[Index].Par.TargetOffset;
        ShuttleParameters[Index].AdvancedReleaseConfig.Direction := Interface[Index].Par.Direction;
        ShuttleParameters[Index].PalletConfig.Motion.Acceleration := REAL_TO_UINT(Interface[Index].Par.Acceleration);
        ShuttleParameters[Index].PalletConfig.Motion.Velocity := REAL_TO_UINT(Interface[Index].Par.Velocity);
	    
        // StShuttleExt function block inputs
        ControlShuttle[Index].StLink := ADR(gSTSystemLink);
        ControlShuttle[Index].Enable := gSuperTrak.System.Status.Active;
        ControlShuttle[Index].ErrorReset := gSuperTrak.System.Cmd.Reset AND ControlShuttle[Index].Error;
        ControlShuttle[Index].Parameters := ADR(ShuttleParameters[Index]);
        ControlShuttle[Index].PalletID := Index;
        
        CASE ShuttleControlState[Index] OF
            SHUTTLE_STATE_WAIT_FOR_COMMAND:
                IF Interface[Index].Cmd.ReleaseToTarget OR Interface[Index].Cmd.ReleaseToOffset OR Interface[Index].Cmd.IncrementOffset THEN
                    ShuttleControlState[Index] := SHUTTLE_STATE_SET_MOTION_PARS;
                END_IF;
            
            SHUTTLE_STATE_SET_MOTION_PARS:
                ControlShuttle[Index].SetPalletMotionPar := TRUE;
                IF ControlShuttle[Index].CommandDone THEN
                    ControlShuttle[Index].SetPalletMotionPar := FALSE;
                    ShuttleControlState[Index] := SHUTTLE_STATE_RELEASE_SHUTTLE;
                END_IF;
            
            SHUTTLE_STATE_RELEASE_SHUTTLE:
                ControlShuttle[Index].ReleaseToTarget := Interface[Index].Cmd.ReleaseToTarget;
                ControlShuttle[Index].ReleaseToOffset := Interface[Index].Cmd.ReleaseToOffset;
                ControlShuttle[Index].IncrementOffset := Interface[Index].Cmd.IncrementOffset;
                Interface[Index].Status.ShuttleReleased := TRUE;
                ShuttleControlState[Index] := SHUTTLE_STATE_WAIT_FOR_CMD_RESET;
            
            SHUTTLE_STATE_WAIT_FOR_CMD_RESET:
                IF NOT(Interface[Index].Cmd.ReleaseToTarget OR Interface[Index].Cmd.ReleaseToOffset OR Interface[Index].Cmd.IncrementOffset) THEN
                    Interface[Index].Status.ShuttleReleased := FALSE;
                    ControlShuttle[Index].ReleaseToTarget := FALSE;
                    ControlShuttle[Index].ReleaseToOffset := FALSE;
                    ControlShuttle[Index].IncrementOffset := FALSE;
                    ShuttleControlState[Index] := SHUTTLE_STATE_WAIT_FOR_COMMAND;
                END_IF;
        END_CASE;
        
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
        
        // Log errors only when that error first occurs
        r_trig_ShuttleFBError[Index](CLK := ControlShuttle[Index].Error);
        
        IF r_trig_ShuttleFBError[Index].Q THEN
            brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
            UserLogArguments.i[0] := Index; 
            UserLogArguments.i[1] := ControlShuttle[Index].StatusID;
            UserLogAdvanced(USERLOG_SEVERITY_ERROR, 1300, 'SuperTrak Shuttle Control error. Shuttle: %i. Status ID: %i', UserLogArguments);
        END_IF;
                
        // Check for release commands and update Target ShuttleCount statuses
        r_trig_ShuttleRelease[Index].CLK := (Interface[Index].Cmd.ReleaseToTarget OR Interface[Index].Cmd.ReleaseToOffset OR Interface[Index].Cmd.IncrementOffset);
        r_trig_ShuttleRelease[Index]();
        
        IF r_trig_ShuttleRelease[Index].Q THEN
            // Decrement current target's shuttle count (if shuttle is currently at a target)
            IF Interface[Index].Status.AtTarget THEN
                ShuttleAtTarget := 0;
                FOR TargetIndex := 1 TO ST_TARGET_MAX DO
                    IF gSuperTrak.Target[TargetIndex].Status.ShuttlePresent AND gSuperTrak.Target[TargetIndex].Status.ShuttleID = Index THEN
                        ShuttleAtTarget := TargetIndex;
                        EXIT;
                    END_IF;
                END_FOR;

                IF ShuttleAtTarget > 0 AND ShuttleAtTarget < ST_TARGET_MAX THEN
                    IF gSuperTrak.Target[ShuttleAtTarget].Status.ShuttleCount > 0 THEN
                        gSuperTrak.Target[ShuttleAtTarget].Status.ShuttleCount := gSuperTrak.Target[ShuttleAtTarget].Status.ShuttleCount - 1;
                    END_IF;
                END_IF;
            END_IF;
            // Increment destination target's shuttle count
            IF gSuperTrak.Shuttle[Index].Par.DestinationTarget > 0 AND gSuperTrak.Shuttle[Index].Par.DestinationTarget < ST_TARGET_MAX THEN
                gSuperTrak.Target[gSuperTrak.Shuttle[Index].Par.DestinationTarget].Status.ShuttleCount := 
                gSuperTrak.Target[gSuperTrak.Shuttle[Index].Par.DestinationTarget].Status.ShuttleCount + 1;
            END_IF;
        END_IF; 
        
        // Write global outputs
        gSuperTrak.Shuttle[Index].Status := Interface[Index].Status;
    END_FOR
	 
END_PROGRAM
