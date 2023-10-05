
TYPE
	STSystemInterfaceType : 	STRUCT 
		Cmd : STSystemInterfaceCmdType;
		Status : STSystemInterfaceStatusType;
	END_STRUCT;
	STSystemInterfaceCmdType : 	STRUCT 
		Enable : BOOL;
		EnableAllSections : BOOL; (*SuperTrak command to enable all sections*)
		Reset : BOOL; (*Reset error*)
	END_STRUCT;
	STSystemInterfaceStatusType : 	STRUCT 
		Active : BOOL;
		Error : BOOL;
		ErrorID : DINT;
		State : STSystemStateEnum;
	END_STRUCT;
	STSystemStateEnum : 
		(
		STSYSTEM_STATE_OFF,
		STSYSTEM_STATE_ENABLING,
		STSYSTEM_STATE_RUN,
		STSYSTEM_STATE_ERROR,
		STSYSTEM_STATE_RESETTING
		);
END_TYPE
