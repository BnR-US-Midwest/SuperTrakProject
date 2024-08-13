
(* Determine cummulative target released status *)
ACTION GetTargetsReleased:
	
    TargetsReleased := TRUE; // Assume true
    FOR LoopTarget := 1 TO ST_TARGET_MAX DO
        // Configured targets
        IF gSuperTrak.Target[LoopTarget].Status.Section <> 0 THEN
            // Any target command true while released confirmation false
            IF (gSuperTrak.Target[LoopTarget].Cmd.ReleaseToTarget
                OR gSuperTrak.Target[LoopTarget].Cmd.ReleaseToOffset
                OR gSuperTrak.Target[LoopTarget].Cmd.IncrementOffset) THEN
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
                OR gSuperTrak.Shuttle[LoopShuttle].Cmd.IncrementOffset) THEN
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
