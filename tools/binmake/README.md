# Using binmake tool to convert platform_info.json into binary

Build binmake tool:

```bash
cd binmake
make binmake
```

- Output:

```bash
binmake
├── binmake                 <--- Target tool 
├── binmake.c
├── cjson
│   ├── cJSON.c
│   └── cJSON.h
├── Makefile
└── platform_info.json
```

Convert platform_info.json into binary file for specific board:

If you're using RZ/G2L-SBC, run:

```bash
./binmake --input=platform_info.json --board=RZG2L-SBC --output=RZG2L-SBC.bin
```

If you're using RZ/G2L-EVK, run:

```bash
./binmake --input=platform_info.json --board=RZG2L-EVK --output=RZG2L-EVK.bin
```

- Output:

```bash
binmake
├── binmake
├── binmake.c
├── cjson
│   ├── cJSON.c
│   └── cJSON.h
├── Makefile
├── RZG2L-SBC.bin           <--- Output binary 
├── RZG2L-EVK.bin           <--- Output binary 
└── platform_info.json
```
