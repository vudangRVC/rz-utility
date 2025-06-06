#!/usr/bin/python3

# Imports
import serial
import argparse
import time
from serial.tools.list_ports import comports

class UloadFlashUtil:
	def __init__(self, args=None):
		self.__setupArgumentParser(args)
		self.__setupSerialPort()

	# Setup CLI parser
	def __setupArgumentParser(self, args):
		# Create parser
		self.__parser = argparse.ArgumentParser(description='Util to flash bootloader from U-Boot console on RZ Board.\n', epilog='Example:\n\t./uload_bootloader_flash.py')

		# Add arguments
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
				self.__serialPort = serial.Serial(port= ports[0], baudrate = self.__args.baudRate, timeout=15)
			else:
				self.__serialPort = serial.Serial(port=self.__args.serialPort, baudrate = self.__args.baudRate, timeout=15)
		except:
			die(msg='Unable to open serial port.')

	# Function to write bootloader
	def writeUloadBootloader(self):
		start_time = time.time()

		# Wait for device to be ready to receive image.
		print('Please power on board. Make sure you changed switches to normal boot mode.')
		self.__serialRead('Hit any key to stop autoboot:')
		self.__writeSerialCmd('')

		self.__serialRead('=>')

		# sf probe
		self.__writeSerialCmd('sf probe')
		self.__serialRead('MiB')

		# true
		self.__writeSerialCmd('true')
		self.__serialRead('=>')

		# sf erase
		print('erase QSPI: please wait a minute...')
		start_time_erase = time.time()
		self.__writeSerialCmd('sf erase 0 100000')
		self.__serialRead('OK')
		end_time_erase = time.time()
		erase_time = end_time_erase - start_time_erase
		print(f"erase time: {erase_time:.6f} seconds")

		# true
		self.__writeSerialCmd('true')
		self.__serialRead('=>')

		# loading bl2...
		self.__writeSerialCmd('fatload mmc 0:1 0x48000000 boot/uload-bootloader/bl2_bp-rzg2l-sbc.bin')
		self.__serialRead('MiB/s)')

		# true
		self.__writeSerialCmd('true')
		self.__serialRead('=>')

		# writing bl2...
		self.__writeSerialCmd('sf write 0x48000000 0 $filesize')
		self.__serialRead('OK')

		# true
		self.__writeSerialCmd('true')
		self.__serialRead('=>')

		# loading fip...
		self.__writeSerialCmd('fatload mmc 0:1 0x48000000 boot/uload-bootloader/fip-rzg2l-sbc.bin')
		self.__serialRead('MiB/s)')

		# true
		self.__writeSerialCmd('true')
		self.__serialRead('=>')

		# writing fip...
		self.__writeSerialCmd('sf write 0x48000000 1d200 $filesize')
		self.__serialRead('OK')

		# true
		self.__writeSerialCmd('true')
		self.__serialRead('=>')

		# Closed serial port.
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
	def __serialRead(self, cond='\n'):
		buf = self.__serialPort.read_until(cond.encode())

		if not buf:
			print("Returned value is not the expectation. Exiting.")
			exit()

		print(f'{buf.decode()}')

# Util function to die with error
def die(msg='', code=1):
	print(f'Error: {msg}')
	exit(code)

def main():
	uloadFlashUtil = UloadFlashUtil()

	uloadFlashUtil.writeUloadBootloader()

if __name__ == '__main__':
	main()
