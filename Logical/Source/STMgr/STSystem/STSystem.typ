
TYPE
	STSystemInterfaceType : 	STRUCT  (*Program interface*)
		Cmd : STSystemInterfaceCmdType; (*System commands*)
		Par : STSystemInterfaceParType; (*System parameters*)
		Status : STSystemInterfaceStatusType; (*Status of the System interface*)
		Info : STSystemInterfaceInfoType; (*System information*)
	END_STRUCT;
	STSystemInterfaceCmdType : 	STRUCT  (*Interface commands*)
		Enable : BOOL; (*Enable the SuperTrak system interface*)
		Run : BOOL; (*Run the SuperTrak via System Control (enable all sections)*)
		Stop : BOOL; (*Disable all sections*)
		Reset : BOOL; (*Error Reset*)
	END_STRUCT;
	STSystemInterfaceParType : 	STRUCT  (*Interface parameters*)
		GlobalDirection : UINT := 1; (*Define global direction 0: left (CW) 1: right (CCW)*)
	END_STRUCT;
	STSystemInterfaceStatusType : 	STRUCT  (*Interface command response*)
		Active : BOOL; (*Control function block is Active*)
		Busy : BOOL; (*Interface is processing a command*)
		Ready : BOOL; (*Interface is ready for commands*)
		Running : BOOL; (*SuperTrak is running; sections are enabled*)
		Stopped : BOOL; (*SuperTrak has stopped and task is in Idle state*)
		Error : BOOL; (*There is an active error in the task*)
		ErrorID : DINT; (*ID of the active error*)
	END_STRUCT;
	STSystemInterfaceInfoType : 	STRUCT  (*Interface information*)
		WarningPresent : BOOL; (*One or more system warnings are active*)
		Warnings : UDINT; (*System warning bits*)
		FaultPresent : BOOL; (*One or more system faults are active*)
		Faults : UDINT; (*System fault bits*)
		SectionCount : UINT; (*Number of configured sections (only read once on control enable)*)
		ShuttleCount : UINT; (*Number of shuttles currently on the system (read cyclically)*)
		SectionsEnabled : BOOL; (*All sections enabled*)
		SectionsDisabled : BOOL; (*All sections disabled*)
	END_STRUCT;
END_TYPE
