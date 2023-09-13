
TYPE
	STCyclicInterfaceType : 	STRUCT  (*Interface structure*)
		Status : STCyclicInterfaceStatusType; (*Status structure*)
	END_STRUCT;
	STCyclicInterfaceStatusType : 	STRUCT  (*Status structure*)
		LinkAddress : UDINT; (*StLink address*)
	END_STRUCT;
END_TYPE
