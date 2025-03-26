# rzv2h_ipl_build_script
Build IPL for rzv2h board

# Install env
sudo apt update
sudo apt install binwalk -y
sudo apt install python3-pip -y
sudo pip3 install pyserial

# build
./build_flash_writer.sh v2h
./build_atf.sh v2h
./build_u-boot.sh v2h
./merge_ipl_file.sh v2h

# burn_IPL
sudo ./write_ipl.sh
