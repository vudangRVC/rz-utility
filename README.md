# rz-utility
The RZ utilities for development

# install tool
sudo apt update
sudo apt install lzop
sudo apt install srecord
sudo apt install libssl3

# Build IPL for v2l
./build_flash_writer.sh v2l
./build_atf.sh v2l
./build_u-boot.sh v2l

# merge fip
./merge_ipl_file.sh v2l

# burn to board
./write_ipl.sh
