// Gets the functions configured for all Trakmaster Inputs. Returned value is the Status of SuperTrakServChanRead
FUNCTION GetInputFunctions
    
    // Check inputs for validity
    IF (pDataBuffer = 0) OR (DataBufferLength = 0) THEN
        GetInputFunctions := ST_HELPER_FUNCTION_INPUT_ERROR;
        RETURN;
    END_IF;
    
    // Check size of data array
    GetArrayLengthStatus := GetDataParameterArrayLength(stPAR_DIGITAL_INPUT_FUNCTION, ADR(GetArrayLengthReturnValue), SIZEOF(GetArrayLengthReturnValue));
    IF GetArrayLengthStatus <> 0 THEN
        GetInputFunctions := ST_HELPER_FUNCTION_INPUT_ERROR;
        RETURN;
    END_IF;
    
    // Number of inputs is lesser of (data array size, size of data buffer elements)
    Count := MIN(UDINT_TO_UINT(GetArrayLengthReturnValue), DataBufferLength/SIZEOF(UINT)); 
    GetInputFunctions := SuperTrakServChanRead(0, stPAR_DIGITAL_INPUT_FUNCTION, 0, Count, pDataBuffer, DataBufferLength);
    LogValues.i[0] := stPAR_DIGITAL_INPUT_FUNCTION;
    LogValues.i[1] := 0;
    LogValues.i[2] := Count;
    UserLogAdvanced(USERLOG_SEVERITY_INFORMATION, 100, 'Service Channel Request: Parameter %i, Start Index %i, Count %i', LogValues);
    
END_FUNCTION

// Sets the functions configured for all Trakmaster Inputs. Returned value is the Status of SuperTrakServChanRead
FUNCTION SetInputFunctions
    
    // Check inputs for validity
    IF (pDataBuffer = 0) OR (DataBufferLength = 0) THEN
        SetInputFunctions := ST_HELPER_FUNCTION_INPUT_ERROR;
        RETURN;
    END_IF;
    
    // Check size of data array
    GetArrayLengthStatus := GetDataParameterArrayLength(stPAR_DIGITAL_INPUT_FUNCTION, ADR(GetArrayLengthReturnValue), SIZEOF(GetArrayLengthReturnValue));
    IF GetArrayLengthStatus <> 0 THEN
        SetInputFunctions := ST_HELPER_FUNCTION_INPUT_ERROR;
        RETURN;
    END_IF;
    
    // Number of inputs is lesser of (data array size, size of data buffer elements)
    Count := MIN(UDINT_TO_UINT(GetArrayLengthReturnValue), DataBufferLength/SIZEOF(UINT)); 
    SetInputFunctions := SuperTrakServChanWrite(0, stPAR_DIGITAL_INPUT_FUNCTION, 0, Count, pDataBuffer, DataBufferLength);
    LogValues.i[0] := stPAR_DIGITAL_INPUT_FUNCTION;
    LogValues.i[1] := 0;
    LogValues.i[2] := Count;
    UserLogAdvanced(USERLOG_SEVERITY_INFORMATION, 100, 'Service Channel Request: Parameter %i, Start Index %i, Count %i', LogValues);
    
END_FUNCTION

