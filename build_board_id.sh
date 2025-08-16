#!/bin/bash

WORKPWD=$(pwd)
build_board_id()
{
    # Set model based on the board
    BOARD=$1
    if [ "${BOARD}" == "v2l-evk" ] ; then
        MODEL="RZV2L-evk"
    elif [ "${BOARD}" == "g2l-sbc" ] ; then
        MODEL="RZG2L-SBC"
    elif [ "${BOARD}" == "g2l-evk" ] ; then
        MODEL="RZG2L-evk"
    elif [ "${BOARD}" == "g2l-100" ] ; then
        MODEL="RZG2L-100"
    elif [ "${BOARD}" == "v2h-evk" ] ; then
        MODEL="RZV2H-evk1"
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
    fi

    # Build bin file from platform_info.json
    cd ${WORKPWD}/tools/binmake
    rm -rf ${WORKPWD}/tools/binmake/build
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

validate_board_id() {
    BOARD=$1
    case "${BOARD}" in
        v2h-evk|v2l-evk|g2l-sbc|g2l-evk|g2l-100)
            return 0
            ;;
        *)
            echo "BOARD is not supported"
            echo "Please use one of: v2h-evk, g2l-sbc, v2l-evk, g2l-evk, g2l-100"
            echo "Example: ./all_build.sh v2h-evk"
            echo "Example: ./all_build.sh g2l-sbc"
            echo "Example: ./all_build.sh v2l-evk"
            echo "Example: ./all_build.sh g2l-evk"
            echo "Example: ./all_build.sh g2l-100"
            exit 1
            ;;
    esac
}

function main_process(){
    BOARD=$1
    validate_board_id "${BOARD}"
    build_board_id $BOARD
}

#--start--------
# ./build_board_id.sh v2h-evk
# ./build_board_id.sh v2l-evk
# ./build_board_id.sh g2l-sbc
# ./build_board_id.sh g2l-evk
# ./build_board_id.sh g2l-100
main_process $*

exit
#---- end ------