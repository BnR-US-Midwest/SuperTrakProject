(***************************************************************************************
 * Global SuperTrak data types
 *
 * These structures allow any program (task) to interface with the SuperTrak (ST) tasks
 *
 * File: SuperTrak.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
****************************************************************************************)
TYPE
	SuperTrak_type : 	STRUCT  (*Main SuperTrak command/parameter/status structure*)
		System : STSystemInterfaceType; (*SuperTrak System interface*)
		Sections : STSectionInterfaceType; (*SuperTrak Section interface*)
		Target : ARRAY[1..ST_TARGET_MAX]OF STTargetInterfaceType; (*SuperTrak Targets interface*)
		Shuttle : ARRAY[1..ST_SHUTTLE_MAX]OF STShuttleInterfaceType; (*SuperTrak Shuttles interface*)
	END_STRUCT;
	STReleaseCommandType : 	STRUCT  (*Release (target and shuttle) command structure*)
		ReleaseToTarget : BOOL; (*Release shuttle to target. Configure destination, direction, velocity, and acceleration.*)
		ReleaseToOffset : BOOL; (*Release shuttle to target with a configured offset. Configure destination, direction, velocity, acceleration, and offset.*)
		IncrementOffset : BOOL; (*Increment the shuttle offset. Configure velocity, acceleration, and incremental distance.*)
	END_STRUCT;
	STReleaseParameterType : 	STRUCT  (*Release (target and shuttle) parameter structure*)
		Velocity : REAL; (*[mm/s] Set velocity of release movement*)
		Acceleration : REAL; (*[mm/s^2] Set acceleration of release movement*)
		Direction : UINT; (*Direction of release movement 0: left (CW) 1: right (CCW)*)
		DestinationTarget : USINT := 1; (*1..254 Destination target, target configured in TrackMaster, 255 identified for expert mode*)
		TargetOffset : REAL; (*[mm] Absolute position offset relative to destination target*)
		IncrementalOffset : REAL; (*[mm] Increment current accumulated offset of current destination target*)
	END_STRUCT;
END_TYPE
