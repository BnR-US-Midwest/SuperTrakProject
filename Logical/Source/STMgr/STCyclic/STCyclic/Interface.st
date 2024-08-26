(***************************************************************************************
 * STCyclic task Interface actions
 *
 * These Actions can be run only by the STCyclic task and relate to the 
 * SuperTrak Control and Status interfaces
 *
 * File: STCyclic/Interface.st
 * Created: 2024-01-12
 *
 * Authors:
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

(* Assign revision, connection type, and size of control interface data *)
ACTION InitializeControlInterface:
	
	// Revision 0 required by StCom
	ControlInterfaceRevision := 0;
	SuperTrakServChanWrite(0, stPAR_PLC_IF_REVISION, 0, 1,
		ADR(ControlInterfaceRevision), SIZEOF(ControlInterfaceRevision));
	
	// Parameters used in SuperTrak ProcessControl and ProcessStatus functions
	InterfaceParameters.connectionType := stCONNECTION_LOCAL;
	InterfaceParameters.controlSize := SIZEOF(ControlData);
	InterfaceParameters.statusSize := SIZEOF(StatusData);
	
END_ACTION

(* Assign addresses of control interface data *)
ACTION AddressControlInterface:
	
	// Parameters used in SuperTrak ProcessControl and ProcessStatus functions
    InterfaceParameters.pControl := ADR(ControlData);
    InterfaceParameters.pStatus := ADR(StatusData);
	
END_ACTION
