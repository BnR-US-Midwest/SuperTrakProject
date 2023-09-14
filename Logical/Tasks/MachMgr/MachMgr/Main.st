
PROGRAM _INIT
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Share references from SuperTrak cyclic to StCom's system control
	gSTSystem.Par.Reference := gSTCyclic.Status.Reference;
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM
