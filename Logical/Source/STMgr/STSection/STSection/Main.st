(***************************************************************************************
 * STSection task
 *
 * This task provides a state machine for controlling and monitoring 
 * SuperTrak Sections. This task can be interfaced with via gSuperTrak.Sections
 *
 * File: STSection.st
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

PROGRAM _CYCLIC
    
    // Read global inputs
    Interface.Cmd := gSuperTrak.Sections.Cmd;
    
    // Initialize common statuses, assume true/false then disqualify
    Interface.Status.Active := TRUE;
    Interface.Status.Error := FALSE;
	Interface.Status.SectionError := 0;
	Interface.Status.SectionWarning := 0;
	
    FOR Index := 1 TO ST_SECTION_MAX DO
        ControlSection[Index].StLink := ADR(gSTSystemLink);
        ControlSection[Index].Section := Index;
        // There are no function block parameters, use common address
        ControlSection[Index].Parameters := ADR(SectionParameters[Index]);
        // Enable all function blocks one the System is Active
        ControlSection[Index].Enable := gSuperTrak.System.Status.Active;
        // Enable each section
        ControlSection[Index].EnableSection := Interface.Cmd.PowerSection[Index] AND ControlSection[Index].MotorPowerOn AND NOT ControlSection[Index].Error;
        // Reset all function blocks
        ControlSection[Index].ErrorReset := gSuperTrak.System.Cmd.Reset AND ControlSection[Index].Error;
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
        IF ControlSection[Index].Info.SuperTrak.SectionFaultActive THEN
            Interface.Status.SectionError := Index;
		END_IF;
		IF ControlSection[Index].Info.SuperTrak.SectionWarningActive THEN
			Interface.Status.SectionWarning:= Index;
        END_IF;			
        
        // Log errors only when that error first occurs
        r_trig_SectionFBError[Index](CLK := ControlSection[Index].Error);
        r_trig_SectionWarning[Index](CLK := ControlSection[Index].Info.SuperTrak.SectionWarningActive);
        r_trig_SectionFault[Index](CLK := ControlSection[Index].Info.SuperTrak.SectionFaultActive);
        
        IF r_trig_SectionFBError[Index].Q THEN
            brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
            UserLogArguments.i[0] := Index; 
            UserLogArguments.i[1] := ControlSection[Index].StatusID;
            UserLogEventText('$$arlogusr', -536869812, 0, '', '', UserLogArguments);
        END_IF;
        IF r_trig_SectionWarning[Index].Q THEN
            brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
            UserLogArguments.i[0] := Index; 
            UserLogArguments.i[1] := ControlSection[Index].Info.SuperTrak.SectionWarningBits;
            UserLogEventText('$$arlogusr', -1610609636, 0, '', '', UserLogArguments);
        END_IF;
        IF r_trig_SectionFault[Index].Q THEN  
            brsmemset(ADR(UserLogArguments), 0, SIZEOF(UserLogArguments));
            UserLogArguments.i[0] := Index; 
            UserLogArguments.i[1] := ControlSection[Index].Info.SuperTrak.SectionFaultBits;
            UserLogEventText('$$arlogusr', -536869810, 0, '', '', UserLogArguments);
        END_IF;
        
        // Read other statuses
        Interface.Info[Index].SectionEnabled := ControlSection[Index].SectionEnabled;
        Interface.Info[Index].UnrecognizedShuttles := ControlSection[Index].UnrecognizedPallets;
        Interface.Info[Index].MotorPowerOn := ControlSection[Index].MotorPowerOn;
        Interface.Info[Index].ShuttlesRecovering := ControlSection[Index].PalletsRecovering;
        Interface.Info[Index].LocatingShuttles := ControlSection[Index].LocatingPallets;
        Interface.Info[Index].DisabledExternally := ControlSection[Index].DisabledExternally;
        Interface.Info[Index].WarningPresent := ControlSection[Index].Info.SuperTrak.SectionWarningActive;
        Interface.Info[Index].Warnings := ControlSection[Index].Info.SuperTrak.SectionWarningBits;
        Interface.Info[Index].FaultPresent := ControlSection[Index].Info.SuperTrak.SectionFaultActive;
        Interface.Info[Index].Faults := ControlSection[Index].Info.SuperTrak.SectionFaultBits;
    END_FOR
    
    // Write global outputs
	gSuperTrak.Sections.Status := Interface.Status;
	gSuperTrak.Sections.Info := Interface.Info;
	
END_PROGRAM
