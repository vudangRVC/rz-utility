# Ipl_build_script
Build IPL for rzv2l rzpi

# Install env
sudo apt update
sudo apt install binwalk -y
sudo apt install python3-pip -y
sudo pip3 install pyserial
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Build binaries for rzpi
./all_build.sh rzpi 

# Burn IPL for rzpi
./write_ipl.sh --serial_port /dev/ttyUSB1 --image_writer Flash_Writer_SCIF_rzpi.mot --image_bl2 bl2_bp_rzpi.srec --image_fip fip_rzpi.srec

# Build binaries for rzv2l
./all_build.sh v2l 

# Burn IPL for rzv2l
./write_ipl.sh --serial_port /dev/ttyUSB1 --image_writer Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot --image_bl2 bl2_bp_v2l.srec --image_fip fip_v2l.srec
