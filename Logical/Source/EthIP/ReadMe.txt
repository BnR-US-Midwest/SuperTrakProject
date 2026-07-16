To establish EtherNet/IP Communication between the B&R SuperTrak Controller PC and an Allen Bradley PLC:

B&R Side
1. Enable the EipComm task in the Software Configuration (Cpu.sw)
2. Modify the IP addresses in the ethIPcon.dat data file. #OWNIP refers to the B&R PC's IP address and #STATIONIP refers to the AB PLC's IP address
3. Change the #OWNINTERFACE if you're using a different ETH interface than the default (IF3/ETH1)
4. After all modifications are complete, build and transfer the Automation Studio project to the B&R controller
5. Restart the B&R controller if it did not automatically restart after the transfer

Allen Bradley Side:
1. Use "Import Program" to import the SuperTrak.L5X file. This file includes two UDTs (ST_EthIP_Input and ST_EthIP_Output), two controller tags (SuperTrak_In and SuperTrak_Out), and a copy program (SuperTrak) that moves data between the Generic Ethernet module and the controller tags
    The UDTs define the typed byte layout of the input and output assemblies
    The controller tags (SuperTrak_In / SuperTrak_Out) hold the decoded data exchanged with the B&R controller; reference these in your application logic
2. Add a Generic Ethernet module to the Allen Bradley project. Use the following settings:
    Name: Connection1
    Comm Format: Data - SINT
    IP Address: match #OWNIP from the .dat file
    Input Assembly Instance/Size: 101/96
    Output Assembly Instance/Size: 102/492
    Configuration Assembly Instance/Size: 100/400
    RPI: 10 ms
3. Schedule the copy program to run at least every 5ms (at least twice as fast as the RPI). Each scan it copies Connection1:I -> SuperTrak_In and SuperTrak_Out -> Connection1:O
    Note: the copy program references the module tags, so the module in step 2 must be named Connection1 (otherwise update the CPS operands). Verify the routine after adding the module
4. Download the Allen Bradley project to the PLC and start the program. The Generic Ethernet module should be Running with no faults
5. In your application logic, read status from SuperTrak_In.* and write commands to SuperTrak_Out.*. Do not use the raw Connection1:I / Connection1:O tags directly