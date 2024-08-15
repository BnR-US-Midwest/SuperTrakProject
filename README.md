This is a simple starter Automation Studio project for SuperTraks.

# Quick Start
1. Perform an initial installation to ARSim, making sure to deploy the Logical/UserFiles folder to the User Partition of the target
2. Open a global Watch window
3. Add the gMachine variable to the watch window
4. Toggle gMachine.Cmd.Enable to True
5. When gMachine.Status.Ready is True, toggle gMachine.Cmd.Run to True
6. The simulation will begin running and can be visualized in Trakmaster

# Hardware and Software Requirements
 - Automation Studio: 4.12.6
 - SuperTrak Distribution Package: 5.7
 - SuperTrak Library: 0.48.0
 - StCom Library: 5.07.0
 - Trakmaster: 3.0.48.0

The current version of this project uses Automation Runtime version K4.93. However, simulation performance with the Trakmaster visualization can be dramatically increased by running the simulation with Automation Runtime version G4.91. 

This project was developed for a standard SuperTrak PC (a B&R APC910 with the SuperTrak interface card).

# Project Components
## MachineMgr
The MachineMgr package contains the Main machine task. This task implements a state machine for controlling the SuperTrak, and can be adjusted to control any other B&R hardware that is added to this project. This state machine includes the following functionality:
- Enabling/Disabling the SuperTrak
- Starting/Stopping the machine process
- Error and Error Reset handling

Commands are processed using the gMachine.Cmd and gMachine.Par structures. Statuses are returned using the gMachine.Status structure.

This task demonstrates the sequence of checking targets for a present shuttle and then having the target release that shuttle when a machine component is done working on the shuttle.
For the purposes of simulation, shuttles are released after a timer which simulates the completion of a machine process. This sequence can be modified simply by editing the code within the MAIN_STATE_RUN section of the state machine.

## STMgr
The STMgr package contains the programs used to interface with the SuperTrak via the StCom library functions. These tasks should always be called in Cyclic #1. The following tasks are included:
1. STCyclic - handles the cyclic functions that run the SuperTrak. THIS TASK MUST ALWAYS BE CALLED IN CYCLIC 1 AT A CYCLE TIME OF 800 MICROSECONDS.
2. STSystem - controls the SuperTrak system as a whole by implementing StControl. Can be interfaced with by other programs using the variable gSuperTrak.System
3. STSection - individual Section control using StSection. Can be interfaced with by other programs using the variable gSuperTrak.Sections
4. STTarget - individual Target control using StTargetExt. Can be interfaced with by other programs using the variable gSuperTrak.Target[TARGET_NUMBER] where TARGET_NUMBER is in the range of 1..ST_TARGET_MAX
5. STShuttle - individual Shuttle control using StPallet. Can be interfaced with by other programs using the variable gSuperTrak.Shuttle[SHUTTLE_NUMBER] where SHUTTLE_NUMBER is in the range of 1..ST_SHUTTLE_MAX
