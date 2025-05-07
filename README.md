
# IPL Build and Flash Script for RZ Boards

This guide provides instructions to build and flash the Initial Program Loader (IPL) for various Renesas RZ boards, including **RZ/V2L**, **RZ/G2L**, **RZ/G2L-100**, and **RZPi**.

## Environment Setup

Install required packages:

```bash
sudo apt update
sudo apt install -y binwalk python3-pip
sudo pip3 install pyserial
```

Install OpenSSL 1.1 (required by some flash utilities):

```bash
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
```

---

## Build Instructions

Run the following scripts to build the IPL binaries for each board.

### RZPi

```bash
./all_build.sh rzpi
```

### RZ/V2L

```bash
./all_build.sh v2l
```

### RZ/G2L

```bash
./all_build.sh g2l
```

### RZ/G2L-100

```bash
./all_build.sh g2l100
```

### RZ/V2H

```bash
./all_build.sh v2h
```

---

## Flashing Instructions

Use `write_ipl.sh` to flash IPL over UART.

### RZPi

```bash
./write_ipl.sh \
  --serial_port /dev/ttyUSB0 \
  --image_writer Flash_Writer_SCIF_rzpi.mot \
  --image_bl2 bl2_bp_rzpi.srec \
  --image_fip fip_rzpi.srec
```

### RZ/V2L

```bash
./write_ipl.sh \
  --serial_port /dev/ttyUSB0 \
  --image_writer Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot \
  --image_bl2 bl2_bp_v2l.srec \
  --image_fip fip_v2l.srec
```

### RZ/G2L

```bash
./write_ipl.sh \
  --serial_port /dev/ttyUSB0 \
  --image_writer Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot \
  --image_bl2 bl2_bp_g2l.srec \
  --image_fip fip_g2l.srec
```

### RZ/G2L-100

```bash
./write_ipl.sh \
  --serial_port /dev/ttyUSB0 \
  --image_writer Flash_Writer_SCIF_RZG2L_15MMSQ_DEV_DDR4_4GB.mot \
  --image_bl2 bl2_bp_g2l100.srec \
  --image_fip fip_g2l100.srec
```

### RZ/V2H

```bash
  lsblk
  sudo dd if=bl2_bp_esd_v2h.bin of=/dev/sdb bs=512 seek=1 conv=notrunc
  sudo dd if=fip_v2h.bin of=/dev/sdb bs=512 seek=768 conv=notrunc
  sudo eject /dev/sdb
```

---

## Notes

- Make sure the correct USB-to-Serial device (`/dev/ttyUSBx`) is selected.
- The flash writer `.mot` files and `.srec` binaries must be generated or placed in the working directory.
- If you're flashing multiple boards, disconnect/reconnect the USB cable to reset the serial connection as needed.

---

## License

Please refer to Renesas documentation for board-specific configurations and safety guidelines.
