
PROGRAM _INIT
	
END_PROGRAM

PROGRAM _CYCLIC
    
    // Read global inputs
    Interface.Cmd := gSuperTrak.Sections.Cmd;
    
	// Initialize common statuses, assume true/false then disqualify
	Interface.Status.Active := TRUE;
	Interface.Status.Error := FALSE;
	
	FOR Index := 1 TO ST_SECTION_MAX DO
		ControlSection[Index].StLink := ADR(gSTSystemLink);
		ControlSection[Index].Section := Index;
		// There are no function block parameters, use common address
		ControlSection[Index].Parameters := ADR(SectionParameters);
		// Enable all function blocks
		ControlSection[Index].Enable := Interface.Cmd.Enable;
		// Enable each section
		ControlSection[Index].EnableSection := Interface.Cmd.EnableSection[Index] AND ControlSection[Index].MotorPowerOn AND NOT ControlSection[Index].Error;
		// Reset all function blocks
		ControlSection[Index].ErrorReset := Interface.Cmd.Reset;
		ControlSection[Index]();
		
		// All sections must be active
		IF ControlSection[Index].Active = FALSE THEN
			Interface.Status.Active := FALSE;
		END_IF
		// Error if any section has error
		IF ControlSection[Index].Error THEN
            Interface.Status.Error := TRUE;
            Interface.Status.StatusID := ControlSection[Index].StatusID;
        END_IF
        
        // Read other statuses
        Interface.Status.SectionStatus[Index].SectionEnabled := ControlSection[Index].SectionEnabled;
        Interface.Status.SectionStatus[Index].UnrecognizedShuttles := ControlSection[Index].UnrecognizedPallets;
        Interface.Status.SectionStatus[Index].MotorPowerOn := ControlSection[Index].MotorPowerOn;
        Interface.Status.SectionStatus[Index].ShuttlesRecovering := ControlSection[Index].PalletsRecovering;
        Interface.Status.SectionStatus[Index].LocatingShuttles := ControlSection[Index].LocatingPallets;
        Interface.Status.SectionStatus[Index].DisabledExternally := ControlSection[Index].DisabledExternally;
        Interface.Status.SectionStatus[Index].WarningPresent := ControlSection[Index].Info.SuperTrak.SectionWarningActive;
        Interface.Status.SectionStatus[Index].Warnings := ControlSection[Index].Info.SuperTrak.SectionWarningBits;
        Interface.Status.SectionStatus[Index].FaultPresent := ControlSection[Index].Info.SuperTrak.SectionFaultActive;
        Interface.Status.SectionStatus[Index].Faults := ControlSection[Index].Info.SuperTrak.SectionFaultBits;
    END_FOR
    
    // Write global outputs
    gSuperTrak.Sections.Status := Interface.Status;
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
