#!/bin/bash

source ./config.ini

_usage="
Usage: 

$ ./main_build.sh <target_build> <sub_command> 

Option:
    <target_build>:
        1. kernel
            Build for Linux Kernel
            <sub_command>:
                - clean
                - distclean
                - defconfig
                - menuconfig
                - image
                - dtbs
                - full-image
                - modules

        2. uboot
            Build for U-Boot
            <sub_command>:
                - clean
                - disclean
                - defconfig
                - image
                - full-image

        3. atf
            Build for ATF
            <sub_command>:
                - 
                - 

        4. flash-writer
            Build for Flash-Writer
            <sub_command>:
                - 
                - 

        5. build-all
            Build for all software stacks (Linux Kernel, U-Boot, ATF, Flash-Writer)
            <sub_command>: None

        6. clean-all
            Clean for all software stacks (Linux Kernel, U-Boot, ATF, Flash-Writer)
            <sub_command>: None

For example: 
    Build all images (Kernel image and device tree) for the Linux Kernel:
        $ ./main-build.sh kernel full-image

    Clean the Linux Kernel (Kernel image and device tree) output:
        $ ./main-build.sh kernel clean

Note: Before executing the build, please make sure that you have updated the configuration file: config.ini at the top of the build scripts folder.
"
# Help message
show_help() {
        echo 'Error: Invalid Syntax!'
        echo "${_usage}"
        exit 1
}

# POKY setup
if [ ! -d "${SDK_LOCATION}" ];then
        echo "There is no installed SDK at ${SDK_LOCATION} or it does not set properly at config.ini file."
        echo "Please recheck your setup"
        exit 1
fi

TOOLCHAIN=${SDK_LOCATION}/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux
export PATH=${TOOLCHAIN}:${PATH}
export ARCH=arm64
export CROSS_COMPILE=${TOOLCHAIN}/aarch64-poky-linux-
export KERNEL_CROSS_COMPILE=${CROSS_COMPILE}

# Main process
echo "Starting the build script at $(pwd)"
if [ -z "${1}" ] ; then
        show_help
else
        if [ -z "${2}" ]; then
                show_help
        else
                if [ "${1}" = "kernel" ] || [ "${1}" = "uboot" ] || [ "${1}" = "atf" ] || [ "${1}" = "flash-writer" ]; then
                        case ${1} in
                                "kernel")
                                        ./build_kernel.sh "${2}"
                                        ;;
                                "uboot")
                                        ./build_uboot.sh "${2}"
                                        ;;
                                "atf")
                                        ./build_atf.sh "${2}"
                                        ;;
                                "flash-writer")
                                        ./build_flash_writer.sh "${2}"
                                        ;;
                        esac
                elif [ "${1}" = "build-all" ] || [ "${1}" = "clean-all" ]; then
                        case ${1} in
                                "build-all")
                                        ./build_kernel.sh "mk_full_image"
                                        ./build_uboot.sh "mk_full_image"
                                        ./build_atf.sh ""
                                        ./build_atf.sh ""
                                        ;;
                                "clean-all")
                                        ./build_kernel.sh "mk_distclean"
                                        ./build_uboot.sh "mk_distclean"
                                        ./build_atf.sh ""
                                        ./build_atf.sh ""
                                        ;;
                        esac
                else
                        show_help
                fi
        fi
fi

exit 0