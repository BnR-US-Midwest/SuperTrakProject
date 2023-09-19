
ACTION LogStControlActive:
	
	IF FirstScan THEN
		FirstScan := FALSE;
		UserLogBasic(USERLOG_SEVERITY_INFORMATION, 200, 'First scan of cyclic');
	END_IF
	
	IF ControlSystem.Active AND PreviousActive = FALSE THEN
		UserLogBasic(USERLOG_SEVERITY_INFORMATION, 200, 'StControl function block not active');
	END_IF
	PreviousActive := ControlSystem.Active;
	
END_ACTION