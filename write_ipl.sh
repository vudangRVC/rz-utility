#!/usr/bin/python3

# Imports
import serial
import argparse
import time
import os
import zipfile
import subprocess
from subprocess import Popen, PIPE, CalledProcessError
from sys import platform
import glob
import shlex
import argparse

class FlashUtil:
    def __init__(self):
        self.__scriptDir = os.getcwd()
        self.__rootDir = os.path.abspath(os.path.join(self.__scriptDir, '..', '..', '..', '..'))
        self.__imagesDir = "."

        self.__setupArgumentParser()

        self.__setupSerialPort()
        self.__writeBootloader()

    # Setup CLI parser
    def __setupArgumentParser(self):
        self.__parser = argparse.ArgumentParser(
            description="Utility to flash bootloader on RZ Boards",
            epilog="Example:\n\t./bootloader_flash.py g2l-evk --serial_port /dev/ttyUSB0"
        )

        # Serial port arguments
        self.__parser.add_argument(
            "--serial_port", default="/dev/ttyUSB0", dest="serialPort",
            help="Serial port used to talk to board (default: /dev/ttyUSB0)"
        )
        self.__parser.add_argument(
            "--serial_port_baud", default=115200, dest="baudRate", type=int,
            help="Baud rate for serial port (default: 115200)"
        )

        # Subcommands for each board
        subparsers = self.__parser.add_subparsers(dest="board", required=True, help="Target board")

        presets = {
            "v2l-evk": {
                "flashWriterImage": f"{self.__imagesDir}/Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot",
                "bl2Image": f"{self.__imagesDir}/bl2_bp_v2l-evk.srec",
                "fipImage": f"{self.__imagesDir}/fip_v2l-evk.srec",
                "boardIDImage": f"{self.__imagesDir}/v2l-evk-platform-settings.srec",
            },
            "g2l-evk": {
                "flashWriterImage": f"{self.__imagesDir}/Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot",
                "bl2Image": f"{self.__imagesDir}/bl2_bp_g2l-evk.srec",
                "fipImage": f"{self.__imagesDir}/fip_g2l-evk.srec",
                "boardIDImage": f"{self.__imagesDir}/g2l-evk-platform-settings.srec",
            },
            "g2l-sbc": {
                "flashWriterImage": f"{self.__imagesDir}/Flash_Writer_SCIF_rzg2l-sbc.mot",
                "bl2Image": f"{self.__imagesDir}/bl2_bp_g2l-sbc.srec",
                "fipImage": f"{self.__imagesDir}/fip_g2l-sbc.srec",
                "boardIDImage": f"{self.__imagesDir}/g2l-sbc-platform-settings.srec",
            },
            "g2l-100": {
                "flashWriterImage": f"{self.__imagesDir}/Flash_Writer_SCIF_RZG2L_15MMSQ_DEV_DDR4_4GB.mot",
                "bl2Image": f"{self.__imagesDir}/bl2_bp_g2l-100.srec",
                "fipImage": f"{self.__imagesDir}/fip_g2l-100.srec",
                "boardIDImage": f"{self.__imagesDir}/g2l-100-platform-settings.srec",
            },
        }

        for board, defaults in presets.items():
            sp = subparsers.add_parser(board, help=f"Flash {board}")
            for k, v in defaults.items():
                sp.set_defaults(**{k: v})

        self.__args = self.__parser.parse_args()


    # Setup Serial Port
    def __setupSerialPort(self):
        try:
            self.__serialPort = serial.Serial(port=self.__args.serialPort, baudrate = self.__args.baudRate, timeout=150)
        except:
            die(msg='Unable to open serial port.')

    # Setup Serial Port SUP
    def __setupSerialPort_SUP(self):
        try:
            self.__serialPort = serial.Serial(port=self.__args.serialPort, baudrate = 921600, timeout=15)
        except:
            die(msg='Unable to open serial port 921600 bps.')

    # Function to write bootloader
    def __writeBootloader(self):
        start_time = time.time()

        # Check file exists
        if not os.path.exists(self.__args.flashWriterImage):
            print(f"The file {self.__args.flashWriterImage} does not exist.")
            exit()
        if not os.path.exists(self.__args.bl2Image):
            print(f"The file {self.__args.bl2Image} does not exist.")
            exit()
        if not os.path.exists(self.__args.fipImage):
            print(f"The file {self.__args.fipImage} does not exist.")
            exit()
        if not os.path.exists(self.__args.boardIDImage):
            print(f"The file {self.__args.boardIDImage} does not exist.")
            exit()

        # Wait for device to be ready to receive image.
        print("Please power on board. Make sure you changed switches to SCIF download mode.")
        buf = self.__serialPort.read_until('please send !'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        # Write flash writer application
        time1 = time.time()
        print("Writing Flash Writer application...")
        self.__writeFileToSerial(self.__args.flashWriterImage)
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        time2 = time.time()
        elapsed_time = time2 - time1
        print(f"Elapsed time: Flash Writer: {elapsed_time:.6f} seconds")
        self.__serialPort.write('true\r'.encode())

        # Erase QSPI flash
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')
        self.__serialPort.write('xcs\r'.encode())

        buf = self.__serialPort.read_until('Clear OK?(y/n)'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')
        self.__serialPort.write('y\r'.encode())

        buf = self.__serialPort.read_until('complete!'.encode())
        if not buf:
            print("Returned value is not the expectation - 01. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('\r\r'.encode())

        # Changing speed to 921600 bps.
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('SUP\r'.encode())
        buf = self.__serialPort.read_until('the terminal.'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__setupSerialPort_SUP()
        time.sleep(1)
        self.__serialPort.write('\r\r'.encode())
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        # Write BL2
        self.__serialPort.write('\rXLS2\r'.encode())
        buf = self.__serialPort.read_until('Please Input : H'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('11E00\r'.encode())
        buf = self.__serialPort.read_until('Please Input : H'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('\r00000\r'.encode())
        buf = self.__serialPort.read_until('please send !'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        print("Writing BL2...")
        self.__writeFileToSerial(self.__args.bl2Image)
        buf = self.__serialPort.read_until('Clear OK'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('\ry\r'.encode())
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        # Write FIP
        self.__serialPort.write('XLS2\r'.encode())
        buf = self.__serialPort.read_until('Please Input : H'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('00000\r'.encode())
        buf = self.__serialPort.read_until('Please Input : H'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('1D200\r'.encode())
        buf = self.__serialPort.read_until('please send !'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        print("Writing fip ...")
        self.__writeFileToSerial(self.__args.fipImage)
        buf = self.__serialPort.read_until('Clear OK'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('\ry\r'.encode())
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        # Write platform settings board ID
        self.__serialPort.write('XLS2\r'.encode())
        buf = self.__serialPort.read_until('Please Input : H'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('00000\r'.encode())
        buf = self.__serialPort.read_until('Please Input : H'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('1C700\r'.encode())
        buf = self.__serialPort.read_until('please send !'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        print("Writing board_ID ...")
        self.__writeFileToSerial(self.__args.boardIDImage)
        buf = self.__serialPort.read_until('Clear OK'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        self.__serialPort.write('\ry\r'.encode())
        buf = self.__serialPort.read_until('>'.encode())
        if not buf:
            print("Returned value is not the expectation. Exiting.")
            exit()
        print(f'{buf.decode()}')

        # Close serial port
        print("Closed serial port.")
        self.__serialPort.close()

        end_time = time.time()
        elapsed_time = end_time - start_time
        print(f"Elapsed time: {elapsed_time:.6f} seconds")

    def __writeSerialCmd(self, cmd):
        self.__serialPort.write(f'{cmd}\r'.encode())

    # Function to write file over serial
    def __writeFileToSerial(self, file):
        with open(file, 'rb') as f:
            self.__serialPort.write(f.read())
            f.close()

    # Function to wait and print contents of serial buffer
    def __serialRead(self, cond='\n', print=False):
        buf = self.__serialPort.read_until(cond.encode())

        if print:
            print(f'{buf.decode()}')

# Util function to die with error
def die(msg='', code=1):
    print(f'Error: {msg}')
    exit(code)

def main():
    flashUtil = FlashUtil()

if __name__ == '__main__':
    main()
