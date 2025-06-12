#!/bin/bash
source ./common.sh

# Build all the components for a specific SoC type
function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    ./build_board_id.sh $BOARD

    set_toolchain

    ./build_atf.sh $BOARD
    ./build_u-boot.sh $BOARD

    if [ "${BOARD}" == "v2h" ] ; then
        ./v2h_merge_ipl_file.sh $BOARD
    else
        ./build_flash_writer.sh $BOARD
        ./merge_ipl_file.sh $BOARD
    fi
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
