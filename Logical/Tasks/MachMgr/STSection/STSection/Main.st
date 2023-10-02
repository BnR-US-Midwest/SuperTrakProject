
PROGRAM _INIT
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Initialize common statuses, assume true/false then disqualify
	Interface.Status.Active := TRUE;
	Interface.Status.Error := FALSE;
	
	FOR Index := 1 TO ST_SECTION_MAX DO
		ControlSection[Index].StLink := ADR(gSTSystemLink);
		ControlSection[Index].Section := Interface.Par.Section[Index];
		// There are no function block parameters, use common address
		ControlSection[Index].Parameters := ADR(SectionParameters);
		// Enable all function blocks
		ControlSection[Index].Enable := Interface.Cmd.Enable;
		// Enable each section
		ControlSection[Index].EnableSection := Interface.Cmd.EnableSection[Index];
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
		END_IF
		Interface.Status.SectionEnabled[Index] := ControlSection[Index].SectionEnabled;
	END_FOR
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
