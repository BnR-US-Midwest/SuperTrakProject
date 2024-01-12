
(* Reference control interface and service channel data *)
ACTION ReferenceCyclicData:
	
	gSTCyclicRef.ControlDataAddress := ADR(ControlData);
	gSTCyclicRef.ControlDataSize := SIZEOF(ControlData);
	gSTCyclicRef.StatusDataAddress := ADR(StatusData);
	gSTCyclicRef.StatusDataSize := SIZEOF(StatusData);
	gSTCyclicRef.RequestDataAddress := ADR(RequestData);
	gSTCyclicRef.RequestDataSize := SIZEOF(RequestData);
	gSTCyclicRef.ResponseDataAddress := ADR(ResponseData);
	gSTCyclicRef.ResponseDataSize := SIZEOF(ResponseData);
	
END_ACTION
