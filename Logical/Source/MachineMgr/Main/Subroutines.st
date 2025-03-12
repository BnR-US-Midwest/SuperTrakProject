(***************************************************************************************
 * Main task subroutines (Actions)
 *
 * These Actions can be run only by the Main task
 *
 * File: Main/Subroutines.st
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

(* Determine cummulative target released status *)
ACTION GetTargetsReleased:
	
    TargetsReleased := TRUE; // Assume true
    FOR LoopTarget := 1 TO ST_TARGET_MAX DO
        // Configured targets
        IF gSuperTrak.Target[LoopTarget].Status.Section <> 0 THEN
            // Any target command true while released confirmation false
            IF (gSuperTrak.Target[LoopTarget].Cmd.Release.ReleaseToTarget
                OR gSuperTrak.Target[LoopTarget].Cmd.Release.ReleaseToOffset
                OR gSuperTrak.Target[LoopTarget].Cmd.Release.IncrementOffset) 
                AND NOT gSuperTrak.Target[LoopTarget].Status.ShuttleReleased THEN
                TargetsReleased := FALSE; // Disqualify
                EXIT;
            END_IF
        END_IF
    END_FOR
	
END_ACTION

(* Determine cummulative pallet released status *)
ACTION GetShuttlesReleased:
	
    ShuttlesReleased := TRUE; // Assume true
    FOR LoopShuttle := 1 TO ST_SHUTTLE_MAX DO
        // Pallet present on system
        IF gSuperTrak.Shuttle[LoopShuttle].Status.Present THEN
            // Any pallet command true while released confirmation false
            IF (gSuperTrak.Shuttle[LoopShuttle].Cmd.ReleaseToTarget
                OR gSuperTrak.Shuttle[LoopShuttle].Cmd.ReleaseToOffset
                OR gSuperTrak.Shuttle[LoopShuttle].Cmd.IncrementOffset)
                AND NOT gSuperTrak.Shuttle[LoopShuttle].Status.ShuttleReleased THEN
                ShuttlesReleased := FALSE; // Disqualify
                EXIT;
            END_IF
        END_IF
    END_FOR
	
END_ACTION

(* Reset all target release commands *)
ACTION ResetTargetRelease: 
	
    FOR LoopTarget := 1 TO ST_TARGET_MAX DO
        brsmemset(ADR(gSuperTrak.Target[LoopTarget].Cmd), 0, SIZEOF(gSuperTrak.Target[LoopTarget].Cmd));
    END_FOR
	
END_ACTION

(* Reset all shuttle release commands *)
ACTION ResetShuttleRelease: 
	
    FOR LoopShuttle := 1 TO ST_SHUTTLE_MAX DO
        brsmemset(ADR(gSuperTrak.Shuttle[LoopShuttle].Cmd), 0, SIZEOF(gSuperTrak.Shuttle[LoopShuttle].Cmd));
    END_FOR
	
END_ACTION

(* Reset all process timers *)
ACTION ResetProcessTimer:
	
	FOR LoopTarget := 1 TO ST_TARGET_MAX DO
		ProcessTimer[LoopTarget](IN := FALSE);
	END_FOR
	
END_ACTION

(* Set ErrorType depending on what caused the error *)
ACTION GetErrorType:
	
	// Clear ErrorType
	Interface.Status.ErrorType:= errNONE;
	
	// Default to User Error
	IF MainState = MAIN_STATE_ERROR THEN
		Interface.Status.ErrorType:= errUSER;
	END_IF
	// System FUB Errors
	IF gSuperTrak.System.Status.Error THEN
		MainState:= MAIN_STATE_ERROR;
		Interface.Status.ErrorType:= errST_COM;
	END_IF
	// Section FUB Errors
	IF gSuperTrak.Sections.Status.Error THEN
		MainState:= MAIN_STATE_ERROR;
		Interface.Status.ErrorType:= errST_COM;
	END_IF
	// System Warnings
	IF gSuperTrak.System.Info.WarningPresent THEN
		Interface.Status.ErrorType:= warnST_SYSTEM;
	END_IF
	// System Errors
	IF gSuperTrak.System.Info.FaultPresent THEN
		MainState:= MAIN_STATE_ERROR;
		Interface.Status.ErrorType:= errST_SYSTEM;
	END_IF
	// Section Warnings
	IF gSuperTrak.Sections.Status.SectionWarning THEN
		Interface.Status.ErrorType:= warnST_SECTION;
	END_IF
	// Section Errors
	IF gSuperTrak.Sections.Status.SectionError THEN
		MainState:= MAIN_STATE_ERROR;
		Interface.Status.ErrorType:= errST_SECTION;
	END_IF
	
END_ACTION

(* Translate bit-packed Errors and Warnings into Booleans *)
ACTION GetTrakMasterWarningsAndErrors:

	IF Interface.Status.SuperTrakDiag.SuperTrakDiagIndex = 0 THEN
		// System
		FOR i := 0 TO 31 DO
			Interface.Status.SuperTrakDiag.Warnings[i]	:= BIT_TST(gSuperTrak.System.Info.Warnings, i);
			Interface.Status.SuperTrakDiag.Errors[i] 	:= BIT_TST(gSuperTrak.System.Info.Faults, i);
		END_FOR
	ELSE
		// Sections
		FOR i := 0 TO 31 DO
			Interface.Status.SuperTrakDiag.Warnings[i]	:= BIT_TST(gSuperTrak.Sections.Info[Interface.Status.SuperTrakDiag.SuperTrakDiagIndex].Warnings, i);
			Interface.Status.SuperTrakDiag.Errors[i] 	:= BIT_TST(gSuperTrak.Sections.Info[Interface.Status.SuperTrakDiag.SuperTrakDiagIndex].Faults, i);
		END_FOR
	END_IF
	
END_ACTION

