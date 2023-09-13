
PROGRAM _INIT
	
	// Initialize SuperTrak, set configuration path
	SuperTrakInit('/DEVICE=USER_PATH\SuperTrak\Configuration', '127.0.0.1', 'IF3,IF4');
	
	// Set PLC interface to revision 0 for StCom
	PLCInterfaceRevision := 0;
	SuperTrakServChanWrite(0, stPAR_PLC_IF_REVISION, 0, 1, ADR(PLCInterfaceRevision), SIZEOF(PLCInterfaceRevision));
	
	// Initialize StCom system parameters
	SystemParameters.NrOfCommands := 48;
	SystemParameters.NrOfSections := 4;
	SystemParameters.NrOfTargets := 4;
	SystemParameters.NrOfPallets := 4;
	ControlSystem.Enable := TRUE;
	
	// Initialize service channel identifier for StCom
	ServiceChannel.channelId := 1;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Process control and status data of PLC interface for StCom
	ControlInterface.pControl := ADR(ControlData);
	ControlInterface.pStatus := ADR(StatusData);
	ControlInterface.controlSize := SIZEOF(ControlData);
	ControlInterface.statusSize := SIZEOF(StatusData);
	
	// Process control data before SuperTrak cyclic and status data after
	SuperTrakProcessControl(0, ControlInterface);
	SuperTrakCyclic1();
	SuperTrakProcessStatus(0, ControlInterface);
	
	// Call StCom system
	// This function block receives commands from other StCom function blocks
	// The commands are processed in the PLC interface
	ControlSystem.StLink := ADR(gStLink);
	ControlSystem.Parameters := ADR(SystemParameters);
	ControlSystem.StCtrlData := ADR(ControlData);
	ControlSystem.StCtrlDataSize := SIZEOF(ControlData);
	ControlSystem.StStatData := ADR(StatusData);
	ControlSystem.StStatDataSize := SIZEOF(StatusData);
	ControlSystem.StServChRequestData := ADR(RequestData);
	ControlSystem.StServChRequestDataSize := SIZEOF(RequestData);
	ControlSystem.StServChResponseData := ADR(ResponseData);
	ControlSystem.StServChResponseDataSize := SIZEOF(ResponseData);
	ControlSystem();
	
	// Call service channel
	// This is used for a short amount of time to configure the PLC interface for StCom
	ServiceChannel.pRequestHeader := ADR(RequestData);
	ServiceChannel.pResponseHeader := ADR(ResponseData);
	ServiceChannel.pRequestValues := ADR(RequestData) + SIZEOF(ServiceChannelHeader_t);
	ServiceChannel.pResponseValues := ADR(ResponseData) + SIZEOF(ServiceChannelHeader_t);
	ServiceChannel.requestBufferSize := SIZEOF(RequestData) - SIZEOF(ServiceChannelHeader_t);
	ServiceChannel.responseBufferSize := SIZEOF(ResponseData) - SIZEOF(ServiceChannelHeader_t);
	RequestHeader ACCESS ADR(RequestData);
	ResponseHeader ACCESS ADR(ResponseData);
	
	IF ServiceChannel.state = scSTATE_RECV AND RequestHeader.sequence <> ResponseHeader.sequence THEN
		ServiceChannel.requestSequence := RequestHeader.sequence;
		ServiceChannel.state := scSTATE_EXEC;
		
	ELSIF ServiceChannel.state = scSTATE_EXEC OR ServiceChannel.state = scSTATE_WAIT THEN
		SuperTrakServiceChannel(ServiceChannel);
		
	ELSIF ServiceChannel.state = scSTATE_SEND THEN
		ServiceChannel.state := scSTATE_RECV;
	END_IF
	
END_PROGRAM

PROGRAM _EXIT
	
	SuperTrakExit();
	
END_PROGRAM

