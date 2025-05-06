#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "cjson/cJSON.h"

#define MAX_STRING_LEN 255

// Pack a length-prefixed ASCII string
void write_string(FILE *out, const char *str) {
    size_t len = strlen(str);
    if (len > MAX_STRING_LEN) {
        fprintf(stderr, "String too long: %s\n", str);
        exit(EXIT_FAILURE);
    }    
    fwrite(&len, sizeof(uint8_t), 1, out);
    fwrite(str, sizeof(char), len, out);
}

// Helper to read int from JSON
int get_int(cJSON *json, const char *key) {
    cJSON *item = cJSON_GetObjectItemCaseSensitive(json, key);
    if (!cJSON_IsNumber(item)) {
        fprintf(stderr, "Missing or invalid int: %s\n", key);
        exit(EXIT_FAILURE);
    }
    return item->valueint;
}

// Helper to read string from JSON
const char* get_str(cJSON *json, const char *key) {
    cJSON *item = cJSON_GetObjectItemCaseSensitive(json, key);
    if (!cJSON_IsString(item)) {
        fprintf(stderr, "Missing or invalid string: %s\n", key);
        exit(EXIT_FAILURE);
    }
    return item->valuestring;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input.json> <output.bin>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Read JSON input
    FILE *f = fopen(argv[1], "rb");
    if (!f) {
        perror("Failed to open input JSON");
        return EXIT_FAILURE;
    }
    fseek(f, 0, SEEK_END);
    long file_len = ftell(f);
    if (file_len < 0) {
        perror("ftell failed");
        return EXIT_FAILURE;
    }
    size_t len = (size_t)file_len;
    rewind(f);    
    char *json_data = (char *)malloc(len + 1);
    if (fread(json_data, 1, len, f) != len) {
        fprintf(stderr, "Failed to read entire JSON file.\n");
        exit(EXIT_FAILURE);
    }    
    json_data[len] = '\0';
    fclose(f);

    // Parse JSON
    cJSON *json = cJSON_Parse(json_data);
    if (!json) {
        fprintf(stderr, "JSON parse error: %s\n", cJSON_GetErrorPtr());
        return EXIT_FAILURE;
    }

    FILE *out = fopen(argv[2], "wb");
    if (!out) {
        perror("Failed to open output file");
        return EXIT_FAILURE;
    }

    // Write binary fields
    uint8_t model_id = get_int(json, "model_id");
    uint16_t rev_minor = get_int(json, "revision_minor");
    uint16_t rev_major = get_int(json, "revision_major");
    fwrite(&model_id, sizeof(uint8_t), 1, out);
    fwrite(&rev_minor, sizeof(uint16_t), 1, out);
    fwrite(&rev_major, sizeof(uint16_t), 1, out);

    write_string(out, get_str(json, "model_string"));
    write_string(out, get_str(json, "mfg_name"));

    uint8_t locs[6] = {
        get_int(json, "bl2_loc"),
        get_int(json, "bl2_dtb_loc"),
        get_int(json, "u_boot_loc"),
        get_int(json, "u_boot_dtb_loc"),
        get_int(json, "kernel_loc"),
        get_int(json, "kernel_dtb_loc")
    };
    fwrite(locs, sizeof(uint8_t), 6, out);

    uint16_t ids[6] = {
        get_int(json, "bl2_id"),
        get_int(json, "bl2_dtb_id"),
        get_int(json, "u_boot_id"),
        get_int(json, "u_boot_dtb_id"),
        get_int(json, "kernel_id"),
        get_int(json, "kernel_dtb_id")
    };
    fwrite(ids, sizeof(uint16_t), 6, out);

    write_string(out, get_str(json, "bl2_desc"));
    write_string(out, get_str(json, "bl2_dtb_desc"));
    write_string(out, get_str(json, "u_boot_desc"));
    write_string(out, get_str(json, "u_boot_dtb_desc"));
    write_string(out, get_str(json, "kernel_desc"));
    write_string(out, get_str(json, "kernel_dtb_desc"));

    fclose(out);
    cJSON_Delete(json);
    free(json_data);

    printf("Binary file written to %s\n", argv[2]);
    return EXIT_SUCCESS;
}
