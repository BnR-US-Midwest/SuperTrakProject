[![Made for B&R](https://raw.githubusercontent.com/hilch/BandR-badges/dfd5e264d7d2dd369fd37449605673f779db437d/Made-For-BrAutomation.svg)](https://www.br-automation.com)
![GitHub License](https://img.shields.io/github/license/BnR-US-Midwest/SuperTrakProject)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/BnR-US-Midwest/SuperTrakProject/total)
[![GitHub issues](https://img.shields.io/github/issues-raw/BnR-US-Midwest/SuperTrakProject)](https://github.com/BnR-US-Midwest/SuperTrakProject/issues)

# SuperTrak Starter Project

This is a fully functional Automation Studio project for controlling a SuperTrak. It includes:
 - Low-level Control Interface processing
 - Implementation of the B&R-provided StCom library for System, Section, Target, and Shuttle control
 - A functional Main machine task that implements a state machine with a simulated process sequence
 - EtherNet/IP communication for external control of the SuperTrak
 - Diagnostics, logging, and error handling

# Table of Contents
- [Hardware and Software Requirements](#hardware-and-software-requirements)
- [Quick Start](#quick-start)
- [Project Components](#project-components)
  - [MachineMgr](#machinemgr)
  - [STMgr](#stmgr)
  - [EthIP](#ethip)
- [Modifying the Starter Project for Your Application](#modifying-the-starter-project-for-your-application)
  - [Number of Sections, Targets, and Shuttles](#number-of-sections-targets-and-shuttles)
  - [Recovery](#recovery)
  - [Process Sequence](#process-sequence)
  - [TrakMaster Settings](#trakmaster-settings)

# Hardware and Software Requirements
>**Compatibility note:** This project has been upgraded to Automation Studio 6 and is not backwards compatible with Automation Studio 4. To use a version of this project compatible with Automation Studio 4, download the [last AS4 compatible release](https://github.com/BnR-US-Midwest/SuperTrakProject/releases/tag/1.1.0) or visit the [archive/AS412](https://github.com/BnR-US-Midwest/SuperTrakProject/tree/archive/AS412) branch.

This project was developed for a standard SuperTrak PC (a B&R APC4100 or APC910 with the SuperTrak PCIe interface card).

Software versions:
 - Automation Studio: 6.7
 - Automation Runtime: 6.7
 - SuperTrak Distribution Package: 6.0
 - SuperTrak Library: 0.63.4
 - StCom Library: 6.0.0
 - TrakMaster: 3.0.62.0

Error logging is implemented with the [UserLog library](https://github.com/BnR-US-Midwest/UserLog).

# Quick Start
1. Clone this repository or download/unpack the latest release and open the project in Automation Studio
2. Perform an initial installation to ARSim, making sure to deploy the `Logical\UserFiles` folder to the User Partition of the target via the transfer settings
3. Open a Watch window on the Main task and add the `gMachine` variable
4. Toggle `gMachine.Cmd.Power` to True. This powers all motors
5. When `gMachine.Status.Ready` is True, toggle `gMachine.Cmd.Run` to True
6. The simulation will begin running and can be visualized in TrakMaster

<img width="1426" height="376" alt="RunningExample" src="https://github.com/user-attachments/assets/09d7edff-2544-4842-af18-c750bb2b5e74" />

# Project Components
## MachineMgr
The MachineMgr package contains the `Main` machine task. This task implements a state machine for controlling the SuperTrak, and can be adjusted to control any other B&R hardware that is added to this project. This state machine includes the following functionality:
- Enabling/Disabling the SuperTrak
- Starting/Stopping the machine process
- Process station control (Target read/release)
- Error and Error Reset handling

Commands are processed using the `gMachine.Cmd` and `gMachine.Par` structures. Statuses are returned via the `gMachine.Status` structure.

The *MainLogic* Action demonstrates the sequence of checking each target for a present shuttle, and then having the target release that shuttle when a machine component is done working on it.
For the purposes of simulation, shuttles are released after a timer which simulates the completion of a machine process. This Action runs within the `MAIN_STATE_RUN` state and is gated by the boolean variable `gUseExternalControl`. This allows the sequence to be handled externally, in which case incoming commands are written directly to the `gSuperTrak` structure by the `EipComm` task.

## STMgr
The STMgr package contains the programs used to interface with the SuperTrak via the StCom library functions. The following tasks are included:
1. `STCyclic` - calls the cyclic motion control functions 
2. `STSystem` - controls the SuperTrak system as a whole by implementing StControl. Can be interfaced with by other programs using the variable `gSuperTrak.System`
3. `STSection` - individual Section control using StSection. Can be interfaced with by other programs using the variable `gSuperTrak.Sections`
4. `STTarget` - individual Target control using StTargetExt. Can be interfaced with by other programs using the variable `gSuperTrak.Target[TARGET_NUMBER]` where `TARGET_NUMBER` is in the range of 1..`ST_TARGET_MAX`
5. `STShuttle` - individual Shuttle control using StPallet. Can be interfaced with by other programs using the variable `gSuperTrak.Shuttle[SHUTTLE_NUMBER]` where `SHUTTLE_NUMBER` is in the range of 1..`ST_SHUTTLE_MAX`

>⚠️ STCyclic must always be called in Cyclic #1 with a Cycle Time of 800 microseconds and 0 Tolerance.

## EthIP
The EthIP package contains the `EipComm` task, which enables an external PLC to command and monitor the SuperTrak via EtherNet/IP communication. When this task is running it sets `gUseExternalControl` True each cycle, which causes the `Main` task to skip its internal process sequence and accept commands from the external controller instead.

> ⚠️ This task is disabled in the Software Configuration by default. Enabling it as-is will overwrite the`gSuperTrak` structure data with I/O data each cycle and prevent the Main task release logic from running.

Communication is handled using the [AsEthIP library](https://help.br-automation.com/#/en/6/libraries%2Fasethip%2Fasethip.html). The `ethIPcon` data object defines the Input and Output assemblies:

- **Input Assembly** (APC → external controller, `IO.Out.*`): system and section statuses, diagnostic information, per-target shuttle data
- **Output Assembly** (external controller → APC, `IO.In.*`): system enable and error-reset commands, and per-target release commands/parameters

Because EtherNet/IP does not support arrays of BOOLs, per-target and per-shuttle BOOL values are bit-packed into DINT fields (bit position = target/shuttle number). The current DINT bitmask approach supports up to 32 targets and 32 shuttles.


# Modifying the Starter Project for Your Application
There are a few things that must be considered when making modifications to this project.

## Number of Sections, Targets, and Shuttles
There are constants declared in the SuperTrak.var file within the Source -> STMgr package:
 - `ST_SECTION_MAX`
 - `ST_TARGET_MAX`
 - `ST_SHUTTLE_MAX`

These constants must be checked and updated if sections, targets, or shuttles are added to the system.
 > ⚠️ ST_TARGET_MAX must be divisble by 4 and also must be greater than the number of targets actually configured in TrakMaster by at least 1. For example, if there are 8 targets used in TrakMaster, this constant should be set to 12.

## Recovery
Any application-specific recovery code should be added to the `MAIN_STATE_RECOVER` state of the Main task. The basic recovery sequence just checks that all shuttles are on their way to the Load Target.

## Process Sequence
Sample code for controlling SuperTrak targets is in the `MAIN_STATE_RUN` state of the Main task. This is where the main process control code should be written. Each target is checked with the following flow: 

>Shuttle At Target -> Processing Complete -> Set Shuttle Parameters and Release Shuttle

This flow can be duplicated for additional targets.

## TrakMaster Settings
- Use the Advanced -> System Layout page to configure your trak's layout
- Set Global Parameters -> Enable Simulation to False if running on a real APC

The TrakMaster configuration (.dat) files in the project's UserFiles package will be transferred to `USER_PATH\SuperTrak` during an initial installation. This is true for ARSim targets as well. These files will be modified whenever changes are made in TrakMaster (e.g., adding targets). To backup any changes made in TrakMaster, these files should be backed up or copied back into the Logical View directory.