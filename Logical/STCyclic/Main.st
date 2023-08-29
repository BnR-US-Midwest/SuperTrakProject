
PROGRAM _INIT
	
	SuperTrakInit('/DEVICE=USER_PATH\SuperTrak\Configuration', '127.0.0.1', 'IF3,IF4');
	
END_PROGRAM

PROGRAM _CYCLIC
	
	SuperTrakCyclic1();
	
END_PROGRAM

PROGRAM _EXIT
	
	SuperTrakExit();
	
END_PROGRAM

