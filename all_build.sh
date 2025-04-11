#!/bin/bash
# Map board name to BOARD_ID
get_board_id() {
    case "$1" in
        v2h)   echo 22 ;;
        v2l)   echo 33 ;;
        rzpi)  echo 44 ;;
        g2l)   echo 55 ;;
        g2lc)  echo 66 ;;
        g2ul)  echo 77 ;;
        *)     echo "Unknown board: $1" >&2; exit 1 ;;
    esac
}

# Check if argument provided
if [ -z "$1" ]; then
    echo "Usage: $0 <board>"
    exit 1
fi

BOARD_NAME="$1"
BOARD_ID=$(get_board_id "$BOARD_NAME")

# Replace the first line in board_info.txt with the BOARD_ID
sed -i "1s/.*/$BOARD_ID/" board_info.txt

# Build all the components for a specific SoC type
function main_process(){
    SOC_TYPE=$1
    get_board_id $SOC_TYPE
    ./build_flash_writer.sh  $SOC_TYPE
    ./build_atf.sh  $SOC_TYPE
    ./build_u-boot.sh  $SOC_TYPE
    ./merge_ipl_file.sh  $SOC_TYPE
}

#--start--------
# ./all_build.sh rzpi
# ./all_build.sh v2l
main_process $*

exit
#--end--------
