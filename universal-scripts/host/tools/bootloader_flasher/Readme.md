# Bootloader Flashing on RZ devices

The script simplifies the process by automating the flashing of bootloader images onto the RZ board in a multiple OS environment.

## Outline of the folder

```
bootloader-flasher
├── bootloader_flash.py
└── Readme.md
```

## Getting help

Run the following comamnd to know how to use the script

- Windows:

```
py bootloader_flash.py -h
```

- Linux:

```
python3 bootloader_flash.py -h
```

## Basic Usage

To run the script without passing any arguments, simply execute the following command:

- Windows:

```
py bootloader_flash.py
```

- Linux:

```
python3 bootloader_flash.py
```

When no arguments are provided, the script will use the following default info:

- Board info:
  - Board name: rzg2l-sbc
  - Flash method: qspi
  - Serial port: most recently connected port (E.g: COM8 in Windows or /dev/ttyUSB0 in Linux)
  - Serial port baud: 115200
- File paths for the images:
  - Flash Writer Image: </path/to/your/package>/target/images/Flash_Writer_SCIF_rzg2l-sbc.mot
  - BL2 Image: </path/to/your/package>/target/images/bl2_bp-rzg2l-sbc.srec
  - FIP Image: </path/to/your/package>/target/images/fip-rzg2l-sbc.srec
  - Board identification Image: </path/to/your/package>/target/images/rzg2l-sbc-platform-settings.bin

Ensure that these files are present in the current directory before executing the script.

## Custom Usage

If you want to specify different file paths or change the serial port settings or images file, you can pass the arguments as shown below:

### Arguments

- **--board_name**: Board name to flash bootloader. Default is rzg2l-sbc.
- **--flash_method**: Flash method to use (qspi or emmc). Default is qspi.
- **--serial_port**: Serial port to use for communication with the board. Default is most recently connected port (E.g: COM8 in Windows or /dev/ttyUSB0 in Linux).
- **--serial_port_baud**: Baud rate for the serial port. Default is 115200.
- **--image_writer**: Path to the Flash Writer image.
- **--image_bl2**: Path to the BL2 image.
- **--image_fip**: Path to the FIP image.
- **--image_bid**: Path to the board identification image.

### Example command

- Windows:

```
py bootloader_flash.py --board_name rzg2l-evk --flash_method emmc --serial_port COM11 --serial_port_baud 9600 --image_writer D:\rz-sbc\rzg2l-sbc\custom_images\Flash_Writer_SCIF_rzg2l-sbc.mot --image_bl2 D:\rz-sbc\rzg2l-sbc\custom_images\bl2_bp-rzg2l-sbc.srec --image_fip D:\rz-sbc\rzg2l-sbc\custom_images\fip-rzg2l-sbc.srec --image_bid D:\rz-sbc\rzg2l-sbc\custom_images\rzg2l-evk-platform-settings.bin
```

- Linux:

```
python3 bootloader_flash.py --board_name rzg2l-evk --flash_method emmc --serial_port /dev/ttyUSB0 --serial_port_baud 9600 --image_writer /home/renesas/bootloader_images/Flash_Writer_SCIF_rzg2l-sbc.mot --image_bl2 /home/renesas/bootloader_images/bl2_bp-rzg2l-sbc.srec --image_fip /home/renesas/bootloader_images/fip-rzg2l-sbc.srec --image_bid /home/renesas/bootloader_images/rzg2l-evk-platform-settings.bin
```

If which arguments is not passed, the default value will be used.

2.Connect debug serial (SCIF0 - TXD,RXD,GND) to Host PC, then change switches to enter SCIF download mode.

3.Power on the board with a 5V. It will start to flash bootloader images into QSPI flash.

Wait for the script running automatically, and no input or operation is required during this period. After completing the process, you can set RZ board to boot from QSPI as your needs.
