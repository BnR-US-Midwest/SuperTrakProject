(***************************************************************************************
 * STSystem task Section actions
 *
 * These Actions can be run only by the STSystem task and relate to 
 * individual Section control and feedback.
 *
 * File: STSystem/Sections.st
 * Created: 2024-01-12
 *
 * Authors:
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

(* Collect section enable statuses *)
ACTION CollectSectionStatuses:
	
	Interface.Info.SectionsEnabled := ControlSystem.SectionsEnabled;
	
	IF ControlSystem.Active = FALSE THEN
		Interface.Info.SectionsDisabled := FALSE;
		RETURN;
	END_IF
	
	// Read PLC interface configuration (counts and offsets)
	SuperTrakGetControlIfConfig(0, PLCInterfaceConfiguration);
	IF PLCInterfaceConfiguration.sectionCount = 0 THEN
		RETURN;
	END_IF
	
	// Assume true
	Interface.Info.SectionsDisabled := TRUE;
	// Loop through every configured section
	FOR Index := 0 TO PLCInterfaceConfiguration.sectionCount - 1 DO
		SectionStatus ACCESS ControlSystem.StStatData + PLCInterfaceConfiguration.sectionStatusOffset + Index;
		// Test bit 0 if section is enabled
		IF BIT_TST(SectionStatus, 0) THEN
			Interface.Info.SectionsDisabled := FALSE;
		END_IF
	END_FOR
	
END_ACTION
