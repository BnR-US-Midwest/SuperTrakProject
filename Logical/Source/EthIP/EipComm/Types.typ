(***************************************************************************************
 * EipComm task local types and enumerations
 *
 * These datatypes and enums are local to the EipComm task and are used for
 * EtherNet/IP communication
 *
 * File: EipComm/Types.typ
 * Created: 2025-03-11
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

TYPE
	EipComm_type : 	STRUCT  (*Ethernet IP Communication program interface*)
		Command : EipComm_Cmd_type; (*Ethernet IP Communication program commands*)
		Parameter : EipComm_Par_type; (*Ethernet IP Communication program parameters*)
		Status : EipComm_Status_type; (*Ethernet IP Communication program statuses*)
	END_STRUCT;
	EipComm_Cmd_type : 	STRUCT  (*Ethernet IP Communication program commands*)
		Run : BOOL; (*When TRUE, communication will happen. When FALSE, it will not*)
		ErrorReset : BOOL; (*Reset errors if in the ERROR state*)
	END_STRUCT;
	EipComm_Par_type : 	STRUCT  (*Ethernet IP Communication program parameters*)
		InitHandle : UDINT; (*Handle provided by EIPInit*)
	END_STRUCT;
	EipComm_Status_type : 	STRUCT  (*Ethernet IP Communication program statuses*)
		InitExitStatus : STRING[80]; (*Exit STatus provided by EIPInit. Contains error information*)
	END_STRUCT;
	CommState_enum : 
		( (*State of the communication program*)
		COMM_STATE_OFF, (*Communication is inactive*)
		COMM_STATE_ON, (*Communication is active*)
		COMM_STATE_ERROR (*There is an error. Communication is inactive*)
		);
END_TYPE
