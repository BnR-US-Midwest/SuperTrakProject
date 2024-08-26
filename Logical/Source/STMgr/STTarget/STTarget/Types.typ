(***************************************************************************************
 * STTarget task local data types
 *
 * These structures and enumerations are local to the STTarget task
 *
 * File: STTarget/Types.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)
TYPE
	TargetControlState_enum : 
		( (*Shuttle release state machine*)
		TARGET_STATE_WAIT_FOR_SHUTTLE, (*Wait for a shuttle to arrive at the target*)
		TARGET_STATE_SHUTTLE_PRESENT, (*A shuttle is at the target and ready for commands*)
		TARGET_STATE_SET_SHUTTLE_ID, (*Set the ID of the shuttle that is currently at the target*)
		TARGET_STATE_SET_MOTION_PARS, (*Set the shutte at target's motion parameters*)
		TARGET_STATE_RELEASE_SHUTTLE, (*Release the shuttle currently at the target*)
		TARGET_STATE_WAIT_FOR_RELEASE, (*Wait for the release to complete*)
		TARGET_STATE_WAIT_FOR_CMD_RESET (*Wait for the caller to reset all commands*)
		);
END_TYPE
