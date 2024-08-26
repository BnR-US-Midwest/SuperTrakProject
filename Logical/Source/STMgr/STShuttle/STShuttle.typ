(***************************************************************************************
 * Global STShuttle data types
 *
 * These structures allow any program (task) to interface with the STShuttle task
 *
 * File: STShuttle.typ
 * Created: 2024-08-15
 *
 * Authors:
 *  Marcus Mangel, B&R Industrial Automation
 *
****************************************************************************************)
TYPE
	STShuttleInterfaceType : 	STRUCT  (*Shuttle interface structure*)
		Cmd : STReleaseCommandType; (*Shuttle release commands*)
		Status : STShuttleStatusType; (*Shuttle status information*)
		Par : STReleaseParameterType; (*Shuttle release parameters*)
	END_STRUCT;
	STShuttleStatusType : 	STRUCT  (*Shuttle status structure*)
		ShuttleID : USINT; (*(StPalletStatusBits_e) ID Number assigned to the shuttle*)
		Present : BOOL; (*(StPalletStatusBits_e) Present on system*)
		Recovering : BOOL; (*(StPalletStatusBits_e) Will recover or recovering to last controlled position*)
		AtTarget : BOOL; (*(StPalletStatusBits_e) Arrived at target, in position, not yet released*)
		InPosition : BOOL; (*(StPalletStatusBits_e) Within in-position window*)
		ServoEnabled : BOOL; (*(StPalletStatusBits_e) Control enabled*)
		Initializing : BOOL; (*(StPalletStatusBits_e) Moving to load target*)
		Lost : BOOL; (*(StPalletStatusBits_e) Position feedback lost*)
		ControlMode : USINT; (*(SuperTrakPalletInfo_t) Pallet control mode, see SuperTrak library*)
		Section : USINT; (*(SuperTrakPalletInfo_t or Par 1307) Current section number*)
		PositionMicrons : DINT; (*(SuperTrakPalletInfo_t or Par 1310) [um] Current section position in microns*)
		Position : REAL; (*(SuperTrakPalletInfo_t or Par 1310) [mm] Current section position*)
		Velocity : REAL; (*(Par 1314) [mm/s] Current velocity*)
		DestinationTarget : USINT; (*(Par 1339) Destination target*)
		SetSection : USINT; (*(Par 1306) Section number setpoint*)
		SetPositionMicrons : DINT; (*(Par 1311) [um] Integer section position setpoint in microns*)
		SetPosition : REAL; (*(Par 1311) [mm] Section position setpoint*)
		SetVelocity : REAL; (*(Par 1313) [mm/s] Velocity setpoint*)
		SetAcceleration : REAL; (*(Par 1312) [mm/s^2] Acceleration setpoint*)
		ShuttleReleased : BOOL; (*(Derived) Release command acknowledged. True until release command is reset*)
	END_STRUCT;
END_TYPE
