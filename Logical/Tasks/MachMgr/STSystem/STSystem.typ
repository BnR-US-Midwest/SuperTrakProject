
TYPE
	STSystemInterfaceType : 	STRUCT 
		Cmd : STSystemInterfaceCmdType;
		Status : STSystemInterfaceStatusType;
	END_STRUCT;
	STSystemInterfaceCmdType : 	STRUCT 
		EnableAllSections : BOOL; (*Enable all SuperTrak sections, requires the system as the enable source*)
		Reset : BOOL; (*Reset error*)
	END_STRUCT;
	STSystemInterfaceStatusType : 	STRUCT 
		Active : BOOL; (*StCom's StControl is active*)
		Error : BOOL; (*StCom's StControl error or SuperTrak system fault*)
	END_STRUCT;
END_TYPE
