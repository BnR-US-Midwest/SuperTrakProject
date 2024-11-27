(***************************************************************************************
 * Main task local data types
 *
 * These structures and enumerations are local to the Main task
 *
 * File: Main/Types.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

TYPE
	MainState_enum : 
		( (*Program state*)
		MAIN_STATE_OFF, (*SuperTrak control is disabled*)
		MAIN_STATE_DISABLED, (*SuperTrak control is enabled, but the trak itself is disabled*)
		MAIN_STATE_ENABLE_SECTIONS, (*SuperTrak sections are enabling and powering up*)
		MAIN_STATE_RECOVER, (*Shuttles are recovering*)
		MAIN_STATE_READY, (*Trak is ready to run the main process*)
		MAIN_STATE_RUN, (*Trak is running the main process*)
		MAIN_STATE_STOP, (*Trak is stopping*)
		MAIN_STATE_DISABLING, (*Trak is disabling all sections*)
		MAIN_STATE_ERROR (*There is an active error*)
		);
END_TYPE
