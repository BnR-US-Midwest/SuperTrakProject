(***************************************************************************************
 * STShuttle task local data types
 *
 * These structures and enumerations are local to the STShuttle task
 *
 * File: STShuttle/Types.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)
TYPE
	ShuttleControlState_enum : 
		( (*State machine for Shuttle control*)
		SHUTTLE_STATE_WAIT_FOR_COMMAND, (*Wait for a command*)
		SHUTTLE_STATE_SET_MOTION_PARS, (*Set the shuttle's velocity and acceleration*)
		SHUTTLE_STATE_RELEASE_SHUTTLE, (*Give the shuttle a release command*)
		SHUTTLE_STATE_WAIT_FOR_CMD_RESET (*Wait for interface commands to be reset by the caller*)
		);
END_TYPE
