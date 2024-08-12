(*Data Parameters*)

FUNCTION GetDataParameterArrayLength : UINT (*Gets the array length for data parameters. The array length N indicates that N values can be addressed, using indexes 0 through (N - 1). Returned value is the Status of SuperTrakServChanRead*)
	VAR_INPUT
		ParameterToCheck : UINT; (*Data parameter number to check the length of*)
		pDataBuffer : UDINT; (*Pointer to (UDINT) location of output data*)
		DataBufferLength : UINT; (*[bytes] Size of output data location*)
	END_VAR
	VAR
		LogValues : UserLogFormatType; (*Runtime values formatted for Log messages*)
	END_VAR
END_FUNCTION
(*Inputs and Outputs*)

FUNCTION GetInputFunctions : UINT (*Gets the functions configured for all Trakmaster Inputs. Returned value is the Status of SuperTrakServChanRead*)
	VAR_INPUT
		pDataBuffer : UDINT; (*Pointer to (UINT[8]) location of output data. Each element in the array is a Digital Input.*)
		DataBufferLength : UINT; (*[bytes] Size of output data location*)
	END_VAR
	VAR
		GetArrayLengthStatus : UINT; (*Status returned by GetDataParameterArrayLength*)
		GetArrayLengthReturnValue : UDINT; (*Value returned by GetDataParameterArrayLength*)
		Count : UINT; (*Count of values to read*)
		LogValues : UserLogFormatType; (*Runtime values formatted for Log messages*)
	END_VAR
END_FUNCTION

FUNCTION SetInputFunctions : UINT (*Sets the functions configured for all Trakmaster Inputs. Returned value is the Status of SuperTrakServChanRead*)
	VAR_INPUT
		pDataBuffer : UDINT; (*Pointer to (UINT[8]) location of input data. Each element in the array is a Digital Input.*)
		DataBufferLength : UINT; (*[bytes] Size of input data location*)
	END_VAR
	VAR
		GetArrayLengthStatus : UINT; (*Status returned by GetDataParameterArrayLength*)
		GetArrayLengthReturnValue : UDINT; (*Value returned by GetDataParameterArrayLength*)
		Count : UINT; (*Count of values to read*)
		LogValues : UserLogFormatType; (*Runtime values formatted for Log messages*)
	END_VAR
END_FUNCTION
