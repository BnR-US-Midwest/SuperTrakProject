(***************************************************************************************
 * Global Machine data types
 *
 * These structures allow any program (task) to interface with the Main Machine task
 *
 * File: Machine.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
****************************************************************************************)
TYPE
	Machine_type : 	STRUCT  (*Machine interface*)
		Cmd : Machine_Cmd_type; (*Machine commands*)
		Par : Machine_Par_type; (*Machine parameters*)
		Status : Machine_Status_type; (*Machine statuses*)
	END_STRUCT;
	Machine_Cmd_type : 	STRUCT  (*Machine commands*)
		Enable : BOOL; (*Enable all SuperTrak sections*)
		Run : BOOL; (*Run process sequence*)
		ErrorReset : BOOL; (*Error reset*)
	END_STRUCT;
	Machine_Par_type : 	STRUCT  (*Machine parameters*)
		Velocity : REAL := 1500.0; (*[mm/s] Set velocity for target and shuttle release commands*)
		Acceleration : REAL := 15000.0; (*[mm/s^2] Set acceleration for target and shuttle release commands*)
	END_STRUCT;
	Machine_Status_type : 	STRUCT  (*Machine statuses*)
		Enabled : BOOL; (*The main state machine is enabled and the trak is powered*)
		Ready : BOOL; (*The program is ready to run*)
		Error : BOOL; (*There is an active error present*)
	END_STRUCT;
END_TYPE
