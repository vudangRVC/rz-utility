#!/bin/bash

WORKPWD=$(pwd)
build_board_id()
{
    # Set model based on the board
    BOARD=$1
    if [ "${BOARD}" == "v2l" ] ; then
        MODEL="RZV2L-EVK"
    elif [ "${BOARD}" == "rzpi" ] ; then
        MODEL="RZG2L-SBC"
    elif [ "${BOARD}" == "g2l" ] ; then
        MODEL="RZG2L-EVK"
    elif [ "${BOARD}" == "g2l100" ] ; then
        MODEL="RZG2L-100"
    elif [ "${BOARD}" == "v2h" ] ; then
        MODEL="RZV2H-EVK1"
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
    fi

    # Build bin file from platform_info.json
    cd ${WORKPWD}/tools/binmake
    if [ ! -d build ]; then
        mkdir -p ${WORKPWD}/tools/binmake/build
    fi

    cd ${WORKPWD}/tools/binmake/build
    cmake ..
    make -j12
    ./binmake --input=../platform_info.json --board=${MODEL} --output=${MODEL}.bin
    if [ $? -ne 0 ]; then
        echo "Error: Failed to build board ID for ${MODEL}"
        exit 1
    fi
    echo "Board ID for ${MODEL} has been built successfully."
    objcopy -I binary -O srec --adjust-vma=0x00000 --srec-forceS3 ${MODEL}.bin ${MODEL}.srec
    echo "Board ID for ${MODEL} has been converted to SREC format."
    cp ${MODEL}.srec ${WORKPWD}
}

function main_process(){
    BOARD=$1
    build_board_id $BOARD
}

#--start--------
# ./build_board_id.sh v2h
# ./build_board_id.sh v2l
# ./build_board_id.sh rzpi
# ./build_board_id.sh g2l
# ./build_board_id.sh g2l100
main_process $*

exit
#---- end ------