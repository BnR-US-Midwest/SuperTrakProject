
TYPE
	STTargetInterfaceType : 	STRUCT 
		Cmd : STReleaseCommandType;
		Par : STReleaseParameterType;
		Status : STTargetStatusType;
	END_STRUCT;
	STTargetStatusType : 	STRUCT  (*Target status structure*)
		PalletPresent : BOOL; (*(IF) A pallet has arrived, has entered the in-position window, and has not yet been released*)
		PalletInPosition : BOOL; (*(IF) Pallet is currently within the in-position window*)
		PalletPreArrival : BOOL; (*(IF) A pallet is expected to arrive at the stop within the configured time*)
		PalletOverTarget : BOOL; (*(IF) A pallet's shelf is over the target, only reported if configured*)
		PalletPositionUncertain : BOOL; (*(IF) The associated pallet's actual position is uncertain, see warning #6*)
		PalletID : USINT; (*(IF) ID of pallet present at target, pallet over target (if configured), or pallet from pre-arrival notification (if configured)*)
		PalletOffsetIndex : USINT;
		PalletReleased : BOOL; (*(Derived) Release command successful, pallet has begun movement*)
		PalletCount : USINT; (*(Derived) Number of pallets destined for target*)
		Section : USINT; (*(Par 1650) Target section number*)
		Position : LREAL; (*(Par 1651) [mm] Target section position*)
		GlobalPosition : LREAL; (*(Derived) [mm] Global target position, see StCoreSystemParameterTyp and StPos library*)
		GlobalPositionMicrons : DINT; (*(Derived) [um] Integer global target position in microns, see StCoreSystemParameterTyp and StPos library*)
	END_STRUCT;
END_TYPE
