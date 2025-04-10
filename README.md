# rzv2l_ipl_build_script
Build IPL for rzv2l board

# Install env
sudo apt update
sudo apt install binwalk -y
sudo apt install python3-pip -y
sudo pip3 install pyserial
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# build
./build_flash_writer.sh v2l
./build_atf.sh v2l
./build_u-boot.sh v2l
./merge_ipl_file.sh v2l

# burn_IPL
sudo ./write_ipl.sh
