
TYPE
	STSystemInterfaceType : 	STRUCT 
		Cmd : STSystemInterfaceCmdType;
		Status : STSystemInterfaceStatusType;
	END_STRUCT;
	STSystemInterfaceCmdType : 	STRUCT 
		Start : BOOL;
		Stop : BOOL;
		Run : BOOL;
		Reset : BOOL;
	END_STRUCT;
	STSystemInterfaceStatusType : 	STRUCT 
		Ready : BOOL;
		Running : BOOL;
		Stopped : BOOL;
		Error : BOOL;
		ErrorID : DINT;
	END_STRUCT;
END_TYPE
