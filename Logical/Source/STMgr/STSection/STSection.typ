(***************************************************************************************
 * Global STSection data types
 *
 * These structures allow any program (task) to interface with the STSection task
 *
 * File: STSection.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *  Tyler Matijevich, B&R Industrial Automation
 *
****************************************************************************************)

TYPE
	STSectionInterfaceType : 	STRUCT  (*Section control interface*)
		Cmd : STSectionInterfaceCmdType; (*Section commands*)
		Status : STSectionInterfaceStatusType; (*Section statuses*)
		Info : ARRAY[1..ST_SECTION_MAX]OF STSectionInterfaceInfoType; (*Information about each individual section*)
	END_STRUCT;
	STSectionInterfaceCmdType : 	STRUCT  (*Section commands*)
		PowerSection : ARRAY[1..ST_SECTION_MAX]OF BOOL; (*Enable individual sections*)
		Reset : BOOL; (*Error Reset for all sections*)
	END_STRUCT;
	STSectionInterfaceStatusType : 	STRUCT  (*Section statuses*)
		Active : BOOL; (*All section control function blocks are Active*)
		Error : BOOL; (*At least one section function block is reporting an Error*)
		StatusID : DINT; (*StatusID of section function block reporting an error*)
		SectionError : BOOL; (*At least one section has an active error*)
		SectionWarning : BOOL; (*At least one section has an active warning*)
	END_STRUCT;
	STSectionInterfaceInfoType : 	STRUCT  (*Information about each individual section*)
		SectionEnabled : BOOL; (*Sections that are Enabled have a TRUE value in this array*)
		UnrecognizedShuttles : BOOL; (*Detected one or more shuttles with undetermined position, jogged to locate when enabled*)
		MotorPowerOn : BOOL; (*Voltage within usage range*)
		ShuttlesRecovering : BOOL; (*Shuttles must be returned to last controlled position and/or making their initial move to load target*)
		LocatingShuttles : BOOL; (*Shuttles are automatically jogged to locate*)
		DisabledExternally : BOOL; (*Disabled due to external condition, see digital inputs*)
		WarningPresent : BOOL; (*One or more warning messages have been recorded*)
		Warnings : UDINT; (*Warning bit(s) active*)
		FaultPresent : BOOL; (*One or more fault messages have been recorded*)
		Faults : UDINT; (*Fault bit(s) active*)
	END_STRUCT;
END_TYPE
