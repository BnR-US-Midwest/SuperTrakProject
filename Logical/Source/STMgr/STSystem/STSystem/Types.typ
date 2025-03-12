(***************************************************************************************
 * STSystem task local data types
 *
 * These structures and enumerations are local to the STSystem task
 *
 * File: STSystem/Types.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

TYPE
	StateEnum : 
		( (*Program state*)
		STATE_INITIALIZE, (*Enable StControl function block*)
		STATE_IDLE, (*No action, wait for run*)
		STATE_STARTING, (*Enable all sections*)
		STATE_EXECUTE, (*Running, wait for stop*)
		STATE_STOPPING, (*Disable all sections*)
		STATE_ERROR, (*An error occurred*)
		STATE_CLEARING (*Reset error*)
		);
END_TYPE
