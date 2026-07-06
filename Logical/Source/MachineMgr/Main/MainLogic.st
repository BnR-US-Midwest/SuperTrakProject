(***************************************************************************************
 * Main State Machine
 *
 * This Action should be placed in the RUN state of the Main State Machine. 
 * It interfaces with the gSuperTrak structure to read statuses and write back 
 * shuttle release commands.
 *
 * If the main machine logic is written elsewhere (e.g., in an AB PLC), this Action 
 * should not be run. Instead, data is passed to/from gSuperTrak via the EipComm task.
 *
 * File: Main/MainLogic.st
 * Created: 2026-06-19
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

ACTION MainLogic: 
            
    (*******************************************************
     *******************************************************
                Target control code goes here 
    *******************************************************
    *******************************************************)
    
    // In simulation, timers are used to simulate process stations
    // On a real system, release commands should come from a real signal (e.g., a Digital Input)
    FOR LoopTarget := 1 TO ST_TARGET_MAX DO
        ProcessTimer[LoopTarget].IN := gSuperTrak.Target[LoopTarget].Status.ShuttlePresent;
        ProcessTimer[LoopTarget].PT := SimulatedProcessTimes[LoopTarget];
        ProcessTimer[LoopTarget]();
    END_FOR;
            
    // Target 1: Load
    IF ProcessTimer[ST_TARGET_LOAD].Q THEN
        IF gSuperTrak.Target[ST_TARGET_LOAD].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
            gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.Velocity := Interface.Par.Velocity;
            gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.Acceleration := Interface.Par.Acceleration;
            gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
            gSuperTrak.Target[ST_TARGET_LOAD].Par.Release.DestinationTarget := ST_TARGET_QUEUE;
            gSuperTrak.Target[ST_TARGET_LOAD].Cmd.Release.ReleaseToTarget := TRUE;
        END_IF
    END_IF   
            
    // Target 2: Queue
    IF ProcessTimer[ST_TARGET_QUEUE].Q AND gSuperTrak.Target[ST_TARGET_PROCESS].Status.ShuttleCount = 0 THEN
        IF gSuperTrak.Target[ST_TARGET_QUEUE].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
            gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.Velocity := Interface.Par.Velocity;
            gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.Acceleration := Interface.Par.Acceleration;
            gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
            gSuperTrak.Target[ST_TARGET_QUEUE].Par.Release.DestinationTarget := ST_TARGET_PROCESS;
            gSuperTrak.Target[ST_TARGET_QUEUE].Cmd.Release.ReleaseToTarget := TRUE;
        END_IF
    END_IF 
            
    // Target 3: Process
    IF ProcessTimer[ST_TARGET_PROCESS].Q THEN
        IF gSuperTrak.Target[ST_TARGET_PROCESS].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
            gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.Velocity := Interface.Par.Velocity;
            gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.Acceleration := Interface.Par.Acceleration;
            gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
            gSuperTrak.Target[ST_TARGET_PROCESS].Par.Release.DestinationTarget := ST_TARGET_UNLOAD;
            gSuperTrak.Target[ST_TARGET_PROCESS].Cmd.Release.ReleaseToTarget := TRUE;
        END_IF
    END_IF   
            
    // Target 4: Unload
    IF ProcessTimer[ST_TARGET_UNLOAD].Q THEN
        IF gSuperTrak.Target[ST_TARGET_UNLOAD].Cmd.Release.ReleaseToTarget = FALSE THEN // Rising edge (one-shot)
            gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.Velocity := Interface.Par.Velocity;
            gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.Acceleration := Interface.Par.Acceleration;
            gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.Direction := gSuperTrak.System.Par.GlobalDirection;
            gSuperTrak.Target[ST_TARGET_UNLOAD].Par.Release.DestinationTarget := ST_TARGET_LOAD;
            gSuperTrak.Target[ST_TARGET_UNLOAD].Cmd.Release.ReleaseToTarget := TRUE;
        END_IF
    END_IF   
            
    // Reset commands
    FOR LoopTarget := 1 TO ST_TARGET_MAX DO
        IF gSuperTrak.Target[LoopTarget].Status.ShuttleReleased THEN
            brsmemset(ADR(gSuperTrak.Target[LoopTarget].Cmd), 0, SIZEOF(gSuperTrak.Target[LoopTarget].Cmd));
        END_IF
    END_FOR

END_ACTION
