
(* Determine cummulative target released status *)
ACTION GetTargetsReleased:
	
    TargetsReleased := TRUE; // Assume true
    FOR LoopTarget := 1 TO ST_TARGET_MAX DO
        // Configured targets
        IF gSuperTrak.Target[LoopTarget].Status.Section <> 0 THEN
            // Any target command true while released confirmation false
            IF (gSuperTrak.Target[LoopTarget].Cmd.ReleaseToTarget
                OR gSuperTrak.Target[LoopTarget].Cmd.ReleaseToOffset
                OR gSuperTrak.Target[LoopTarget].Cmd.IncrementOffset)
                AND gSuperTrak.Target[LoopTarget].Status.PalletReleased = FALSE THEN
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
                AND gSuperTrak.Shuttle[LoopShuttle].Status.PalletReleased = FALSE THEN
                ShuttlesReleased := FALSE; // Disqualify
                EXIT;
            END_IF
        END_IF
    END_FOR
	
END_ACTION
