// Gets the array length for data parameters. The array length N indicates that N values can be addressed, using indexes 0 through (N - 1)
// An array length of 1 indicates that a single value can be addressed at index 0.
// An array length OF 0 indicates that the parameter is NOT available.
// Returned value is the Status of SuperTrakServChanRead
FUNCTION GetDataParameterArrayLength
    
    IF (ParameterToCheck < 1024) OR (pDataBuffer = 0) OR (DataBufferLength = 0) THEN
        GetDataParameterArrayLength := ST_HELPER_FUNCTION_INPUT_ERROR;
    ELSE
        // Data parameters occupy parameter numbers starting at 1024
        // To obtain information about data parameter K, specify index K - 1024 when reading the Data Parameter Information parameters
        GetDataParameterArrayLength := SuperTrakServChanRead(0, stPAR_PARAM_ARRAY_LENGTH, ParameterToCheck - 1024, 1, pDataBuffer, DataBufferLength);
        LogValues.i[0] := stPAR_PARAM_ARRAY_LENGTH;
        LogValues.i[1] := ParameterToCheck - 1024;
        LogValues.i[2] := 1;
        UserLogAdvanced(USERLOG_SEVERITY_INFORMATION, 100, 'Service Channel Request: Parameter %i, Start Index %i, Count %i', LogValues);
    END_IF;  

END_FUNCTION
