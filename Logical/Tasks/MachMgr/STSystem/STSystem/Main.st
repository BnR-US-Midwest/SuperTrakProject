
PROGRAM _INIT
	
	SystemParameters.NrOfCommands := 24;
	SystemParameters.NrOfSections := 4;
	SystemParameters.NrOfTargets := 4;
	SystemParameters.NrOfPallets := 4;
	
	Timeout.PT := T#5s;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// State control
	CASE State OF
		STSYSTEM_STATE_OFF:
			// Enable interface
			IF Interface.Cmd.Enable THEN
				State := STSYSTEM_STATE_ENABLING;
			END_IF
			
		STSYSTEM_STATE_ENABLING:
			// Enable once and never disabled
			ControlSystem.Enable := TRUE;
			Timeout.IN := TRUE;
			
			IF ControlSystem.Active THEN
				Timeout.IN := FALSE;
				Interface.Status.Active := TRUE;
				State := STSYSTEM_STATE_RUN;
				
			ELSIF ControlSystem.Error THEN
				Timeout.IN := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STSYSTEM_STATE_ERROR;
				
			ELSIF Timeout.Q THEN
				Timeout.IN := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := -1;
				State := STSYSTEM_STATE_ERROR;
				
			END_IF
		
		STSYSTEM_STATE_RUN:
			// SuperTrak commands
			ControlSystem.EnableAllSections := Interface.Cmd.EnableAllSections;
			
			// Disabled interface
			IF Interface.Cmd.Enable = FALSE THEN
				ControlSystem.EnableAllSections := FALSE;
				Interface.Status.Active := FALSE;
				State := STSYSTEM_STATE_OFF;
				
			// Function block or SuperTrak system error
			ELSIF ControlSystem.Error THEN
				ControlSystem.EnableAllSections := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STSYSTEM_STATE_ERROR;
			END_IF
			
		STSYSTEM_STATE_ERROR:
			// Disable interface
			IF Interface.Cmd.Enable = FALSE THEN
				Interface.Status.Active := FALSE;
				Interface.Status.Error := FALSE;
				Interface.Status.ErrorID := 0;
				State := STSYSTEM_STATE_OFF;
				
			// Reset error with positive edge
			ELSIF ResetPosEdge.Q THEN
				State := STSYSTEM_STATE_RESETTING;
			END_IF
			
		STSYSTEM_STATE_RESETTING:
			ControlSystem.ErrorReset := TRUE;
			Timeout.IN := TRUE;
			
			IF ControlSystem.Error = FALSE THEN
				ControlSystem.ErrorReset := FALSE;
				Timeout.IN := FALSE;
				Interface.Status.Error := FALSE;
				Interface.Status.ErrorID := 0;
				State := STSYSTEM_STATE_OFF;
				
			ELSIF Timeout.Q THEN
				ControlSystem.ErrorReset := FALSE;
				Timeout.IN := FALSE;
				// Record new error number
				IF ControlSystem.StatusID <> Interface.Status.ErrorID THEN
					Interface.Status.ErrorID := ControlSystem.StatusID;
				ELSE
					Interface.Status.ErrorID := -1;
				END_IF
				State := STSYSTEM_STATE_ERROR;
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
	
	ResetPosEdge.CLK := Interface.Cmd.Reset;
	ResetPosEdge();
	
	Timeout();
	
	// Share status info
	Interface.Status.State := State;
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
