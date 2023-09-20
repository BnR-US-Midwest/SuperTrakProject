
PROGRAM _INIT
	
	SystemParameters.NrOfCommands := 24;
	SystemParameters.NrOfSections := 4;
	SystemParameters.NrOfTargets := 4;
	SystemParameters.NrOfPallets := 4;
	
	ControlSystem.Enable := TRUE;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	ControlSystem.EnableAllSections := Interface.Cmd.EnableAllSections;
	ControlSystem.ErrorReset := Interface.Cmd.Reset;
	
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
	
	Interface.Status.Active := ControlSystem.Active;
	Interface.Status.Error := ControlSystem.Error;
	
	LogStControlActive;
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
