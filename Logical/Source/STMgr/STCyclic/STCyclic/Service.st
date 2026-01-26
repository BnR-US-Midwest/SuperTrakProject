(***************************************************************************************
 * STCyclic task Service actions
 *
 * These Actions can be run only by the STCyclic task and relate to the 
 * SuperTrak Service Channel
 *
 * File: STCyclic/Service.st
 * Created: 2024-01-12
 *
 * Authors:
 *  Tyler Matijevich, B&R Industrial Automation
 *
***************************************************************************************)

(* De-Configure any "Allow Section Enable" inputs *)
ACTION DeConfigureAllowSectionEnableInputs:
    InputConfigChanged := FALSE;
    
    // Data parameters occupy parameter numbers starting at 1024
    // To obtain information about data parameter K, specify index K - 1024 when reading the Data Parameter Information parameters
    SuperTrakServChanRead(0, stPAR_PARAM_ARRAY_LENGTH, stPAR_DIGITAL_INPUT_FUNCTION - 1024, 1, ADR(InputParameterDataLength), SIZEOF(InputParameterDataLength));

    // Number of inputs is lesser of (data array size, size of data buffer elements)
    InputCount := MIN(UDINT_TO_UINT(InputParameterDataLength), SIZEOF(DigtalInputFunctions)/SIZEOF(DigtalInputFunctions[0])); 
    SuperTrakServChanRead(0, stPAR_DIGITAL_INPUT_FUNCTION, 0, InputCount, ADR(DigtalInputFunctions), SIZEOF(DigtalInputFunctions));
    
    FOR InputIndex := 0 TO (SIZEOF(DigtalInputFunctions)/SIZEOF(DigtalInputFunctions[0])) DO
        IF DigtalInputFunctions[InputIndex] = 25 THEN
            DigtalInputFunctions[InputIndex] := 0;
            InputConfigChanged := TRUE;
        END_IF;
    END_FOR;

    IF InputConfigChanged THEN
        SuperTrakServChanWrite(0, stPAR_DIGITAL_INPUT_FUNCTION, 0, InputCount, ADR(DigtalInputFunctions), SIZEOF(DigtalInputFunctions));
    END_IF;
        
END_ACTION
