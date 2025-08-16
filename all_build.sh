#!/bin/bash
source ./common.sh

# Build all the components for a specific SoC type
function main_process(){
    BOARD=$1
    # Remove old files
    if compgen -G "*.srec" > /dev/null; then
        rm *.srec
    fi
    if compgen -G "*.bin" > /dev/null; then
        rm *.bin
    fi
    # Validate the board type
    validate_board "${BOARD}"

    # Build the board id
    ./build_board_id.sh $BOARD

    #  Set the toolchain
    set_toolchain

    # Build the atf
    ./build_atf.sh $BOARD

    # Build the u-boot
    ./build_u-boot.sh $BOARD

    # Merge the u-boot and atf
    if [ "${BOARD}" == "v2h-evk" ] ; then
        ./v2h_merge_ipl_file.sh $BOARD
    else
        ./build_flash_writer.sh $BOARD
        ./merge_ipl_file.sh $BOARD
    fi
}

#--start--------
# ./all_build.sh v2h-evk
# ./all_build.sh v2l-evk
# ./all_build.sh g2l-sbc
# ./all_build.sh g2l-evk
# ./all_build.sh g2l-100
main_process $*

exit
#--end--------
