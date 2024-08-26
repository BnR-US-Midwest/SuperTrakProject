(***************************************************************************************
 * Global STCyclic data types
 *
 * These SuperTrak Cyclic program structures must be accessed by other tasks
 *
 * File: STCyclic.typ
 * Created: 2024-01-12
 *
 * Authors:
 *  Tyler Matijevich, B&R Industrial Automation
 *
****************************************************************************************)

TYPE
	STCyclicRefType : 	STRUCT  (*SuperTrak cyclically referenced data*)
		ControlDataAddress : UDINT; (*Pointer to array of USINT*)
		ControlDataSize : UDINT; (*[bytes] Size of Control Data array*)
		StatusDataAddress : UDINT; (*Pointer to array of USINT*)
		StatusDataSize : UDINT; (*[bytes] Size of Status Data array*)
		RequestDataAddress : UDINT; (*Pointer to array of USINT for service channel request data *)
		RequestDataSize : UDINT; (*[bytes] Size of Request Data array*)
		ResponseDataAddress : UDINT; (*Pointer to array of USINT for service channel response data *)
		ResponseDataSize : UDINT; (*[bytes] Size of Response Data array*)
	END_STRUCT;
END_TYPE
