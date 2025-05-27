#!/bin/bash

source ./config.ini
source ./common.sh

# Check Linux Kernel location
if [ -z "${KERNEL_DIR}" ]; then
        echo "There is no Linux Kernel source at ${KERNEL_DIR} or it does not set properly at config.ini file."
        echo "Please recheck your setup"
        exit 1
fi

# Setup the build
kernel_setup() {
        CONFIG_LOCALVERSION='CONFIG_LOCALVERSION="-yocto-standard"'
        CONFIG_LOCALVERSION_AUTO='CONFIG_LOCALVERSION_AUTO=n'
        FILE="arch/arm64/configs/defconfig"

        # Remove '+' at the end of kernel version
        #touch .scmversion
        export LOCALVERSION=""

        # Update defconfig to compatible with rootfs
        if grep -q "$CONFIG_LOCALVERSION" "$FILE"; then
                echo "Already set $CONFIG_LOCALVERSION"
        else
                echo "$CONFIG_LOCALVERSION" >> "$FILE"
                echo "Appended $CONFIG_LOCALVERSION to $FILE"
        fi

        if grep -q "$CONFIG_LOCALVERSION_AUTO" "$FILE"; then
                echo "Already set $CONFIG_LOCALVERSION_AUTO"
        else
                echo "$CONFIG_LOCALVERSION_AUTO" >> "$FILE"
                echo "Appended $CONFIG_LOCALVERSION_AUTO to $FILE"
        fi
}

mk_image() {
        echo '|============================================|'
        echo '|          Build IMAGE Yocto-standard        |'
        echo '|============================================|'
        make -j16 Image
}

mk_dtbs() {
        echo '|============================================|'
        echo '|             Build device tree              |'
        echo '|============================================|'
        make -j8 dtbs
}

mk_full_image() {
        kernel_setup
        make defconfig
        echo '|============================================|'
        echo '|          Build IMAGE Yocto-standard        |'
        echo '|============================================|'
        make -j16 Image
        echo '|============================================|'
        echo '|             Build device tree              |'
        echo '|============================================|'
        make -j8 dtbs
}

mk_clean() {
        make clean
}

mk_distclean() {
        make distclean
}

mk_defconfig() {
        kernel_setup
        make defconfig
}

mk_menuconfig() {
        kernel_setup
        make menuconfig
}

mk_modules() {
        kernel_setup
        make defconfig
        mk_full_image
        echo '|============================================|'
        echo '|               Build modules                |'
        echo '|============================================|'
        make -j16 modules
        echo "Build completed successfully"
}

# Main Linux Kernel build
echo "Starting the kernel build at ${KERNEL_DIR}"
cd "${KERNEL_DIR}" || exit 1

case ${1} in
        'clean')
                mk_clean
                ;;
        'distclean')
                mk_distclean
                ;;
        'defconfig')
                mk_defconfig
                ;;
        'menuconfig')
                mk_menuconfig
                ;;
        'image')
                mk_image
                ;;
        'dtbs')
                mk_dtbs
                ;;
        'all')
                mk_full_image
                ;;
        'modules')
                mk_modules
                ;;
        *)
                show_help
                ;;
esac

exit 0
