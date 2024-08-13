
TYPE
	STSectionInterfaceType : 	STRUCT  (*Section control interface*)
		Cmd : STSectionInterfaceCmdType; (*Section commands*)
		Status : STSectionInterfaceStatusType; (*Section statuses*)
	END_STRUCT;
	STSectionInterfaceCmdType : 	STRUCT  (*Section commands*)
		Enable : BOOL; (*Enable all sections*)
		EnableSection : ARRAY[1..ST_SECTION_MAX]OF BOOL; (*Enable individual sections*)
		Reset : BOOL; (*Error Reset for all sections*)
	END_STRUCT;
	STSectionInterfaceStatusType : 	STRUCT  (*Section statuses*)
		Active : BOOL; (*All section control function blocks are Active*)
		Error : BOOL; (*At least one section function block is reporting an Error*)
		StatusID : DINT; (*StatusID of section function block reporting an error*)
		SectionEnabled : ARRAY[1..ST_SECTION_MAX]OF BOOL; (*Sections that are Enabled have a TRUE value in this array*)
	END_STRUCT;
END_TYPE
