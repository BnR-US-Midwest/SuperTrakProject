
TYPE
	STCyclicInterfaceType : 	STRUCT  (*Interface structure*)
		Status : STCyclicInterfaceStatusType; (*Status structure*)
	END_STRUCT;
	STCyclicInterfaceStatusType : 	STRUCT  (*Status structure*)
		ControlDataAddress : UDINT;
		ControlDataSize : UDINT;
		StatusDataAddress : UDINT;
		StatusDataSize : UDINT;
		RequestDataAddress : UDINT;
		RequestDataSize : UDINT;
		ResponseDataAddress : UDINT;
		ResponseDataSize : UDINT;
	END_STRUCT;
END_TYPE
