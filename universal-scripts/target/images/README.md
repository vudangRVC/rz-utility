# RZ images folder

## Description

This directory contains a collection of image files used for flashing, booting, and deploying the RZ platform on different target boards. It includes bootloader binaries (bl2_bp*.srec), firmware images (fip*.srec), flash writer utilities (\*.mot), device tree blobs (\*.dtb), and complete bootable system images (*.wic) for supported boards such as the RZG2L-SBC and RZG2L_EVK. Use the appropriate files based on your target hardware configuration.

## A top-level directory of images

```
images
├── bl2_bp-rzg2l-sbc.srec
├── bl2_bp-smarc-rzg2l_pmic.srec
├── core-image-minimal-rzg2l.wic
├── core-image-qt-rzg2l-sbc.wic
├── fip-rzg2l-sbc.srec
├── fip-smarc-rzg2l_pmic.srec
├── Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot
├── Flash_Writer_SCIF_rzg2l-sbc.mot
└── Readme.md                               <---- This document
```
