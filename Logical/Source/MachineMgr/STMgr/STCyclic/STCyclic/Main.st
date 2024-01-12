
PROGRAM _INIT
	
	// Initialize SuperTrak, set configuration path
	SuperTrakInit('/DEVICE=USER_PATH\SuperTrak\Configuration', '127.0.0.1', 'IF3,IF4');
	
	// Set PLC interface to revision 0 for StCom
	PLCInterfaceRevision := 0;
	SuperTrakServChanWrite(0, stPAR_PLC_IF_REVISION, 0, 1, ADR(PLCInterfaceRevision), SIZEOF(PLCInterfaceRevision));
	
	// Initialize service channel identifier for StCom
	ServiceChannel.channelId := 1;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Process control and status data of PLC interface for StCom
	PLCInterfaceParameters.pControl := ADR(ControlData);
	PLCInterfaceParameters.pStatus := ADR(StatusData);
	PLCInterfaceParameters.controlSize := SIZEOF(ControlData);
	PLCInterfaceParameters.statusSize := SIZEOF(StatusData);
	
	// Process control data before SuperTrak cyclic and status data after
	SuperTrakProcessControl(0, PLCInterfaceParameters);
	SuperTrakCyclic1();
	SuperTrakProcessStatus(0, PLCInterfaceParameters);
	
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
	
	// StCom has access to request and response data
	// The SuperTrakServiceChannel function is called when the sequence count increments
	// See the SuperTrak library help for SuperTrakServiceChannel
	IF ServiceChannel.state = scSTATE_RECV AND RequestHeader.sequence <> ResponseHeader.sequence THEN
		ServiceChannel.requestSequence := RequestHeader.sequence;
		ServiceChannel.state := scSTATE_EXEC;
		
	ELSIF ServiceChannel.state = scSTATE_EXEC OR ServiceChannel.state = scSTATE_WAIT THEN
		SuperTrakServiceChannel(ServiceChannel);
		
	ELSIF ServiceChannel.state = scSTATE_SEND THEN
		ServiceChannel.state := scSTATE_RECV;
	END_IF
	
	// Share data access to StCom's StControl
	gSTCyclicReference.ControlDataAddress := ADR(ControlData);
	gSTCyclicReference.ControlDataSize := SIZEOF(ControlData);
	gSTCyclicReference.StatusDataAddress := ADR(StatusData);
	gSTCyclicReference.StatusDataSize := SIZEOF(StatusData);
	gSTCyclicReference.RequestDataAddress := ADR(RequestData);
	gSTCyclicReference.RequestDataSize := SIZEOF(RequestData);
	gSTCyclicReference.ResponseDataAddress := ADR(ResponseData);
	gSTCyclicReference.ResponseDataSize := SIZEOF(ResponseData);
	
	// Log service channel requests
	LogStComServiceChannel;
	
END_PROGRAM

PROGRAM _EXIT
	
	SuperTrakExit();
	
END_PROGRAM

