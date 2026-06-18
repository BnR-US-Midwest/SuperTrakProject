(***************************************************************************************
 * EtherNet/IP Communication Data (IO) Processing Actions
 *
 * File: EipComm/IO.st
 * Created: 2026-06-17
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

// Packs data to be transmitted over Ethernet/IP
// Arrays of BOOLs are not allowed, so these must be packed into DINTs
// Arrays of other datatypes need a fixed sized defined in the .dat file
// so data will be copied into these arrays
ACTION PackOutgoingData: 
    
    // Copy System values directly
    IO.Out.SystemEnabled := gSuperTrak.System.Info.SectionsEnabled;
    IO.Out.SystemDisabled := gSuperTrak.System.Info.SectionsDisabled;
    IO.Out.SystemReadyToEnable := gSuperTrak.System.Status.Ready;
    IO.Out.SystemFaultPresent := gSuperTrak.System.Info.FaultPresent;
    IO.Out.SystemFaults := gSuperTrak.System.Info.Faults;
    IO.Out.SystemWarningPresent := gSuperTrak.System.Info.WarningPresent;
    IO.Out.SystemWarnings := gSuperTrak.System.Info.Warnings;
    IO.Out.SystemSectionCount := gSuperTrak.System.Info.SectionCount;
    IO.Out.SystemShuttleCount := gSuperTrak.System.Info.ShuttleCount;
    
    // Loop through all possible Target values
    // If target numbers > 31 are used, the communication
    // definitions must be changed
    FOR i := 1 TO 31 DO
        IF i > ST_TARGET_MAX THEN
            EXIT;
        ELSE
            // Status: Shuttle Present. Pack into a DINT bitwise
            IF gSuperTrak.Target[i].Status.ShuttlePresent THEN
                IO.Out.TargetShuttlePresent := BIT_SET(IO.Out.TargetShuttlePresent, i);
            ELSE
                IO.Out.TargetShuttlePresent := BIT_CLR(IO.Out.TargetShuttlePresent, i);
            END_IF;
            
            // Status: Shuttle ID. Copy into a fixed-size array
            IO.Out.TargetShuttleID[i] := gSuperTrak.Target[i].Status.ShuttleID;
            
            // Status: Shuttle Count. Copy into a fixed-size array
            IO.Out.TargetShuttleCount[i] := gSuperTrak.Target[i].Status.ShuttleCount;
        END_IF;
    END_FOR;

END_ACTION

// Unpacks data received from Ethernet/IP
// Arrays of BOOLs are not allowed, so these must be unpacked from DINTs
// Arrays of other datatypes need a fixed sized defined in the .dat file
// so data will be copied from these arrays
ACTION UnpackIncomingData:
    
    // Don't try to read data if the task is being simulated
    // This will allow setting gSuperTrak members from the Watch window
    // Set TaskIsSimulated False to establish a real EthIP connection to ARSim
    IF TaskIsSimulated THEN
        RETURN;
    END_IF;
    
    // Copy System values directly
    gSuperTrak.System.Cmd.PowerAllSections := IO.In.SystemEnable;
    gSuperTrak.System.Cmd.Reset := IO.In.SystemErrorReset;

    // Loop through all possible Target values
    // If target numbers > 31 are used, the communication
    // definitions must be changed
    FOR i := 1 TO 31 DO
        IF i > ST_TARGET_MAX THEN
            EXIT;
        ELSE
            // Command: Release To Target. Unpack from a DINT bitwise
            gSuperTrak.Target[i].Cmd.Release.ReleaseToTarget := BIT_TST(IO.In.TargetReleaseToTarget, i);
            
            // Parameter: Destination Target. Copy out of a fixed-size array
            gSuperTrak.Target[i].Par.Release.DestinationTarget := IO.In.TargetDestinationTarget[i];
            
            // Parameter: Release Acceleration. Copy out of a fixed-size array
            gSuperTrak.Target[i].Par.Release.Acceleration := IO.In.TargetReleaseAccel[i];
            
            // Parameter: Release Velocity. Copy out of a fixed-size array
            gSuperTrak.Target[i].Par.Release.Velocity := IO.In.TargetReleaseVelocity[i];
        END_IF;
    END_FOR;
    
END_ACTION
