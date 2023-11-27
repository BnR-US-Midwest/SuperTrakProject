
TYPE
	STSystemInterfaceType : 	STRUCT 
		Cmd : STSystemInterfaceCmdType;
		Status : STSystemInterfaceStatusType;
		Info : STSystemInterfaceInfoType;
	END_STRUCT;
	STSystemInterfaceCmdType : 	STRUCT 
		Start : BOOL;
		Stop : BOOL;
		Run : BOOL;
		Reset : BOOL;
	END_STRUCT;
	STSystemInterfaceStatusType : 	STRUCT 
		Busy : BOOL;
		Ready : BOOL;
		Running : BOOL;
		Stopped : BOOL;
		Error : BOOL;
		ErrorID : DINT;
	END_STRUCT;
	STSystemInterfaceInfoType : 	STRUCT 
		WarningPresent : BOOL; (*One or more system warnings are active*)
		Warnings : UDINT; (*System warning bits*)
		FaultPresent : BOOL; (*One or more system faults are active*)
		Faults : UDINT; (*System fault bits*)
		SectionsEnabled : BOOL; (*All sections enabled*)
		SectionsDisabled : BOOL; (*All sections configured in the PLC interface are disabled*)
	END_STRUCT;
END_TYPE
