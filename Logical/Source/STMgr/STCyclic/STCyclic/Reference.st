(***************************************************************************************
 * STCyclic task Cyclic Reference actions
 *
 * These Actions can be run only by the STCyclic task and relate to the 
 * SuperTrak cyclic reference variable used by StCom function blocks
 *
 * File: STCyclic/Reference.st
 * Created: 2024-01-12
 *
 * Authors:
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

(* Reference control interface and service channel data *)
ACTION ReferenceCyclicData:
	
	gSTCyclicRef.ControlDataAddress := ADR(ControlData);
	gSTCyclicRef.ControlDataSize := SIZEOF(ControlData);
	gSTCyclicRef.StatusDataAddress := ADR(StatusData);
	gSTCyclicRef.StatusDataSize := SIZEOF(StatusData);
	gSTCyclicRef.RequestDataAddress := ADR(RequestData);
	gSTCyclicRef.RequestDataSize := SIZEOF(RequestData);
	gSTCyclicRef.ResponseDataAddress := ADR(ResponseData);
	gSTCyclicRef.ResponseDataSize := SIZEOF(ResponseData);
	
END_ACTION
