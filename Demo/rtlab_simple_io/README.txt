This demonstration consists of two files:
1.	'rtlab_simple_io.mdl' demonstrates simple communication using RT-LAB and an Opal-RT real-time target.
2.	'model_aio' demonstrates hardware-in-loop analog I/O.

Features: 
•	Demonstrates communication with an Opal-RT real-time target
•	Simulink model and configuration files to use AnalogIn/AnalogOut modules in the RT-LAB platform
	
Requirements:
•	MATLAB/Simulink (R2011b)
•	RT-LAB
•	Compatible Opal-RT real-time target (see 'Details')

Instructions:
1.	Review the 'Details' section below for required information.
1.	Open the model in Simulink.
2.	Simulate the model in Simulink and verify that no errors occur.
3.	Create a project in RT-LAB and add these files (see the RT-LAB documentation).
	NOTE: Make sure to include the conf and bin files. More information inside the Simulink Model.
4.	Compile and run the project on the Opal-RT target.

Comments:
•	The model is set up to run on the RT-LAB machine but will also run properly in Simulink.
•	Eventually, this demo might (should?) include the RT-LAB project files.

Details:
OP5142 Analog In/Out Example

This example demonstrates how the Opal-RT OP5142 card can be used in an RT-LAB model for applying voltage values to the Analog Out channels of one OP5330 module and returning voltage values from Analog In channels of one OP5340 module, by using the OP5142EX1 Analog Out and OP5142EX1 Analog In blocks.

In this example, the waveforms applied to the Analog Out channels are calculated in the 'Waveforms' subsystem in the SM_Master subsystem. The 'Waveforms' subsystem produces alternate square waves on the even Analog Out channel numbers and sine waves on the odd Analog Out channel numbers. The model assumes the Analog In and Analog Out channels are connected in loopback, so the waveforms applied to the Analog Out channels are returned by the Analog In channels.

The OpCtrl OP5142EX1 block is also required in the model.
This block controls the selection of the OP5142 card, by specifying its board index value. The board index is set by dip-switches located on the PCIe-to-OP5142 card adapter (refer to the hardware documentation of your system for localizing this dip-switch).
The OpCtrl OP5142EX1 block also specifies the filename of the bitstream file that will be automatically programmed in the FPGA chip of the OP5142EX1 at load time. This bitstream file was produced with RT-XSG 1.3
Finally, the OpCtrl OP5142EX1 block controls the hardware synchronization of the model, by programming a timer on the OP5142 card.

Note: the model must be run in Hardware Synchronized mode, and in XHP mode.

Description of the configuration file, and settings of the Analog Out and Analog In blocks

The Analog Out and Analog In blocks are linked to the OpCtrl OP5142EX1 block by the value of the 'Controller name' parameter. This link enables the underlying software to retrieve the filename of the bitstream, here 'OP5142_1-EX-0000-1_3_a3-OP5142_8DIO_8TSDIO_6QEIO_16AIO-0A-07.bin'.

The bitstream was produced by the Opal-RT RT-XSG product which provides an interface between the Xilinx System Generator tool and the OP5142 card. The bitstream is designed as a Simulink model in which RT-XSG specific blocks are placed according to the data transfers required to exchange Analog In and Analog Out values between the RT-LAB model and the OP5142 card. For this purpose, a set of input and outports are made available in the RT-XSG bitstream. They are named DataIn and DataOut ports. There are 32 DataIn and 32 DataOut ports, each capable of managing up to 250 32-bit data values.

In this example, two DataIn ports were reserved for transfering the Analog Output voltage values from the RT-LAB model to the OP5142 card. Each of these two ports transfer values for up to 8 channels of the Analog Out module. Each voltage value specified at the input of the OP5142EX1 Analog Out block is converted to a 16-bit value by the underlying driver, and these 8 16-bit data values are concatenated and transfered to the OP5142 card at each calculation step. Similarly, the 16-bit data acquired from Analog Input channels are concatenated and transferred to the RT-LAB model via the DataOut ports, and scaled to voltage values in the driver.

Since there are 32 DataIn ports available, and each DataIn port could be connected to any RT-XSG Analog Output block within the RT-XSG bitstream, a configuration textfile file is provided when the bitstream is produced. This textfile has the same name as the bitstream filename, with the extension .conf. It lists the type of I/O feature connected to each DataIn and each DataOut ports of the bitstream, and describes the location of the I/O channels controlled by this port.

The relevant lines of the .conf file in our example are highlighted below. Analog Output channels are addressed via the DataIn ports 1 and 2, and Analog Input channel values are retrieved via the DataOut ports 5 and 6. These numbers correspond to the 'DataIn port number' parameter of the OP5142EX1 AnalogOut blocks, and the 'DataOut port number' parameter of the OP5142EX1 AnalogIn blocks.

Hardware setup

The hardware setup presented below assumes the target PC is an Opal-RT Wanda4-type box :

- The Opal-RT OP5142 board must be installed in the target computer. It connects to the rear of the Wanda4 I/O backplane via a blackplane adapter, and to the PCIe bus via a PCIe-adapter. The PCIe adapter must be connected with a PCIe cable to one PCIe slot of the target computer.
- The Board Index dip-switch on the PCIe-adapter must set the board index value to 0.
- The backplane must be connected to the 18V power supply.
- The OP5330 and OP5340 modules must be installed on an OP5220 carrier board, OP5330 in section A and OP5340 in section B. The OP5220 carrier must be slotted in Slot1 of the carrier case.
- A loopback terminal block must be connected to the output connector of the OP5220 carrier.
- Both the PC and 18V power supplies of the target must be ON.

Connections

The model assumes the Analog In and Analog Out channels are connected in loopback, with a loopback terminal block connected to the output connector of the OP5220 carrier.
