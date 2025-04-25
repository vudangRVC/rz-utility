#!/bin/bash
source ./common.sh

# Build all the components for a specific SoC type
function main_process(){
    SOC_TYPE=$1
    validate_soc_type "${SOC_TYPE}"
    ./build_flash_writer.sh  $SOC_TYPE
    ./build_atf.sh  $SOC_TYPE
    ./build_u-boot.sh  $SOC_TYPE
    ./merge_ipl_file.sh  $SOC_TYPE
}

#--start--------
# ./all_build.sh v2h
# ./all_build.sh v2l
# ./all_build.sh rzpi
# ./all_build.sh g2l
# ./all_build.sh g2l100
main_process $*

exit
#--end--------
