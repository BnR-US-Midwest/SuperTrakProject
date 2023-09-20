
PROGRAM _INIT
	
END_PROGRAM

PROGRAM _CYCLIC
	
	FOR Index := 1 TO ST_SECTION_MAX DO
		ControlSection[Index].StLink := ADR(gSTSystemLink);
		ControlSection[Index].Section := Interface[Index].Par.Section;
		ControlSection[Index].Parameters := ADR(SectionParameters);
		ControlSection[Index].Enable := Interface[Index].Cmd.Enable;
		ControlSection[Index].EnableSection := Interface[Index].Cmd.EnableSection;
		ControlSection[Index].ErrorReset := Interface[Index].Cmd.Reset;
		ControlSection[Index]();
		
		Interface[Index].Status.Active := ControlSection[Index].Active;
		Interface[Index].Status.Error := ControlSection[Index].Error;
	END_FOR
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
