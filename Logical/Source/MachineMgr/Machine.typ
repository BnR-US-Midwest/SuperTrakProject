(***************************************************************************************
 * Global Machine data types
 *
 * These structures allow any program (task) to interface with the Main Machine task
 *
 * File: Machine.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
****************************************************************************************)

TYPE
    Machine_type :     STRUCT  (*Machine interface*)
        Cmd : Machine_Cmd_type; (*Machine commands*)
        Par : Machine_Par_type; (*Machine parameters*)
        Status : Machine_Status_type; (*Machine statuses*)
    END_STRUCT;
    Machine_Cmd_type :     STRUCT  (*Machine commands*)
        Power : BOOL; (*Power all SuperTrak sections*)
        Run : BOOL; (*Run process sequence*)
        ErrorReset : BOOL; (*Error reset*)
    END_STRUCT;
    Machine_Par_type :     STRUCT  (*Machine parameters*)
        Velocity : REAL := 1500.0; (*[mm/s] Set velocity for target and shuttle release commands*)
        Acceleration : REAL := 15.0; (*[m/s^2] Set acceleration for target and shuttle release commands*)
    END_STRUCT;
    Machine_Status_type :     STRUCT  (*Machine statuses*)
        PowerOn : BOOL; (*The main state machine is enabled and the trak is powered*)
        Ready : BOOL; (*The program is ready to run*)
        Error : BOOL; (*There is an active error present*)
        ErrorType : Error_Type_enum; (*Source of the last error*)
        SuperTrakDiag : SuperTrak_Diag_type; (*Fault and Warning information from the SuperTrak library*)
    END_STRUCT;
    Error_Type_enum : 
        ( (*Source of the last error*)
        errNONE := 0,
        errUSER := 1, (*See Automation Studio code*)
        errST_COM := 2, (*See documentation for the StCom or SuperTrak libraries in Automation Studio*)
        errST_SYSTEM := 10, (*See "Faults" section in TrakMaster Help *)
        warnST_SYSTEM := 11, (*See "Warnings" section in TrakMaster Help *)
        errST_SECTION := 20, (*See "Faults" section in TrakMaster Help *)
        warnST_SECTION := 21, (*See "Warnings" section in TrakMaster Help *)
        errST_TARGET := 30, (*See documentation for the StCom or SuperTrak libraries in Automation Studio*)
        errST_SHUTTLE := 40 (*See documentation for the StCom or SuperTrak libraries in Automation Studio*)
        );
    SuperTrak_Diag_type :     STRUCT  (*Fault and Warning information from the SuperTrak library*)
        SuperTrakDiagIndex : USINT; (*Index 0 is the System, others are for a specific section. Set to a relevant index when Errors occur*)
        Warnings : ARRAY[0..31]OF BOOL; (*See TrakMaster Help for descriptions*)
        Errors : ARRAY[0..31]OF BOOL; (*See TrakMaster Help for descriptions*)
    END_STRUCT;
END_TYPE
