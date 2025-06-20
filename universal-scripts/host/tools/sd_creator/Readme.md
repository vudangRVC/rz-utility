# Root filesystem Programming/Flashing Procedure for RZ board on multiple OS environment

This section will introduce the relevant tools and specific steps for using these small script programs to program filesystem image.

## Outline of the folder

```
sd_creator
├── sd_flash.py
└── Readme.md
```

## Getting help

Run the following comamnd to know how to use the script

- Windows:

```
py sd_flash.py -h
```

- Linux:

```
python3 sd_flash.py -h
```

## Use sd_flash.py to program Filesystem Image to SD Card

Please following below steps:

1. Prepare your own rootfs wic image under `target\images` folder
```bash
cp </path/to/your/package>/core-image-minimal.wic /path/to/universal-scripts/target/images/
```
2. Hardware connection to each type of fastboot:
   - [UDP] Connect the Ethernet port 1 to the board
   - [OTG] Connect the PC USB port to the USB OTG port onboard
3. Running the script

### Basic Usage

To run the script without passing any arguments, simply execute the following command:

- Windows:

```
py sd_flash.py
```

- Linux:

```
python3 sd_flash.py
```

When no arguments are provided, the script will use the following default info:

- Fastboot type: udp
- IP address: 169.254.187.89
- Serial port: most recently connected port (E.g: COM8 in Windows or /dev/ttyUSB0 in Linux)
- Serial port baud: 115200
- WIC file: </path/to/your/package>/target/images/core-image-minimal.wic

Ensure that these files are present in the current directory before executing the script.

### Custom Usage

If you want to specify different file paths for the image, you can pass the arguments as shown below:

- **--board_name**: Board name to flash bootloader. Default is rzg2l-sbc.
- **--fastboot_type**: Fastboot type to use (udp or otg). Default is udp.
- **--ether_port**: [Only used in fastboot UDP] Ethernet port used to board communication. Defaults to 1.
- **--ip_address**: [Only used in fastboot UDP] Ethernet IP address used to board communication. Defaults to 169.254.187.89.
- **--serial_port**: Serial port to use for communication with the board. Default is most recently connected port (E.g: COM8 in Windows or /dev/ttyUSB0 in Linux).
- **--serial_port_baud**: Baud rate for the serial port. Default is 115200.
- **--image_rootfs**: Path to the root filesystem image.

#### Example command

- Windows:

```
py sd_flash.py --board_name rzg2l-evk --fastboot_type udp --ip_address 169.254.187.9 --ether_port 1 --serial_port COM11 --serial_port_baud 9600 --image_rootfs D:\rz-sbc\rzg2l-sbc\custom_images\core-image-minimal.wic
```

- Linux:

```
python3 sd_flash.py --board_name rzg2l-evk --fastboot_type udp --ip_address 169.254.187.9 --ether_port 1 --serial_port /dev/ttyUSB0 --serial_port_baud 9600 --image_rootfs /home/renesas/bootloader_images/core-image-minimal.wic
```

2.Connect debug serial (SCIF0 - TXD,RXD,GND) to Host PC.

3.Connect Ethernet Port 1 on RZ board to network on Host PC by network cable.

4.Run **sd_flash.py**.

5.Power on the board with a 5V, Type-C interface power, make sure you changed switches to normal boot mode. It will start to flash filesystem image into SD Card.

Wait for the script running automatically, and no input or operation is required during this period. After finishing, you can boot with the filesystem image that you just flashed.
