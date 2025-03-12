(***************************************************************************************
 * EipComm task
 *
 * This task handles Ethernet/IP Communication. It is only used if the SuperTrak will
 * be controlled by another PLC via EtherNet/IP. This task exchanges Ethernet/IP 
 * data with the gSuperTrak structure.
 *
 * The data that will be exchanged is defined in the ethIPcon.dat file
 *
 * This is meant to be a starting point, but more data may need to be communicated
 * depending on the application
 *
 * File: EipComm.st
 * Created: 2025-03-12
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

PROGRAM _INIT
    
    // Make sure this compiles
    StationStatus;
	
    // Initialize Ethernet IP communication
    // This must be done in the INIT program
    fb_EIPInit.enable := TRUE;
    fb_EIPInit.pconfig := ADR('ethIPcon');
    fb_EIPInit();
    
    IF fb_EIPInit.status = 0 THEN
        Interface.Command.Run := TRUE;
        Interface.Parameter.InitHandle := fb_EIPInit.handle;
    ELSE
        CommState := COMM_STATE_ERROR;
    END_IF;
    
    Interface.Status.InitExitStatus := fb_EIPInit.extstatus;
	 
END_PROGRAM

PROGRAM _CYCLIC
	
    // Check for errors
    // Function Block may return ERR_FUB_ENABLE_FALSE or ERR_FUB_BUSY during normal operation
    // Any other nonzero status is an error
    IF (fb_EIPCyclic.status <> 0) AND (fb_EIPCyclic.status <> ERR_FUB_ENABLE_FALSE) AND (fb_EIPCyclic.status <> ERR_FUB_ENABLE_FALSE <> ERR_FUB_BUSY) THEN
        CommState := COMM_STATE_ERROR;
    END_IF;
    
    // Pack outgoing data
    PackOutgoingData;
    
    // Communication state machine
    CASE CommState OF
        COMM_STATE_OFF:
            fb_EIPCyclic.enable := FALSE;
            IF Interface.Command.Run THEN
                CommState := COMM_STATE_ON;
            END_IF;
            
        COMM_STATE_ON:
            fb_EIPCyclic.enable := TRUE;
            IF NOT Interface.Command.Run THEN
                CommState := COMM_STATE_OFF;
            END_IF;
            
        COMM_STATE_ERROR:
            IF Interface.Command.ErrorReset THEN
                // No error reset on this function block
                // Just disable and re-enable
                fb_EIPCyclic.enable := FALSE;
                CommState := COMM_STATE_OFF;
            END_IF;
    END_CASE;
    
    // Call communication function block cyclically
    
    fb_EIPCyclic.handle := Interface.Parameter.InitHandle;
    fb_EIPCyclic();
    
    // Unpack received data
    UnpackIncomingData;
	 
END_PROGRAM

PROGRAM _EXIT
	
    // Stop communication and free up resources
    // This must be called in the Exit routine
    fb_EIPExit.enable := TRUE;
    fb_EIPExit.handle := Interface.Parameter.InitHandle;
    fb_EIPExit();
	 
END_PROGRAM
