(***************************************************************************************
 * EipComm task local types and enumerations
 *
 * These datatypes and enums are local to the EipComm task and are used for
 * EtherNet/IP communication
 *
 * File: EipComm/Types.typ
 * Created: 2025-03-11
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
***************************************************************************************)

TYPE
    CommState_enum : 
        ( (*State of the communication program*)
        COMM_STATE_OFF, (*Communication is inactive*)
        COMM_STATE_ON, (*Communication is active*)
        COMM_STATE_ERROR (*There is an error. Communication is inactive*)
        );
END_TYPE

(*Communicated Data*)

TYPE
    IO_type :     STRUCT  (*Data communicated to external controller*)
        In : IO_In_type; (*Data from external controller (Output Assembly)*)
        Out : IO_Out_type; (*Data to external controller (Input Assembly)*)
    END_STRUCT;
    IO_In_type :     STRUCT  (*Data from external controller (Output Assembly)*)
        SystemEnable : BOOL; (*Command: Power all Sections*)
        SystemErrorReset : BOOL; (*Command: Global error reset*)
        TargetReleaseToTarget : DINT; (*Command: Release the Shuttle at the Target to a new Target. Bit packed (bit position = Source Target #)*)
        TargetReleaseToOffset : DINT; (*Command: Release the Shuttle to a Target with an Offset. Bit packed (bit position = Source Target #)*)
        TargetDestinationTarget : ARRAY[0..31]OF SINT; (*Parameter: Destination Target for the RelaseToTarget command. *)
        TargetReleaseDirection : ARRAY[0..31]OF INT; (*Parameter: Direction of Release. 0=CW, 1=CCW. Source Target# = Array Position. ARRAY SIZE MUST MATCH DEFINITION IN .DAT FILE*)
        TargetReleaseAccel : ARRAY[0..31]OF REAL; (*Parameter: Acceleration [m/s^2] for Release commands (Source Target# = Array Position). ARRAY SIZE MUST MATCH DEFINITION IN .DAT FILE*)
        TargetReleaseVelocity : ARRAY[0..31]OF REAL; (*Parameter: Velocity [mm/s] for Release commands (Source Target# = Array Position). ARRAY SIZE MUST MATCH DEFINITION IN .DAT FILE*)
        TargetReleaseOffset : ARRAY[0..31]OF REAL; (*Parameter: Absolute position offset from Target [mm]. Source Target# = Array Position. ARRAY SIZE MUST MATCH DEFINITION IN .DAT FILE*)
    END_STRUCT;
    IO_Out_type :     STRUCT  (*Data to external controller (Input Assembly)*)
        SystemEnabled : BOOL; (*Status: All sections are Enabled*)
        SystemDisabled : BOOL; (*Status: All sections are Disabled*)
        SystemReadyToEnable : BOOL; (*Status: System is ready to Enable*)
        SystemFaultPresent : BOOL; (*Status: System is reporting a Fault*)
        SystemFaults : DINT; (*Status: System Fault bits*)
        SystemWarningPresent : BOOL; (*Status: System is reporting a Warning*)
        SystemWarnings : DINT; (*Status: System Warning bits*)
        SystemSectionCount : INT; (*Status: # of configured Sections (only read once on Enable)*)
        SystemShuttleCount : INT; (*Status: # of Shuttles currently on the system (read Cyclically)*)
        TargetShuttlePresent : DINT; (*Status: A Shuttle has arrived at the Target. Bit packed (bit position = Target #)*)
        TargetShuttleID : ARRAY[0..31]OF SINT; (*Status: ID of the Shuttle at the Target (Target# = Array Position). ARRAY SIZE MUST MATCH DEFINITION IN .DAT FILE*)
        TargetShuttleCount : ARRAY[0..31]OF SINT; (*Status: Number of Shuttles at the Target (Target# = Array Position). ARRAY SIZE MUST MATCH DEFINITION IN .DAT FILE*)
    END_STRUCT;
END_TYPE
