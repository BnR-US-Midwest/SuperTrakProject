
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
