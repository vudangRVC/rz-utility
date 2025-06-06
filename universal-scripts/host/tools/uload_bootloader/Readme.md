# RZ uload-bootloader

This directory contains tools used for flashing uload bootloader on the RZ devices

## Outline of the folder

```
uload-bootloader
├── uload_bootloader_flash.py
└── Readme.md
```

## Getting help

Run the following comamnd to know how to use the script

- Windows:

```
py uload_bootloader_flash.py -h
```

- Linux:

```
python3 uload_bootloader_flash.py -h
```

## Script usage

### Copy necessary images

1. Place all bootloader images in the /boot/uload-bootloader SD card folder (optional).

We have already prepared the .bin images in the /boot/uload-bootloader folder on partition 1 (FAT32) of the SD card. If you want to update the images, replace the files in this folder using the correct partition.

The `/boot/uload-bootloader` folder should contain the following files:

- fip-rzg2l-sbc.bin
- bl2_bp-rzg2l-sbc.bin

Or you can using the sd_creator/sd_flash.py script to program Filesystem Image to SD Card.

### Basic Usage

To run the script, use the following command

- Windows:

```
py uload_bootloader_flash.py
```

- Linux:

```
python3 uload_bootloader_flash.py
```

**Note:**

**1. Before performing a flashing, make sure the board is powered off and SD Card is attached on the board with the latest root filesystem (for details, see `Prepare image and rootfs in microSD card on Linux/Windows` in the startup guide)**

**2. (Optional) Default bootloader images (.bin) are located in the folder `/boot/uload-bootloader` of the root filesystem. You can put your own bootloader images there and perform a flashing**

## Custom Usage

If you want to change the serial port settings, you can pass the arguments as shown below:

### Arguments

- **--serial_port**: Serial port to use for communication with the board. Default is most recently connected port (E.g: COM8 in Windows or /dev/ttyUSB0 in Linux).
- **--serial_port_baud**: Baud rate for the serial port. Default is 115200.

### Example command

- Windows:

```
py uload_bootloader_flash.py --serial_port COM11 --serial_port_baud 9600
```

- Linux:

```
python3 uload_bootloader_flash.py --serial_port /dev/ttyUSB0 --serial_port_baud 9600
```

2. Connect debug serial (SCIF0 - TXD,RXD,GND) to Host PC.

3. Power on the board with a 5V. It will start to load bootloader images from uboot into QSPI flash.

Wait for the script running automatically, and no input or operation is required during this period. After completing the process, you can set RZ board to boot from QSPI as your needs.
