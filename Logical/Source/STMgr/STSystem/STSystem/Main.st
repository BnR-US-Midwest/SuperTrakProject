(***************************************************************************************
 * STSystem task
 *
 * This task provides a state machine for enabling/disabling the SuperTrak system.
 * This task should be controlled by the Main task via gSuperTrak.System.
 *
 * If adding sections, targets, or shuttles, double check the assigned values
 * of the ST_XX_MAX constants.
 *
 * File: STSystem.st
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

PROGRAM _INIT
	
	SystemParameters.NrOfCommands := ST_COMMAND_MAX;
	SystemParameters.NrOfSections := ST_SECTION_MAX;
	SystemParameters.NrOfTargets := ST_TARGET_MAX;
	SystemParameters.NrOfPallets := ST_SHUTTLE_MAX;
	
	Timeout.PT := T#500ms;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Read global inputs
    Interface.Cmd := gSuperTrak.System.Cmd;
	
    // State control
    CASE State OF
        STATE_INITIALIZE:
            // Enable once and never disabled
            ControlSystem.Enable := TRUE;
			
            IF ControlSystem.Active THEN
                State := STATE_IDLE;
				
            ELSIF ControlSystem.Error THEN
                Interface.Status.ErrorID := ControlSystem.StatusID;
                State := STATE_ERROR;
				
            ELSIF Timeout.Q THEN
                Interface.Status.ErrorID := -1;
                UserLogBasic(USERLOG_SEVERITY_ERROR, 0, 'Timeout while enabling StControl function block');
                State := STATE_ERROR;
            END_IF   
			
		STATE_IDLE:
            IF ControlSystem.SectionsEnabled THEN
                UserLogBasic(USERLOG_SEVERITY_WARNING, 1102, 'Sections enabled by alternative source');
                State := STATE_EXECUTE;
			
            ELSIF RunTrigger.Q THEN
                State := STATE_STARTING;
				
            ELSIF ControlSystem.Error THEN
                Interface.Status.ErrorID := ControlSystem.StatusID;
                State := STATE_ERROR;
            END_IF
		
        STATE_STARTING:
            ControlSystem.EnableAllSections := TRUE;
            
            IF ControlSystem.SectionsEnabled THEN
                State := STATE_EXECUTE;
				
            ELSIF ControlSystem.Error THEN
                Interface.Status.ErrorID := ControlSystem.StatusID;
                State := STATE_ERROR;
			
            ELSIF Timeout.Q THEN
                Interface.Status.ErrorID := -1;
                UserLogBasic(USERLOG_SEVERITY_ERROR, 0, 'Timeout during Enable All Sections (StControl function block)');
                State := STATE_ERROR;
            END_IF
			
        STATE_EXECUTE:
            IF Interface.Info.SectionsDisabled THEN
                UserLogBasic(USERLOG_SEVERITY_WARNING, 1104, 'Sections disabled by alternative source');
                ControlSystem.EnableAllSections := FALSE;
                State := STATE_IDLE;
			
            ELSIF NOT Interface.Cmd.PowerAllSections THEN
                State := STATE_STOPPING;
			
            ELSIF ControlSystem.Error THEN
                Interface.Status.ErrorID := ControlSystem.StatusID;
                State := STATE_ERROR;
            END_IF
			
        STATE_STOPPING:
            ControlSystem.EnableAllSections := FALSE;
			
            IF Interface.Info.SectionsDisabled THEN
                State := STATE_IDLE;
				
            ELSIF ControlSystem.Error THEN
                Interface.Status.ErrorID := ControlSystem.StatusID;
                State := STATE_ERROR;
				
            ELSIF Timeout.Q THEN
                UserLogBasic(USERLOG_SEVERITY_ERROR, 0, 'Timeout during Disable All Sections (StControl function block)');
                Interface.Status.ErrorID := -1;
                State := STATE_ERROR;
            END_IF
			
        STATE_ERROR:
            ControlSystem.EnableAllSections := FALSE;
			
            IF ResetTrigger.Q THEN
                State := STATE_CLEARING;
            END_IF
			
        STATE_CLEARING:
            ControlSystem.ErrorReset := TRUE;
            Interface.Status.ErrorID := 0;
			
            IF ControlSystem.Error = FALSE THEN
                ControlSystem.ErrorReset := FALSE;
                State := STATE_IDLE;
				
            ELSIF Timeout.Q THEN
                Interface.Status.ErrorID := -1;
                UserLogBasic(USERLOG_SEVERITY_ERROR, 0, 'Timeout during Error Reset of StControl function block');
                State := STATE_ERROR;
            END_IF
    END_CASE
	
    // Call function blocks
    ControlSystem.StCtrlData := gSTCyclicRef.ControlDataAddress;
    ControlSystem.StCtrlDataSize := gSTCyclicRef.ControlDataSize;
    ControlSystem.StStatData := gSTCyclicRef.StatusDataAddress;
    ControlSystem.StStatDataSize := gSTCyclicRef.StatusDataSize;
    ControlSystem.StServChRequestData := gSTCyclicRef.RequestDataAddress;
    ControlSystem.StServChRequestDataSize := gSTCyclicRef.RequestDataSize;
    ControlSystem.StServChResponseData := gSTCyclicRef.ResponseDataAddress;
    ControlSystem.StServChResponseDataSize := gSTCyclicRef.ResponseDataSize;
    ControlSystem.StLink := ADR(gSTSystemLink);
    ControlSystem.Parameters := ADR(SystemParameters);
    ControlSystem();
	
    RunTrigger.CLK := Interface.Cmd.PowerAllSections;
    RunTrigger();
    ResetTrigger.CLK := Interface.Cmd.Reset;
    ResetTrigger();
	
    Timeout.IN := Interface.Status.Busy;
    Timeout();
	
    // Process outputs
    CollectSectionStatuses;
    Interface.Info.SectionCount := ControlSystem.Info.SuperTrak.NrOfSections;
    Interface.Info.ShuttleCount := ControlSystem.Info.SuperTrak.NrOfPallets;
    Interface.Info.WarningPresent := ControlSystem.Info.SuperTrak.SystemWarningActive;
    Interface.Info.Warnings := ControlSystem.Info.SuperTrak.SystemWarningBits;
    Interface.Info.FaultPresent := ControlSystem.Info.SuperTrak.SystemFaultActive;
    Interface.Info.Faults := ControlSystem.Info.SuperTrak.SystemFaultBits;
	
    // Set status
    Interface.Status.Active := ControlSystem.Active;
    Interface.Status.Busy := State = STATE_INITIALIZE OR
    State = STATE_STARTING OR
    State = STATE_STOPPING OR
    State = STATE_CLEARING;
    Interface.Status.Ready := State = STATE_IDLE;
    Interface.Status.PowerOn := State = STATE_EXECUTE;
    Interface.Status.Error := State = STATE_ERROR;
	
    // Write global outputs
    gSuperTrak.System.Status := Interface.Status;
    gSuperTrak.System.Info := Interface.Info;
	
END_PROGRAM
