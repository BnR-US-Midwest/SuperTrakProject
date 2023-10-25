
ACTION ThrowError: 
	
	LogValues.i[0] := Interface.Status.ErrorID;
	LogValues.s[0] := StateName;
	UserLogAdvanced(USERLOG_SEVERITY_ERROR, 1001, 'Error %i in state %s', LogValues);
	
	Interface.Status.Ready := FALSE;
	Interface.Status.Running := FALSE;
	Interface.Status.Stopped := FALSE;
	Interface.Status.Error := TRUE;
	
	State := STATE_ERROR;
	
END_ACTION
