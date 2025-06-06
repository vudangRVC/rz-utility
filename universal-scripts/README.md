# universal-scripts

Scripts for flashing RZ images, compatible with both Windows and Linux OS.

Folder hierarchy:

```shell
universal_scripts
├── host
│   └── tools
│       ├── bootloader-flasher
│       │   ├── bootloader_flash.py
│       │   └── README.md
│       ├── sd-creator
│       │   ├── sd_flash.py
│       │   └── README.md
│       ├── uload-bootloader
│       │   ├── uload_bootloader_flash.py
│       │   └── README.md
│       ├── flash_images.json
│       ├── README.md
│       └── universal_flash.py
└── target
    └── images
        ├── bl2_bp-rzg2l-sbc.srec
        ├── bl2_bp-smarc-rzg2l_pmic.srec
        ├── core-image-minimal-rzg2l.wic
        ├── core-image-qt-rzg2l-sbc.wic
        ├── fip-rzg2l-sbc.srec
        ├── fip-smarc-rzg2l_pmic.srec
        ├── Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot
        ├── Flash_Writer_SCIF_rzg2l-sbc.mot
        ├── r9a07g044l2-smarc.dtb
        └── rzg2l-sbc.dtb
```