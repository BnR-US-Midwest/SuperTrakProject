
PROGRAM _INIT
	
	TriggerSection := 3;
	TriggerPosition := 800_000;
	
	SelectPalletIndex := 0;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	CASE State OF
		0:
			IF CreateFaultTrigger.Q THEN
				State := 10;
			END_IF
			
		10:
			IF SelectPalletIndex >= PALLET_MAX AND PALLET_MAX > 0 THEN
				SelectPalletIndex := PALLET_MAX - 1;
			END_IF
			
			SuperTrakGetPalletInfo(ADR(PalletInfo), PALLET_MAX, FALSE);
			PreviousPalletPosition := PalletInfo[SelectPalletIndex].position;
			
			State := 20;
			
		20:
			SuperTrakGetPalletInfo(ADR(PalletInfo), PALLET_MAX, FALSE);
			
			IF CreateFault = FALSE THEN
				State := 0;
				
			ELSIF PalletInfo[SelectPalletIndex].section = TriggerSection AND
				PalletInfo[SelectPalletIndex].position >= TriggerPosition AND 
				PreviousPalletPosition < TriggerPosition THEN
					
				State := 30;
			END_IF
			PreviousPalletPosition := PalletInfo[SelectPalletIndex].position;
			
		30:
			SuperTrakBeginExternalControl(PalletInfo[SelectPalletIndex].palletID);
				
			SuperTrakPalletControl(PalletInfo[SelectPalletIndex].palletID, 1, 0, 0.0, 0.0);
			
			State := 40;
			
		40:
			State := 0;
	END_CASE
	
	CreateFaultTrigger.CLK := CreateFault;
	CreateFaultTrigger();
	
END_PROGRAM

PROGRAM _EXIT
	
END_PROGRAM

