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
SRC = binmake.c $(CJSON_DIR)/cJSON.c

BOARD ?= RZG2L-SBC
INPUT_JSON = platform_info.json
OUTPUT_BIN = $(BOARD).bin

################################################################################
# 3rd party library
################################################################################
CJSON_URL = https://raw.githubusercontent.com/DaveGamble/cJSON/master
CJSON_DIR = cjson
CJSON_FILES = cJSON.c cJSON.h

.PHONY: all clean

all: $(OUTPUT_BIN)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

$(OUTPUT_BIN): binmake $(INPUT_JSON)
	./binmake --input=$(INPUT_JSON) --board=$(BOARD) --output=$(OUTPUT_BIN)

# Download cJSON files if not already present
$(CJSON_DIR)/cJSON.c:
	@mkdir -p $(CJSON_DIR)
	@echo "Downloading cJSON sources..."
	@for file in $(CJSON_FILES); do \
		wget -q -O $(CJSON_DIR)/$$file $(CJSON_URL)/$$file; \
	done
	@echo "Download complete."

clean:
	rm -f $(TARGET)
	rm -rf $(CJSON_DIR)
	rm -rf *.bin
