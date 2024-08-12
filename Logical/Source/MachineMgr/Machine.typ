
TYPE
	Machine_type : 	STRUCT 
		Cmd : Machine_Cmd_type;
		Status : Machine_Status_type;
	END_STRUCT;
	Machine_Cmd_type : 	STRUCT 
		Enable : BOOL;
		Run : BOOL;
		ErrorReset : BOOL;
	END_STRUCT;
	Machine_Status_type : 	STRUCT 
		Error : BOOL;
	END_STRUCT;
END_TYPE
