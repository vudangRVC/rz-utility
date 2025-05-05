# Ipl_build_script
Build IPL for rzv2l rzpi

# Install env
sudo apt update
sudo apt install binwalk -y
sudo apt install python3-pip -y
sudo pip3 install pyserial
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# RZPI ----------------------------------------------------------------------------------------------------------------------------------
# Build binaries for rzpi
./all_build.sh rzpi 

# Burn IPL for rzpi
./write_ipl.sh --serial_port /dev/ttyUSB1 --image_writer Flash_Writer_SCIF_rzpi.mot --image_bl2 bl2_bp_rzpi.srec --image_fip fip_rzpi.srec

# RZV2L ----------------------------------------------------------------------------------------------------------------------------------
# Build binaries for rzv2l
./all_build.sh v2l

# Burn IPL for rzv2l
./write_ipl.sh --serial_port /dev/ttyUSB1 --image_writer Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot --image_bl2 bl2_bp_v2l.srec --image_fip fip_v2l.srec

# RZG2L ----------------------------------------------------------------------------------------------------------------------------------
# Build binaries for rzg2l
./all_build.sh g2l

# Burn IPL for rzg2l
./write_ipl.sh --serial_port /dev/ttyUSB1 --image_writer Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot --image_bl2 bl2_bp_g2l.srec --image_fip fip_g2l.srec

# RSG2L-100 ----------------------------------------------------------------------------------------------------------------------------------
# Build binaries for g2l100
./all_build.sh g2l100

# Burn IPL for g2l100
./write_ipl.sh --serial_port /dev/ttyUSB1 --image_writer Flash_Writer_SCIF_RZG2L_15MMSQ_DEV_DDR4_4GB.mot --image_bl2 bl2_bp_g2l100.srec --image_fip fip_g2l100.srec
