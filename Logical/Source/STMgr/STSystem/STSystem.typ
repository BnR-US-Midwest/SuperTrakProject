
TYPE
	STSystemInterfaceType : 	STRUCT  (*Program interface*)
		Cmd : STSystemInterfaceCmdType;
		Status : STSystemInterfaceStatusType;
		Info : STSystemInterfaceInfoType;
	END_STRUCT;
	STSystemInterfaceCmdType : 	STRUCT  (*Interface commands*)
		Enable : BOOL;
		Run : BOOL;
		Stop : BOOL;
		Reset : BOOL;
	END_STRUCT;
	STSystemInterfaceStatusType : 	STRUCT  (*Interface command response*)
		Active : BOOL;
		Busy : BOOL;
		Ready : BOOL;
		Running : BOOL;
		Stopped : BOOL;
		Error : BOOL;
		ErrorID : DINT;
	END_STRUCT;
	STSystemInterfaceInfoType : 	STRUCT  (*Interface information*)
		WarningPresent : BOOL; (*One or more system warnings are active*)
		Warnings : UDINT; (*System warning bits*)
		FaultPresent : BOOL; (*One or more system faults are active*)
		Faults : UDINT; (*System fault bits*)
		SectionsEnabled : BOOL; (*All sections enabled*)
		SectionsDisabled : BOOL; (*All sections disabled*)
	END_STRUCT;
END_TYPE
