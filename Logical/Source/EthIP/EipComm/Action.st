
// Packs data to be transmitted over Ethernet/IP
// This is to avoid sending the entire gSuperTrak structure
// Arrays of BOOLs are not allowed
ACTION PackOutgoingData: 
    
    // Loop through all possible target values
    // If target numbers > 31 are used, the communication
    // definitions must be changed
    FOR i := 1 TO 31 DO
        IF i > ST_TARGET_MAX THEN
            EXIT;
        ELSE
            // Set data for ShuttleInPosition
            IF gSuperTrak.Target[i].Status.ShuttleInPosition THEN
                Target_ShuttleAtTarget := BIT_SET(Target_ShuttleAtTarget, i);
            ELSE
                Target_ShuttleAtTarget := BIT_CLR(Target_ShuttleAtTarget, i);
            END_IF;
            
            // Set data for Shuttle Number at Target
            Target_ShuttleNumber[i] := gSuperTrak.Target[i].Status.ShuttleID;
            
            // Set data for Shuttle Count
            Target_ShuttleCount[i] := gSuperTrak.Target[i].Status.ShuttleCount;
        END_IF;
    END_FOR;

END_ACTION

// Unpacks data received from Ethernet/IP
// This is to avoid sending the entire gSuperTrak structure
// Arrays of BOOLs are not allowed
ACTION UnpackIncomingData: 

    // Loop through all possible target values
    // If target numbers > 31 are used, the communication
    // definitions must be changed
    FOR i := 1 TO 31 DO
        IF i > ST_TARGET_MAX THEN
            EXIT;
        ELSE
            // Set data for Next Destination
            gSuperTrak.Target[i].Par.Release.DestinationTarget := Target_NextDestination[i];
            gSuperTrak.Target[i].Par.Release.Velocity := gMachine.Par.Velocity;
            gSuperTrak.Target[i].Par.Release.Acceleration := gMachine.Par.Acceleration;
            gSuperTrak.Target[i].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
            
            // Set data for Release
            gSuperTrak.Target[i].Cmd.Release.ReleaseToTarget := BIT_TST(Target_Release, i);
        END_IF;
    END_FOR;
    
END_ACTION
