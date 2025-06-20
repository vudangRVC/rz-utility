# universal-scripts

Scripts for flashing RZ images, compatible with both Windows and Linux OS.

# Folder hierarchy:

```shell
universal_scripts
├── host
│   └── tools
│       ├── config
│       │   ├── boards_flash_config.toml
│       │   └── README.md
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
        ├── bl2_bp_rzg2l-evk.srec
        ├── bl2_bp_rzv2l-evk.srec
        ├── bl2_bp_spi_rzv2h-evk.srec
        ├── bl2_bp-rzg2l-sbc.srec
        ├── fip_rzg2l-evk.srec
        ├── fip_rzg2l-sbc.srec
        ├── fip_rzv2h-evk.srec
        ├── fip_rzv2l-evk.srec
        ├── Flash_Writer_SCIF_rzg2l-evk_PMIC.mot
        ├── Flash_Writer_SCIF_rzg2l-sbc.mot
        ├── Flash_Writer_SCIF_RZV2H_DEV_INTERNAL_MEMORY.mot
        ├── Flash_Writer_SCIF_rzv2l-evk_PMIC.mot
        ├── rzg2l-evk-platform-settings.bin
        ├── rzg2l-sbc-platform-settings.bin
        ├── rzv2h-evk-platform-settings.srec
        ├── rzv2l-evk-platform-settings.bin
        └── README.md
```
