
PROGRAM _INIT
	
	SystemParameters.NrOfCommands := 24;
	SystemParameters.NrOfSections := 4;
	SystemParameters.NrOfTargets := 4;
	SystemParameters.NrOfPallets := 4;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Read global inputs
	Interface.Cmd := gSTSystem.Cmd;
	
	// State control
	CASE State OF
		STATE_OFF:
			IF StartTrigger.Q THEN
				State := STATE_INITIALIZE;
			END_IF
			
		STATE_INITIALIZE:
			// Enable once and never disabled
			ControlSystem.Enable := TRUE;
			
			IF ControlSystem.Active THEN
				State := STATE_IDLE;
				
			ELSIF ControlSystem.Error THEN
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
			END_IF
			
		STATE_IDLE:
			IF RunTrigger.Q THEN
				State := STATE_STARTING;
				
			ELSIF ControlSystem.Error THEN
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
			END_IF
		
		STATE_STARTING:
			ControlSystem.EnableAllSections := TRUE;
			
			IF ControlSystem.SectionsEnabled THEN
				State := STATE_EXECUTE;
				
			ELSIF ControlSystem.Error THEN
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
			END_IF
			
		STATE_EXECUTE:
			IF Interface.Cmd.Stop THEN
				State := STATE_STOPPING;
			
			ELSIF ControlSystem.Error THEN
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
			END_IF
			
		STATE_STOPPING:
			ControlSystem.EnableAllSections := FALSE;
			
			IF Interface.Info.SectionsDisabled THEN
				State := STATE_IDLE;
				
			ELSIF ControlSystem.Error THEN
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
			END_IF
			
		STATE_ERROR:
			IF ResetTrigger.Q THEN
				State := STATE_CLEARING;
			END_IF
			
		STATE_CLEARING:
			ControlSystem.ErrorReset := TRUE;
			
			IF ControlSystem.Error = FALSE THEN
				ControlSystem.ErrorReset := FALSE;
				Interface.Status.Error := FALSE;
				Interface.Status.ErrorID := 0;
				State := STATE_OFF;
			END_IF
	END_CASE
	
	// Call function blocks
	ControlSystem.StCtrlData := gSTCyclicReference.ControlDataAddress;
	ControlSystem.StCtrlDataSize := gSTCyclicReference.ControlDataSize;
	ControlSystem.StStatData := gSTCyclicReference.StatusDataAddress;
	ControlSystem.StStatDataSize := gSTCyclicReference.StatusDataSize;
	ControlSystem.StServChRequestData := gSTCyclicReference.RequestDataAddress;
	ControlSystem.StServChRequestDataSize := gSTCyclicReference.RequestDataSize;
	ControlSystem.StServChResponseData := gSTCyclicReference.ResponseDataAddress;
	ControlSystem.StServChResponseDataSize := gSTCyclicReference.ResponseDataSize;
	ControlSystem.StLink := ADR(gSTSystemLink);
	ControlSystem.Parameters := ADR(SystemParameters);
	ControlSystem();
	
	StartTrigger.CLK := Interface.Cmd.Start;
	StartTrigger();
	RunTrigger.CLK := Interface.Cmd.Run;
	RunTrigger();
	ResetTrigger.CLK := Interface.Cmd.Reset;
	ResetTrigger();
	
	// Process outputs
	CollectSectionStatuses;
	Interface.Info.WarningPresent := ControlSystem.Info.SuperTrak.SystemWarningActive;
	Interface.Info.Warnings := ControlSystem.Info.SuperTrak.SystemWarningBits;
	Interface.Info.FaultPresent := ControlSystem.Info.SuperTrak.SystemFaultActive;
	Interface.Info.Faults := ControlSystem.Info.SuperTrak.SystemFaultBits;
	
	// Write global outputs
	gSTSystem.Status := Interface.Status;
	gSTSystem.Info := Interface.Info;
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
