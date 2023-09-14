
ACTION LogStComSystemStatus: 
	
	IF FirstScan THEN
		FirstScan := FALSE;
		UserLogBasic(USERLOG_SEVERITY_INFORMATION, 200, 'First scan');
	END_IF
	
	IF ControlSystem.Active AND NOT PreviousStComSystemActive THEN
		UserLogBasic(USERLOG_SEVERITY_INFORMATION, 210, 'StCom StSystem function block active');
	END_IF
	
	PreviousStComSystemActive := ControlSystem.Active;
	
END_ACTION

ACTION LogStComServiceChannel:
	
	// Read Section Count 1080
	// Read System Name 1053
	// Read Enable Signal Source 1057
	// Write PLC Interface Options 1430
	// Write PLC Interface Section Count 1432
	// Write PLC Interface Target Count 1434
	// Write PLC Interface Command Count 1436
	// Write Parameter Save Function 971
	
	IF ServiceChannel.state = scSTATE_EXEC AND ServiceChannel.state <> PreviousServiceChannelState THEN
		Values.i[0] := RequestHeader.task;
		Values.i[1] := RequestHeader.param;
		Values.i[2] := RequestHeader.section;
		Values.i[3] := RequestHeader.count;
		UserLogAdvanced(USERLOG_SEVERITY_INFORMATION, 220, 'Service Channel request execution, task %i, parameter %i, Section %i, Count %i', Values);
	END_IF
	
	PreviousServiceChannelState := ServiceChannel.state;
	
END_ACTION