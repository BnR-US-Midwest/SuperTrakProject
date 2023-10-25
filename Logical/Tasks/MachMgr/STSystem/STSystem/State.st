
ACTION SetStateName:
	
	CASE State OF
		STATE_OFF: StateName := 'OFF';
		STATE_ENABLING: StateName := 'ENABLING';
		STATE_IDLE: StateName := 'IDLE';
		STATE_RUNNING: StateName := 'RUNNING';
		STATE_STOPPED: StateName := 'STOPPED';
		STATE_ERROR: StateName := 'ERROR';
		STATE_RESETTING: StateName := 'RESETTING';
		ELSE StateName := 'UNKNOWN';
	END_CASE
	
END_ACTION

ACTION LogStateChange: 
	
	IF State <> PreviousState THEN
		LogValues.s[0] := PreviousStateName;
		LogValues.s[1] := StateName;
		UserLogAdvanced(USERLOG_SEVERITY_INFORMATION, 1000, 'State changed from %s to %s', LogValues);
	END_IF
	PreviousState := State;
	
END_ACTION
