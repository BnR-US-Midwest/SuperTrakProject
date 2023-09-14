
TYPE
	STCyclicInterfaceType : 	STRUCT  (*Interface structure*)
		Cmd : STCyclicInterfaceCmdType; (*Command structure*)
		Status : STCyclicInterfaceStatusType; (*Status structure*)
	END_STRUCT;
	STCyclicInterfaceCmdType : 	STRUCT  (*Command structure*)
		Reset : BOOL; (*Reset StControl function block errors and SuperTrak system faults & warnings*)
	END_STRUCT;
	STCyclicInterfaceStatusType : 	STRUCT  (*Status structure*)
		Active : BOOL; (*StCom control active*)
		LinkAddress : UDINT; (*StCom StLink address*)
	END_STRUCT;
END_TYPE
