#
# Copyright (c) 2025, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

################################################################################
# Default values for build configurations
################################################################################
CC = gcc
CFLAGS = -Wall -Wextra -O2 -Iutils/cjson
TARGET = binmake
SRC = binmake.c cjson/cJSON.c

BOARD ?= RZG2L-SBC
INPUT_JSON = platform_info.json
OUTPUT_BIN = $(BOARD).bin

.PHONY: all clean

all: $(OUTPUT_BIN)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

$(OUTPUT_BIN): binmake $(INPUT_JSON)
	./binmake --input=$(INPUT_JSON) --board=$(BOARD) --output=$(OUTPUT_BIN)

clean:
	rm -f $(TARGET)
	rm -rf *.bin
