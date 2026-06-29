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
    
    // Set TaskIsSimulated initially based on ARSim usage
    // This can be set False if a real Ethernet/IP connection will be established to ARSim
    TaskIsSimulated := DiagCpuIsARsim();
    
    // Make sure this compiles
    StationStatus;
	
    // Initialize Ethernet IP communication
    // This must be done in the INIT program
    fb_EIPInit.enable := TRUE;
    fb_EIPInit.pconfig := ADR('ethIPcon');
    fb_EIPInit();
    InitExitStatus := fb_EIPInit.extstatus;
    
    IF fb_EIPInit.status = 0 THEN
        Initialized := TRUE;
        InitHandle := fb_EIPInit.handle;
        brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
        UserLogCustom('$$arlogusr', USERLOG_SEVERITY_INFORMATION, 1, 30, 0, '', 'EtherNet/IP data object initialized successfully', UserLogArguments);
    ELSE
        Initialized := FALSE;
        InitHandle := 0;
        brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
        brsstrcpy(ADR(UserLogArguments.s[0]), ADR(fb_EIPInit.extstatus));
        UserLogCustom('$$arlogusr', USERLOG_SEVERITY_ERROR, 1, 10, 0, '', 'EtherNet/IP data object initialization failed! Status: %s', UserLogArguments);
        CommState := COMM_STATE_ERROR;
    END_IF;
    
END_PROGRAM

PROGRAM _CYCLIC
	
    // Check for errors
    // Function Block may return ERR_FUB_ENABLE_FALSE or ERR_FUB_BUSY during normal operation
    // Any other nonzero status is an error
    IF EDGEPOS((fb_EIPCyclic.status <> 0) AND (fb_EIPCyclic.status <> ERR_FUB_ENABLE_FALSE) AND (fb_EIPCyclic.status <> ERR_FUB_BUSY)) THEN
        brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
        UserLogArguments.i[0] := fb_EIPCyclic.status;
        UserLogCustom('$$arlogusr', USERLOG_SEVERITY_ERROR, 1, 11, 0, '', 'EtherNet/IP communication error: %i', UserLogArguments);
        CommState := COMM_STATE_ERROR;
    END_IF;
    
    // Pack outgoing data
    PackOutgoingData;
    
    // Communication state machine
    CASE CommState OF
        COMM_STATE_OFF:
            fb_EIPCyclic.enable := FALSE;
            IF Initialized THEN
                CommState := COMM_STATE_ON;
            END_IF;
            
        COMM_STATE_ON:
            fb_EIPCyclic.enable := TRUE;
            IF NOT Initialized THEN // Just provides a way to manually stop communication for debugging
                CommState := COMM_STATE_OFF;
            END_IF;
            
        COMM_STATE_ERROR:
            IF gMachine.Cmd.ErrorReset THEN
                // No error reset on this function block
                // Just disable and re-enable
                fb_EIPCyclic.enable := FALSE;
                CommState := COMM_STATE_OFF;
            END_IF;
    END_CASE;
    
    // Call communication function block cyclicall
    fb_EIPCyclic(handle := InitHandle);
    
    // Unpack received data
    UnpackIncomingData;
	 
END_PROGRAM

PROGRAM _EXIT
	
    // Stop communication and free up resources
    // This must be called in the Exit routine
    fb_EIPExit.enable := TRUE;
    fb_EIPExit.handle := InitHandle;
    fb_EIPExit();
	 
END_PROGRAM
