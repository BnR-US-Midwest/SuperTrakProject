(*
Copyright ATS Automation Tooling Systems, Inc. 2015-2022
All rights reserved.
*)
(*
=== begin SuperTrak standard items ===
*)
(*SuperTrak Conveyor Controller implementation*)

FUNCTION SuperTrakInit : BOOL (*Called during INIT of Cyclic #1*) (*Not used*)
	VAR_INPUT
		storagePath : STRING[127]; (*Specifies the filesystem location for conveyor configuration data*)
		simIPAddress : STRING[15]; (*Simulation IP address, as specified in CPU Configuration*)
		ethernetInterfaces : STRING[63]; (*Comma-delimited list of Ethernet interfaces. Example: 'IF3,IF4'*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakFieldbusHwConfig : BOOL
	VAR_INPUT
		pOptions : UDINT; (*Pointer to array of FieldbusHardwareOption_t*)
		optionCount : UINT;
	END_VAR
END_FUNCTION

FUNCTION SuperTrakCyclic1 : BOOL (*Called during Cyclic #1*) (*Not used*)
END_FUNCTION

FUNCTION SuperTrakExit : BOOL (*Called during EXIT of Cyclic #1*) (*Not used*)
END_FUNCTION
(*Control interface functions*)

FUNCTION SuperTrakProcessControl : BOOL (*Process the control portion of a control interface*) (*True on success, False on failure*)
	VAR_INPUT
		index : UINT; (*Fieldbus interface index (0 - 3)*)
		data : SuperTrakControlInterface_t; (*Control interface data buffers*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakProcessStatus : BOOL (*Process the status and service channel portion of a control interface *) (*True on success, False on failure*)
	VAR_INPUT
		index : UINT; (*Fieldbus interface index (0 - 3)*)
		data : SuperTrakControlInterface_t; (*Control interface data buffers*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakServiceChannel : BOOL (*See also SuperTrakServChanRead/Write and StServiceChannel*) (*True on success, False on failure*)
	VAR_IN_OUT
		sc : ServiceChannel_t; (*Service channel structure*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakServChanRead : UINT (*Reads data from the conveyor*) (*One of the scERR constants*)
	VAR_INPUT
		section : USINT; (*User-assigned section address, or 0 to access system parameters*)
		parameter : UINT; (*Parameter to read*)
		startIndex : UDINT; (*Index of first value to read*)
		count : UINT; (*Count of values to read*)
		pBuffer : UDINT; (*Buffer to accept values*)
		bufferSize : UINT; (*Size of the buffer, in bytes*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakServChanWrite : UINT (*Writes data to the conveyor*) (*One of the scERR constants*)
	VAR_INPUT
		section : USINT; (*User-assigned section address, or 0 to access system parameters*)
		parameter : UINT; (*Parameter to write*)
		startIndex : UDINT; (*Index of first value to write*)
		count : UINT; (*Count of values to write*)
		pData : UDINT; (*Data values to write*)
		dataLength : UINT; (*Size of data to write, in bytes*)
	END_VAR
END_FUNCTION

FUNCTION_BLOCK StServiceChannel (*Exchange data with the conveyor*)
	VAR_INPUT
		Execute : BOOL;
		Task : USINT; (*Use scTASK_**)
		Section : USINT; (*Specify 0 for system parameters*)
		Parameter : UINT; (*Use stPAR_**)
		StartIndex : UDINT;
		Count : UINT; (*Number of elements to read or write*)
		reserved0 : UINT;
		RequestDataLength : UINT; (*Size of request data (in bytes)*)
		ResponseBufferSize : UINT; (*Size of response buffer (in bytes)*)
		pRequestData : UDINT; (*Address of data to be written (specify 0 when reading data)*)
		pResponseBuffer : UDINT; (*Address of buffer for read data (specify 0 when writing data)*)
	END_VAR
	VAR_OUTPUT
		Busy : BOOL;
		Done : BOOL;
		Error : BOOL;
		ErrorID : UINT; (*See scERR_**)
		ResponseDataLength : UINT; (*Actual length of data read*)
	END_VAR
	VAR
		Internal : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION SuperTrakGetControlIfConfig : BOOL
	VAR_INPUT
		index : UINT;
	END_VAR
	VAR_IN_OUT
		config : SuperTrakControlIfConfig_t;
	END_VAR
END_FUNCTION
(*CNC pallet control*)

FUNCTION SuperTrakCncBeginControl : BOOL (*Begin coordinated motion at a target*) (*True on success, False on failure*)
	VAR_INPUT
		instance : UINT; (*CNC instance index (0 - 3)*)
		target : UINT; (*Conveyor target where the pallet is stopped*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakCncUpdateControl : BOOL (*Update coordinated motion at a target*) (*True on success, False on failure*)
	VAR_INPUT
		instance : UINT; (*CNC instance index (0 - 3)*)
		position : DINT; (*Commanded position, in microns, relative to initial position; right is positive*)
		acceleration : REAL; (*Instantaneous commanded acceleration, in mm/s^2*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakCncEndControl : BOOL (*End coordinated motion at a target*) (*True on success, False on failure*)
	VAR_INPUT
		instance : UINT; (*CNC instance index (0 - 3)*)
	END_VAR
END_FUNCTION
(*Advanced pallet control*)

FUNCTION SuperTrakGetPalletInfo : BOOL (*Get pallet position information*) (*True on success, False on failure*)
	VAR_INPUT
		palletInfo : UDINT; (*Pointer to array of SuperTrakPalletInfo_t*)
		count : USINT; (*Size of pallet information array*)
		useSetpointPositions : BOOL; (*TRUE = return setpoint positions, FALSE = return actual positions*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakBeginExternalControl : BOOL (*Begin external control of a pallet*) (*True on success, False on failure*)
	VAR_INPUT
		palletID : UINT; (*Pallet ID of the affected pallet*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakPalletControl : BOOL (*Update external control of a pallet*) (*True on success, False on failure*)
	VAR_INPUT
		palletID : UINT; (*Pallet ID of the affected pallet*)
		setpointSection : UINT; (*User-assigned section where the pallet is commanded to be positioned*)
		setpointPosition : DINT; (*Commanded position on section, in microns*)
		setpointVelocity : REAL; (*Instantaneous commanded velocity, in mm/s = um/ms; positive = right*)
		setpointAccel : REAL; (*Instantaneous commanded acceleration, in m/s^2 = um/ms^2; positive = right accel / left decel*)
	END_VAR
END_FUNCTION
(*Miscellaneous*)

FUNCTION SuperTrakAttachParameter : BOOL (*Configures a service channel parameter that is stored in the application space*)
	VAR_INPUT
		paramNum : UINT; (*Service channel parameter number*)
		varAddress : UDINT; (*Address of the variable*)
		varType : UINT; (*Use scDATA_TYPE constants*)
		count : UDINT; (*Array Length*)
		indexOffset : UDINT; (*Size of array*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakGetDistance : DINT (*Returns the distance between two user-addressed sections and positions*)
	VAR_INPUT
		userStartSection : UINT; (*User-addressed start section*)
		startPosition : DINT; (*Start position*)
		userEndSection : UINT; (*User-addressed end section*)
		endPosition : DINT; (*End Position*)
		inForwardDirection : BOOL; (*If TRUE, distance will be found in the pallet flow direction, If FALSE, distance will be found in the reverse pallet flow direction*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakSimulateMoveTrajectory : UINT (*Simulates pallet movement. This can take a long time to execute!*)
	VAR_INPUT
		moveDistance : DINT; (*Pallet movement distance, in microns*)
		desiredVelocity : INT; (*Desired velocity, in mm/s*)
		desiredAccel : REAL; (*Desired acceleration, in m/s^2*)
		pPositionBuffer : UDINT; (*Address of an array of DINT where position values will be stored*)
		positionBufferCount : UINT; (*Number of elements in the position array*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakGetRelativePosition : BOOL (*Finds the section and position at a specified distance from a specified location.*)
	VAR_INPUT
		section : UINT; (*Section number at starting point*)
		position : DINT; (*Position at starting point*)
		distance : DINT; (*Distance from starting point (positive = right, negative = left)*)
	END_VAR
	VAR_IN_OUT
		resultSection : UINT; (*Section number at ending point*)
		resultPosition : DINT; (*Position at ending point*)
	END_VAR
END_FUNCTION
(*Simulation*)

FUNCTION SuperTrakSimCreatePallet : UINT (*Create a simulated pallet*) (*Handle value for the new simulated pallet*)
	VAR_INPUT
		tagID : USINT; (*IR tag serial number (may be zero if IR tags are not used)*)
		section : UINT; (*Section number where the pallet will be created*)
		position : REAL; (*Position on the section, in millimetres, where the pallet will be created*)
		shelfWidth : REAL; (*Shelf width, in millimetres*)
		shelfOffset : REAL; (*Shelf offset from center, in millimetres*)
		mass : REAL; (*Payload mass, in kilograms*)
	END_VAR
END_FUNCTION

FUNCTION SuperTrakSimDeletePallet : BOOL (*Remove a simulated pallet*) (*True on success, False on failure*)
	VAR_INPUT
		hSimPallet : UINT; (*Handle value for the simulated pallet to be removed*)
	END_VAR
END_FUNCTION
(*I/O hardware support*)

FUNCTION SuperTrakProcessInputs : BOOL
	VAR_INPUT
		pInputs : UDINT; (*Pointer to array of BOOL*)
		inputCount : UINT;
	END_VAR
END_FUNCTION

FUNCTION SuperTrakProcessOutputs : BOOL
	VAR_INPUT
		pOutputs : UDINT; (*Pointer to array of BOOL*)
		outputCount : UINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK StPositionTrigger (*Function block to trigger an X20DS4389 digital output based on a pallet position*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block*) (* *) (*#CYC*)
		Hardware : REFERENCE TO QuadPosTrigHardware_t; (*Variables mapped to hardware*) (* *) (*#PAR*)
		EdgeGenIndex : UINT; (*0 to 3, corresponding to X20DS4389 EdgeGen01 through EdgeGen04*) (* *) (*#PAR*)
		PositionTriggerIndex : UINT; (*Index of position trigger in TrakMaster*) (* *) (*#PAR*)
		MinimumTimeOffset : DINT; (*Shortest time to generate an output: ProgramCycleTime + PowerLinkCycleTime + X2XCycleTime + 200us*) (* *) (*#PAR*)
		MaximumTimeOffset : DINT; (*Longest time to generate an output: MinimumTimeOffset + (ProgramCycleTime x 1.5)*) (* *) (*#PAR*)
	END_VAR
	VAR_OUTPUT
		OutputPulseCount : UDINT; (*Count of output pulses generated*) (* *) (*#PAR*)
		LatePulseCount : UDINT; (*Count of output pulses started late*)
		DroppedPulseCount : UDINT; (*Count of output pulses not generated because they would overlap*)
		HwWarningCount : UDINT; (*Count of hardware warnings acknowledged*) (* *) (*#PAR*)
		HwErrorCount : UDINT; (*Count of hardware errors acknowledged*) (* *) (*#PAR*)
		HardwareError : BOOL; (*If TRUE, check ModuleOK, DeviceName, I/O mappings, and timing parameters*) (* *) (*#PAR*)
		ParameterError : BOOL; (*Indicates that the function block was not configured correctly*) (* *) (*#PAR*)
	END_VAR
	VAR
		Internal : StPositionTriggerInternal_t; (* *) (* *) (*#OMIT*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK StEncoderOutput (*Function block to drive an encoder output based on a pallet position*)
	VAR_INPUT
		Enable : BOOL; (*Enables the function block*)
		Hardware : REFERENCE TO EncoderOutputHardware_t; (*Variables mapped to hardware*) (* *) (*#PAR*)
		EncoderOutputIndex : UINT; (*Index of encoder output in TrakMaster*) (* *) (*#PAR*)
		TimeDelay : DINT; (* *) (* *) (*#PAR*)
	END_VAR
	VAR_OUTPUT
		Error : BOOL; (*Indicates that the function block is in an error state or a command was not executed correctly*)
		MovFifoEmptyCount : DINT; (*Count of MovFifoEmpty errors*) (* *) (*#CYC*)
		MovFifoFullCount : DINT; (*Count of MovFifoFull errors*) (* *) (*#CYC*)
		MovTargetTimeViolationCount : DINT; (*Count of MovTargetTimeViolation errors*) (* *) (*#CYC*)
		MovMaxFrequencyViolationCount : DINT; (*Count of MovMaxFrequencyViolation errors*) (* *) (*#CYC*)
	END_VAR
END_FUNCTION_BLOCK
(*ArEventLog helpers*)

FUNCTION SuperTrakLogWrite : ArEventLogRecordIDType
	VAR_INPUT
		objectID : STRING[36];
		originRecordID : ArEventLogRecordIDType;
		severity : USINT; (*use arEVENTLOG_SEVERITY_**)
		message : STRING[127];
	END_VAR
END_FUNCTION
(*AsArLog helpers (please use ArEventLog instead where possible)*)

FUNCTION SuperTrakLegacyLogWrite : BOOL
	VAR_INPUT
		logLevel : UDINT; (*use arlogLEVEL_* constants*)
		errornr : UDINT; (*status from B&R legacy function block*)
		message : STRING[127];
	END_VAR
END_FUNCTION
(*
=== end SuperTrak standard items ===
*)
