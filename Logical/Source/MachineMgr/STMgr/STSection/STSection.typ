
TYPE
	STSectionInterfaceType : 	STRUCT 
		Cmd : STSectionInterfaceCmdType;
		Status : STSectionInterfaceStatusType;
	END_STRUCT;
	STSectionInterfaceCmdType : 	STRUCT 
		Enable : BOOL;
		EnableSection : ARRAY[1..ST_SECTION_MAX]OF BOOL;
		Reset : BOOL;
	END_STRUCT;
	STSectionInterfaceStatusType : 	STRUCT 
		Active : BOOL;
		Error : BOOL;
		StatusID : DINT;
		SectionEnabled : ARRAY[1..ST_SECTION_MAX]OF BOOL;
	END_STRUCT;
END_TYPE
