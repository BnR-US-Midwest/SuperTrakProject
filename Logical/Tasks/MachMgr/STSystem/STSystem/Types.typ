
TYPE
	StateEnum : 
		(
		STATE_OFF, (*No action, wait for start*)
		STATE_INITIALIZE, (*Enable StControl function block*)
		STATE_IDLE, (*No action, wait for run*)
		STATE_STARTING, (*Enable all sections*)
		STATE_EXECUTE, (*Running, wait for stop*)
		STATE_STOPPING, (*Disable all sections*)
		STATE_ERROR, (*An error occurred*)
		STATE_CLEARING (*Reset error*)
		);
END_TYPE
