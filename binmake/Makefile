CC = gcc
CFLAGS = -Wall -Wextra -O2 -Iutils/cjson
TARGET = binmake
SRC = binmake.c cjson/cJSON.c

CJSON_URL = https://raw.githubusercontent.com/DaveGamble/cJSON/master
CJSON_DIR = cjson
CJSON_FILES = cJSON.c cJSON.h

.PHONY: all clean cjson

all: $(CJSON_DIR)/cJSON.c $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

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
