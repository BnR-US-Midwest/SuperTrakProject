
TYPE
	STTargetInterfaceType : 	STRUCT  (*Target control interface*)
		Cmd : STReleaseCommandType; (*Target release commands*)
		Par : STReleaseParameterType; (*Target release parameters*)
		Status : STTargetStatusType; (*Target status structure*)
	END_STRUCT;
	STTargetStatusType : 	STRUCT  (*Target status structure*)
		ShuttlePresent : BOOL; (*A shuttle has arrived, has entered the in-position window, and has not yet been released*)
		ShuttleInPosition : BOOL; (*A shuttle is currently within the in-position window*)
		ShuttlePreArrival : BOOL; (*A shuttle is expected to arrive at the stop within the configured time*)
		ShuttleOverTarget : BOOL; (*A shuttle's shelf is over the target, only reported if configured*)
		ShuttleOffsetIndex : USINT; (*Offset-Table index applied to the shuttle at the target*)
		ShuttleID : USINT; (*ID of shuttle present at target, pallet over target (if configured), or pallet from pre-arrival notification (if configured)*)
		ShuttleReleased : BOOL; (*(Derived) Release command acknowledged. True until release command is reset*)
		ShuttleCount : USINT; (*(Derived) Number of shuttles destined for target*)
		Section : USINT; (*(Par 1650) Target section number*)
		PositionMicrons : DINT; (*(Par 1651) [um] Target section position in microns*)
		Position : REAL; (*(Par 1651) [mm] Target section position*)
	END_STRUCT;
END_TYPE
