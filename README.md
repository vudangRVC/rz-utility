# rzv2l_ipl_build_script
Build IPL for rzv2l board

# Install env
sudo apt update
sudo apt install binwalk -y
sudo apt install python3-pip -y
sudo pip3 install pyserial

# build
./build_flash_writer.sh v2l
./build_atf.sh v2l
./build_u-boot.sh v2l
./merge_ipl_file.sh v2l

# burn_IPL
./write_ipl.sh v2l
