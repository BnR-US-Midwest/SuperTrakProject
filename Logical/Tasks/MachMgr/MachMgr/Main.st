
PROGRAM _INIT
	
	// Assign section number to each element
	FOR Index := 1 TO ST_SECTION_MAX DO
		gSTSection[Index].Par.Section := Index;
	END_FOR
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Enable section function blocks when the system function block is active
	FOR Index := 1 TO ST_SECTION_MAX DO
		gSTSection[Index].Cmd.Enable := gSTSystem.Status.Active;
	END_FOR
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM

