
(* Assign channel ID and size of service channel data *)
ACTION InitializeServiceChannel:
	
    ServiceChannel.channelId := 1;
	
    ServiceChannel.requestBufferSize := SIZEOF(RequestData) - SIZEOF(ServiceChannelHeader_t);
    ServiceChannel.responseBufferSize := SIZEOF(ResponseData) - SIZEOF(ServiceChannelHeader_t);
	
END_ACTION

(* Assign addresses of service channel data *)
ACTION AddressServiceChannel:
	
    ServiceChannel.pRequestHeader := ADR(RequestData);
    ServiceChannel.pResponseHeader := ADR(ResponseData);
    ServiceChannel.pRequestValues := ADR(RequestData) + SIZEOF(ServiceChannelHeader_t);
    ServiceChannel.pResponseValues := ADR(ResponseData) + SIZEOF(ServiceChannelHeader_t);
    RequestHeader ACCESS ADR(RequestData);
    ResponseHeader ACCESS ADR(ResponseData);

END_ACTION

(* Sequence service channel execution *)
ACTION SequenceServiceChannelExecution:
	
    IF ServiceChannel.state = scSTATE_RECV AND RequestHeader.sequence <> ResponseHeader.sequence THEN
        ServiceChannel.requestSequence := RequestHeader.sequence;
        ServiceChannel.state := scSTATE_EXEC;
		
    ELSIF ServiceChannel.state = scSTATE_EXEC OR ServiceChannel.state = scSTATE_WAIT THEN
        SuperTrakServiceChannel(ServiceChannel);
		
    ELSIF ServiceChannel.state = scSTATE_SEND THEN
        LogServiceChannelRequest;
        ServiceChannel.state := scSTATE_RECV;
    END_IF
	
END_ACTION

(* Log request data when service channel request is sent *)
ACTION LogServiceChannelRequest:
	
	// Read Section Count 1080
	// Read System Name 1053
	// Read Enable Signal Source 1057
	// Write PLC Interface Options 1430
	// Write PLC Interface Section Count 1432
	// Write PLC Interface Target Count 1434
	// Write PLC Interface Command Count 1436
	// Write Parameter Save Function 971
	
    Values.i[0] := RequestHeader.task;
    Values.i[1] := RequestHeader.param;
    Values.i[2] := RequestHeader.section;
    Values.i[3] := RequestHeader.count;
    UserLogAdvanced(USERLOG_SEVERITY_INFORMATION, 100, 'Service Channel Request: Task %i, Parameter %i, Section %i, Count %i', Values);
	
END_ACTION

(* Call service channel address and sequence actions *)
ACTION ProcessServiceChannel:
	
    AddressServiceChannel;
    SequenceServiceChannelExecution;

END_ACTION


(* De-Configure any "Allow Section Enable" inputs *)
ACTION DeConfigureAllowSectionEnableInputs:
    
    IF (GetInputFunctions(ADR(DigtalInputFunctions), SIZEOF(DigtalInputFunctions)) = scERR_SUCCESS) THEN
        FOR InputIndex := 0 TO (SIZEOF(DigtalInputFunctions)/SIZEOF(DigtalInputFunctions[0])) DO
            IF DigtalInputFunctions[InputIndex] = 25 THEN
                DigtalInputFunctions[InputIndex] := 0;
            END_IF;
        END_FOR;
        
        SetInputFunctions(ADR(DigtalInputFunctions), SIZEOF(DigtalInputFunctions));
    END_IF;
    
END_ACTION
