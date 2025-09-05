
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

### RZV2L-EVK

```bash
./all_build.sh v2l-evk
```

### RZV2H-EVK1

```bash
./all_build.sh v2h-evk
```

### RZG2L-EVK

```bash
./all_build.sh g2l-evk
```

### RZG2L-SBC

```bash
./all_build.sh g2l-sbc
```

### RZG2L-100

```bash
./all_build.sh g2l-100
```

---

## Flashing Instructions

Use `write_ipl.sh` to flash IPL over UART.

### RZ/V2H - Burn to SD card

```bash
lsblk
sudo dd if=/dev/zero of=/dev/sdX bs=512 seek=1 count=3000
sudo sync /dev/sdX
sudo dd if=bl2_bp_esd_v2h.bin of=/dev/sdX bs=512 seek=1 conv=notrunc
sudo dd if=fip_v2h.bin of=/dev/sdX bs=512 seek=768 conv=notrunc
sudo sync /dev/sdX
```

### RZV2L-EVK

```bash
./write_ipl.sh v2l-evk
```


### RZG2L-EVK

```bash
./write_ipl.sh g2l-evk
```

### RZG2L-SBC

```bash
./write_ipl.sh g2l-sbc
```

### RZG2L-100

```bash
./write_ipl.sh g2l-100
```

---

## Notes

- The correct USB-to-Serial device (`/dev/ttyUSB0`) is default selected.
- The flash writer `.mot` files and `.srec` binaries must be generated or placed in the working directory.
- If you're flashing multiple boards, disconnect/reconnect the USB cable to reset the serial connection as needed.

---

## License

Please refer to Renesas documentation for board-specific configurations and safety guidelines.
