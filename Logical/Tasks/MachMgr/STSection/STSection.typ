
TYPE
	STSectionInterfaceType : 	STRUCT 
		Cmd : STSectionInterfaceCmdType;
		Par : STSectionInterfaceParType;
		Status : STSectionInterfaceStatusType;
	END_STRUCT;
	STSectionInterfaceCmdType : 	STRUCT 
		Enable : BOOL;
		EnableSection : BOOL;
		Reset : BOOL;
	END_STRUCT;
	STSectionInterfaceParType : 	STRUCT 
		Section : USINT;
	END_STRUCT;
	STSectionInterfaceStatusType : 	STRUCT 
		Active : BOOL;
		Error : BOOL;
	END_STRUCT;
END_TYPE
