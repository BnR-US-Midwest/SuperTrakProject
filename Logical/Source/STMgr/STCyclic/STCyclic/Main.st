(***************************************************************************************
 * STCyclic task
 *
 * This task calls all of the functions cyclically necessary to run a SuperTrak
 * IMPORTANT: This task must be called in Cyclic #1. Cycle time: 800us, Tolerance: 0us.
 * THIS IS A REQUIREMENT TO USE SUPERTRAK.
 *
 * To change the location of the SuperTrak configuration (.dat) files, modify
 * the path used by the SuperTrakInit function in the INIT program.
 *
 * File: STCyclic.st
 * Created: 2024-01-12
 *
 * Authors:
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

PROGRAM _INIT
	
	// Initialize SuperTrak, set configuration path
	SuperTrakInit('/DEVICE=USER_PATH\SuperTrak\Configuration', '127.0.0.1', 'IF3,IF4');
	
	InitializeControlInterface;
    InitializeServiceChannel;
    
    DeConfigureAllowSectionEnableInputs;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Data addresses for PLC control interface
	AddressControlInterface;
	
	// StCom input data
	SuperTrakProcessControl(0, InterfaceParameters);
	
	// SuperTrak cyclic update
	SuperTrakCyclic1();
	
	// StCom output data
	SuperTrakProcessStatus(0, InterfaceParameters);
	
	// StCom configuration
	ProcessServiceChannel;
	
	// StCom reference
	ReferenceCyclicData;
	
END_PROGRAM

PROGRAM _EXIT
	
	SuperTrakExit();
	
END_PROGRAM
