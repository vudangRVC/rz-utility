#!/usr/bin/python3

# Imports
import serial
import argparse
import time
import os
from serial.tools.list_ports import comports

class BootloaderFlashUtil:
	def __init__(self, args=[]):
		self.__scriptDir = os.path.dirname(os.path.abspath(__file__))
		self.__rootDir = os.path.abspath(os.path.join(self.__scriptDir, '..', '..', '..'))
		self.__imagesDir = os.path.abspath(os.path.join(self.__rootDir, 'target', 'images'))

		self.__flashAddress = {
			"rzg2l-sbc": {
				"QSPI": {
					"BL2": ["11E00", "00000"],
					"FIP": ["00000", "1D200"],
					"BID": ["00810", "1C700"]
				},
				"eMMC": {
					"BL2": ["1", "1",   "11E00"],
					"FIP": ["1", "100", "00000", "2",   "8"],
					"BID": ["1", "200", "1C700", "250", "122"],
				}
			},
			"rzg2l-evk": {
				"QSPI": {
					"BL2": ["11E00", "00000"],
					"FIP": ["00000", "1D200"],
					"BID": ["00810", "1C700"]
				},
				"eMMC": {
					"BL2": ["1", "1",   "11E00"],
					"FIP": ["1", "100", "00000", "2",   "8"],
					"BID": ["1", "200", "1C700", "250", "122"],
				}
			},
			"rzv2l-evk": {
				"QSPI": {
					"BL2": ["11E00", "00000"],
					"FIP": ["00000", "1D200"],
					"BID": ["00810", "1C700"]
				},
				"eMMC": {
					"BL2": ["1", "1",   "11E00"],
					"FIP": ["1", "100", "00000", "2",   "8"],
					"BID": ["1", "200", "1C700", "250", "122"],
				}
			},
		}

		self.__setupArgumentParser(args)
		self.__setupSerialPort()

	# Setup CLI parser
	def __setupArgumentParser(self, args=[]):
		# Create parser
		self.__parser = argparse.ArgumentParser(description='Util to flash bootloader on RZ Board.\n', epilog='Example:\n\t./bootloader_flash.py')

		# Add arguments
		# Board name
		self.__parser.add_argument('--board_name',
									default='rzg2l-sbc',
									dest='boardName',
									action='store',
									type=str,
									help='Board name to flash bootloader (defaults to: rzg2l-sbc).')
		self.__parser.add_argument('--flash_method',
									default='qspi',
									dest='flashMethod',
									action='store',
									type=str,
									choices=['emmc', 'qspi'],
									help='Flash method to use (defaults to: qspi).')

		# Serial port arguments
		self.__parser.add_argument('--serial_port',
									default=None,
									dest='serialPort',
									action='store',
									help='Serial port used to talk to board (defaults to: most recently connected port).')
		self.__parser.add_argument('--serial_port_baud',
									default=115200,
									dest='baudRate',
									action='store',
									type=int,
									help='Baud rate for serial port (defaults to: 115200).')

		# Images
		self.__parser.add_argument('--image_writer',
									default=f'{self.__imagesDir}/Flash_Writer_SCIF_rzg2l-sbc.mot',
									dest='flashWriterImage',
									action='store',
									type=str,
									help="Path to Flash Writer image (defaults to: <path/to/your/package>/target/images/Flash_Writer_SCIF_rzg2l-sbc.mot).")
		self.__parser.add_argument('--image_bl2',
									default=f'{self.__imagesDir}/bl2_bp-rzg2l-sbc.srec',
									dest='bl2Image',
									action='store',
									type=str,
									help='Path to bl2 image (defaults to: <path/to/your/package>/target/images/bl2_bp-rzg2l-sbc.srec).')
		self.__parser.add_argument('--image_fip',
									default=f'{self.__imagesDir}/fip-rzg2l-sbc.srec',
									dest='fipImage',
									action='store',
									type=str,
									help='Path to FIP image (defaults to: <path/to/your/package>/target/images/fip-rzg2l-sbc.srec).')
		self.__parser.add_argument('--image_bid',
									default=f'{self.__imagesDir}/rzg2l-sbc-platform-settings.bin',
									dest='bidImage',
									action='store',
									type=str,
									help='Path to board identification image (defaults to: <path/to/your/package>/target/images/rzg2l-sbc-platform-settings.bin).')

		if args is not None:
			self.__args = self.__parser.parse_args(args)
		else:
			self.__args = self.__parser.parse_args()

	# Setup Serial Port
	def __setupSerialPort(self):
		try:
			if (self.__args.serialPort is None):
				ports = [port.device for port in comports()]
				print(f"Available serial ports: {ports}")
				print(f"Using serial port: {ports[0]}")
				self.__serialPort = serial.Serial(port= ports[0], baudrate = self.__args.baudRate, timeout=60)
			else:
				self.__serialPort = serial.Serial(port=self.__args.serialPort, baudrate = self.__args.baudRate, timeout=60)

		except:
			die(msg='Unable to open serial port.')

	# Setup Serial Port SUP
	def __setupSerialPort_SUP(self):
		try:
			self.__serialPort.baudrate = 921600
		except:
			die(msg='Unable to open serial port 921600 bps.')

	# Function to write bootloader
	def writeBootloader(self):
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

		flashAddress = self.__flashAddress[self.__args.boardName]
		if flashAddress is None:
			print(f"Board name {self.__args.boardName} is not supported.")
			exit()

		# Wait for device to be ready to receive image.
		print("Please power on board. Make sure you changed switches to SCIF download mode.")
		self.__serialRead('please send !')

		# Write flash writer application
		time1 = time.time()
		print("Writing Flash Writer application...")
		self.__writeFileToSerial(self.__args.flashWriterImage)
		self.__serialRead('>')

		time2 = time.time()
		elapsed_time = time2 - time1
		print(f"Elapsed time: Flash Writer: {elapsed_time:.6f} seconds")

		self.__writeSerialCmd('')
		self.__serialRead('>')

		# emmc flash
		if (self.__args.flashMethod == "emmc"):
			self.__handle_emmc_flash(flashAddress["eMMC"])
		# qspi flash
		elif (self.__args.flashMethod == "qspi"):
			self.__handle_qspi_flash(flashAddress["QSPI"])

		print("Closed serial port.")
		self.__serialPort.close()

		end_time = time.time()
		elapsed_time = end_time - start_time
		print(f"Elapsed time: {elapsed_time:.6f} seconds")

	def __handle_emmc_flash(self, flashAddress):
		self.__writeSerialCmd('EM_E')
		self.__serialRead('Select area')
		self.__writeSerialCmd('1')
		self.__serialRead('>')

		# Changing speed to 921600 bps.
		self.__writeSerialCmd('SUP')
		self.__serialRead('the terminal.')

		self.__setupSerialPort_SUP()
		time.sleep(1)
		self.__writeSerialCmd('')
		self.__serialRead('>')

		# Write BL2
		BL2FlashAddress = flashAddress["BL2"]
		self.__writeSerialCmd('EM_W')
		self.__serialRead('Select area')
		self.__writeSerialCmd(BL2FlashAddress[0])

		self.__serialRead('Please Input Start Address in sector')
		self.__writeSerialCmd(BL2FlashAddress[1])

		self.__serialRead('Please Input Program Start Address')
		self.__writeSerialCmd(BL2FlashAddress[2])
		self.__serialRead('please send !')

		print("Writing BL2...")
		self.__writeFileToSerial(self.__args.bl2Image)
		self.__serialRead('>')

		# Write FIP
		FIPFlashAddress = flashAddress["FIP"]
		self.__writeSerialCmd('EM_W')
		self.__serialRead('Select area')
		self.__writeSerialCmd(FIPFlashAddress[0])

		self.__serialRead('Please Input Start Address in sector')
		self.__writeSerialCmd(FIPFlashAddress[1])

		self.__serialRead('Please Input Program Start Address')
		self.__writeSerialCmd(FIPFlashAddress[2])
		self.__serialRead('please send !')
		print("Writing fip ...")
		self.__writeFileToSerial(self.__args.fipImage)

		self.__serialRead('EM_W Complete!')

		# Write EXT_CSD
		self.__writeSerialCmd('EM_SECSD')
		self.__serialRead('Please Input EXT_CSD Index')
		self.__writeSerialCmd('B1')
		self.__serialRead('Please Input Value')
		self.__writeSerialCmd(FIPFlashAddress[3])
		self.__serialRead('>')

		self.__writeSerialCmd('EM_SECSD')
		self.__serialRead('Please Input EXT_CSD Index')
		self.__writeSerialCmd('B3')
		self.__serialRead('Please Input Value')
		self.__writeSerialCmd(FIPFlashAddress[4])
		self.__serialRead('>')

		# Write board identification
		BIDFlashAddress = flashAddress["BID"]
		self.__writeSerialCmd('EM_WB')
		self.__writeSerialCmd('EM_W')
		self.__serialRead('Select area')
		self.__writeSerialCmd(BIDFlashAddress[0])

		self.__serialRead('Please Input Start Address in sector')
		self.__writeSerialCmd(BIDFlashAddress[1])

		self.__serialRead('Please Input Program Start Address')
		self.__writeSerialCmd(BIDFlashAddress[2])
		self.__serialRead('please send ! (binary)')

		print("Writing board identification...")
		self.__writeFileToSerial(self.__args.bidImage)
		self.__serialRead('>')

	def __handle_qspi_flash(self, flashAddress):
		self.__writeSerialCmd('XCS')
		self.__serialRead('Clear OK?')
		self.__writeSerialCmd('y')
		self.__serialRead('>')

		# Changing speed to 921600 bps.
		self.__writeSerialCmd('SUP')
		self.__serialRead('the terminal.')

		self.__setupSerialPort_SUP()
		time.sleep(1)
		self.__writeSerialCmd('')
		self.__serialRead('>')

		# Write BL2
		BL2FlashAddress = flashAddress["BL2"]
		self.__writeSerialCmd('XLS2')
		self.__serialRead('Please Input : H')
		self.__writeSerialCmd(BL2FlashAddress[0])

		self.__serialRead('Please Input : H')
		self.__writeSerialCmd(BL2FlashAddress[1])
		self.__serialRead('please send !')

		print("Writing BL2...")
		self.__writeFileToSerial(self.__args.bl2Image)
		self.__serialRead('>')

		# Write FIP
		FIPFlashAddress = flashAddress["FIP"]
		self.__writeSerialCmd('XLS2')
		self.__serialRead('Please Input : H')
		self.__writeSerialCmd(FIPFlashAddress[0])

		self.__serialRead('Please Input : H')
		self.__writeSerialCmd(FIPFlashAddress[1])
		self.__serialRead('please send !')

		print("Writing fip ...")
		self.__writeFileToSerial(self.__args.fipImage)
		self.__serialRead('>')

		# Write board identification
		BIDFlashAddress = flashAddress["BID"]
		self.__writeSerialCmd('XLS3')
		self.__serialRead('Please Input : H')
		self.__writeSerialCmd(BIDFlashAddress[0])

		self.__serialRead('Please Input : H')
		self.__writeSerialCmd(BIDFlashAddress[1])
		self.__serialRead('please send ! (binary)')

		print("Writing board identification...")
		self.__writeFileToSerial(self.__args.bidImage)
		self.__serialRead('>')

	def __writeSerialCmd(self, cmd):
		self.__serialPort.write(f'{cmd}\r'.encode())

	# Function to write file over serial
	def __writeFileToSerial(self, file):
		with open(file, 'rb') as f:
			self.__serialPort.write(f.read())
			f.close()

	# Function to wait and print contents of serial buffer
	def __serialRead(self, cond='\n'):
		buf = self.__serialPort.read_until(cond.encode())

		if not buf:
			print(f"Returned value {cond} is not the expectation. Exiting.")
			exit()

		print(f'{buf.decode()}')

# Util function to die with error
def die(msg='', code=1):
	print(f'Error: {msg}')
	exit(code)

def main():
	bootloaderFlashUtil = BootloaderFlashUtil()

	bootloaderFlashUtil.writeBootloader()

if __name__ == '__main__':
	main()
