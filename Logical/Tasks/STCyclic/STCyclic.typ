
TYPE
	STCyclicInterfaceType : 	STRUCT  (*Interface structure*)
		Status : STCyclicInterfaceStatusType; (*Status structure*)
	END_STRUCT;
	STCyclicInterfaceStatusType : 	STRUCT  (*Status structure*)
		Active : BOOL; (*StCom system active*)
		LinkAddress : UDINT; (*StCom StLink address*)
	END_STRUCT;
END_TYPE
