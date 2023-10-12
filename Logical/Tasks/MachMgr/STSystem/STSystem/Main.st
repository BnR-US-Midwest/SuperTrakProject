
PROGRAM _INIT
	
	SystemParameters.NrOfCommands := 24;
	SystemParameters.NrOfSections := 4;
	SystemParameters.NrOfTargets := 4;
	SystemParameters.NrOfPallets := 4;
	
	Timeout.PT := T#5s;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Process inputs
	Warning := ControlSystem.StatusID <> 0 AND ControlSystem.Error = FALSE;
	
	// State control
	CASE State OF
		STATE_OFF:
			IF Interface.Cmd.Stop THEN 
				State := STATE_STOPPED;
				
			ELSIF StartTrigger.Q THEN
				State := STATE_ENABLING;
				
			ELSIF Warning THEN
				ControlSystem.ErrorReset := ResetTrigger.Q;
			END_IF
			
		STATE_ENABLING:
			// Enable once and never disabled
			ControlSystem.Enable := TRUE;
			Timeout.IN := TRUE;
			
			IF ControlSystem.Active THEN
				Timeout.IN := FALSE;
				Interface.Status.Ready := TRUE;
				State := STATE_IDLE;
				
			ELSIF ControlSystem.Error THEN
				Timeout.IN := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
				
			ELSIF Timeout.Q THEN
				Timeout.IN := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := -1;
				State := STATE_ERROR;
			END_IF
			
		STATE_IDLE:
			IF Interface.Cmd.Stop THEN
				Interface.Status.Ready := FALSE;
				State := STATE_STOPPED;
				
			ELSIF RunTrigger.Q THEN
				State := STATE_RUNNING;
				
			ELSIF Warning THEN
				ControlSystem.ErrorReset := ResetTrigger.Q;
			END_IF
		
		STATE_RUNNING:
			// SuperTrak commands
			ControlSystem.EnableAllSections := TRUE;
			Interface.Status.Running := ControlSystem.SectionsEnabled;
			Timeout.IN := Interface.Status.Running = FALSE;
			
			IF Interface.Cmd.Stop THEN
				ControlSystem.EnableAllSections := FALSE;
				Interface.Status.Ready := FALSE;
				Interface.Status.Running := FALSE;
				State := STATE_STOPPED;
				
			// Function block or SuperTrak system error
			ELSIF ControlSystem.Error THEN
				ControlSystem.EnableAllSections := FALSE;
				Interface.Status.Ready := FALSE;
				Interface.Status.Running := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
				
			ELSIF Warning THEN
				ControlSystem.ErrorReset := ResetTrigger.Q;
				
			ELSIF Timeout.Q THEN
				ControlSystem.EnableAllSections := FALSE;
				Interface.Status.Ready := FALSE;
				Interface.Status.Running := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := -1;
				State := STATE_ERROR;
			END_IF
			
		STATE_STOPPED:
			Interface.Status.Stopped := TRUE;
			
			IF Interface.Cmd.Stop = FALSE THEN
				Interface.Status.Stopped := FALSE;
				State := STATE_OFF;
			
			ELSIF ControlSystem.Error THEN
				Interface.Status.Stopped := FALSE;
				Interface.Status.Error := TRUE;
				Interface.Status.ErrorID := ControlSystem.StatusID;
				State := STATE_ERROR;
				
			ELSIF Warning THEN
				ControlSystem.ErrorReset := ResetTrigger.Q;
			END_IF
			
		STATE_ERROR:
			IF ResetTrigger.Q THEN
				State := STATE_RESETTING;
			END_IF
			
		STATE_RESETTING:
			ControlSystem.ErrorReset := TRUE;
			Timeout.IN := TRUE;
			
			IF ControlSystem.Error = FALSE THEN
				ControlSystem.ErrorReset := FALSE;
				Timeout.IN := FALSE;
				Interface.Status.Error := FALSE;
				Interface.Status.ErrorID := 0;
				State := STATE_OFF;
				
			ELSIF Timeout.Q THEN
				ControlSystem.ErrorReset := FALSE;
				Timeout.IN := FALSE;
				// Record new error number
				IF ControlSystem.StatusID <> Interface.Status.ErrorID THEN
					Interface.Status.ErrorID := ControlSystem.StatusID;
				ELSE
					Interface.Status.ErrorID := -1;
				END_IF
				State := STATE_ERROR;
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
	
	Timeout();
	
	// Process outputs
	Interface.Status.WarningPresent := ControlSystem.Info.SuperTrak.SystemWarningActive;
	Interface.Status.Warnings := ControlSystem.Info.SuperTrak.SystemWarningBits;
	Interface.Status.FaultPresent := ControlSystem.Info.SuperTrak.SystemFaultActive;
	Interface.Status.Faults := ControlSystem.Info.SuperTrak.SystemFaultBits;
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
