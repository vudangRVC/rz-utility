#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/stat.h>
#include "cjson/cJSON.h"

#define MAX_STRING_LEN 255

typedef enum { FIELD_U8, FIELD_STRING } FieldType;

typedef struct {
    const char *key;
    FieldType type;
} FieldDesc;

FieldDesc fields[] = {
    {"model_id"         , FIELD_U8      },
    {"revision_minor"   , FIELD_U8      },
    {"revision_major"   , FIELD_U8      },
    {"model_string"     , FIELD_STRING  },
    {"mfg_name"         , FIELD_STRING  },
    {"bl2_loc"          , FIELD_U8      },
    {"bl2_dtb_loc"      , FIELD_U8      },
    {"u_boot_loc"       , FIELD_U8      },
    {"u_boot_dtb_loc"   , FIELD_U8      },
    {"kernel_loc"       , FIELD_U8      },
    {"kernel_dtb_loc"   , FIELD_U8      },
    {"bl2_id"           , FIELD_U8      },
    {"bl2_dtb_id"       , FIELD_U8      },
    {"u_boot_id"        , FIELD_U8      },
    {"u_boot_dtb_id"    , FIELD_U8      },
    {"kernel_id"        , FIELD_U8      },
    {"kernel_dtb_id"    , FIELD_U8      },
    {"bl2_desc"         , FIELD_STRING  },
    {"bl2_dtb_desc"     , FIELD_STRING  },
    {"u_boot_desc"      , FIELD_STRING  },
    {"u_boot_dtb_desc"  , FIELD_STRING  },
    {"kernel_desc"      , FIELD_STRING  },
    {"kernel_dtb_desc"  , FIELD_STRING  },
};

void write_string(FILE *out, const char *str) {
    size_t len = strlen(str);
    if (len > MAX_STRING_LEN) {
        fprintf(stderr, "String too long: %s\n", str);
        exit(EXIT_FAILURE);
    }
    uint8_t len8 = (uint8_t)len;
    fwrite(&len8, sizeof(uint8_t), 1, out);
    fwrite(str, sizeof(char), len, out);
}

void print_help(const char *prog_name) {
    printf("Usage: %s --input=platform_info.json --board=BOARD_NAME --output=BOARD_NAME.bin\n", prog_name);
    printf("Options:\n");
    printf("  --input=FILE      Path to input JSON file containing board information\n");
    printf("  --board=NAME      Board name to select from the JSON file\n");
    printf("  --output=FILE     Path to output binary file\n");
    printf("  -h, --help        Show this help message and exit\n");
}

int main(int argc, char *argv[]) {
    const char *json_path = NULL;
    const char *board_name = NULL;
    const char *output_path = NULL;

    for (int i = 1; i < argc; i++) {
        if (strncmp(argv[i], "--input=", 8) == 0) {
            json_path = argv[i] + 8;
        } else if (strncmp(argv[i], "--board=", 8) == 0) {
            board_name = argv[i] + 8;
        } else if (strncmp(argv[i], "--output=", 9) == 0) {
            output_path = argv[i] + 9;
        } else if ((strcmp(argv[i], "-h") == 0) || (strcmp(argv[i], "--help") == 0)) {
            print_help(argv[0]);
            return EXIT_SUCCESS;
        } else {
            fprintf(stderr, "Unknown option: %s\n", argv[i]);
            print_help(argv[0]);
            return EXIT_FAILURE;
        }
    }    

    if (!json_path || !board_name || !output_path) {
        print_help(argv[0]);
        return EXIT_FAILURE;
    }

    FILE *f = fopen(json_path, "rb");
    if (!f) {
        perror("Failed to open input JSON");
        return EXIT_FAILURE;
    }

    fseek(f, 0, SEEK_END);
    long file_len = ftell(f);
    if (file_len < 0) {
        perror("ftell failed");
        fclose(f);
        return EXIT_FAILURE;
    }
    size_t len = (size_t)file_len;
    rewind(f);

    char *json_data = (char *)malloc(len + 1);
    if (!json_data) {
        perror("malloc failed");
        fclose(f);
        return EXIT_FAILURE;
    }

    if (fread(json_data, 1, len, f) != len) {
        fprintf(stderr, "Failed to read entire JSON file.\n");
        free(json_data);
        fclose(f);
        return EXIT_FAILURE;
    }
    json_data[len] = '\0';
    fclose(f);

    cJSON *root_all = cJSON_Parse(json_data);
    if (!root_all) {    
        fprintf(stderr, "JSON parsing error\n");
        free(json_data);
        return EXIT_FAILURE;
    }

    cJSON *root = cJSON_GetObjectItem(root_all, board_name);
    if (!root) {
        fprintf(stderr, "Board '%s' not found in JSON.\n", board_name);
        fprintf(stderr, "Available boards:\n");
        cJSON *child = root_all->child;
        while (child) {
            if (cJSON_IsObject(child)) {
                fprintf(stderr, "  - %s\n", child->string);
            }
            child = child->next;
        }
        cJSON_Delete(root_all);
        free(json_data);
        return EXIT_FAILURE;
    }

    FILE *out = fopen(output_path, "wb");
    if (!out) {
        perror("Failed to open output file");
        cJSON_Delete(root_all);
        free(json_data);
        return EXIT_FAILURE;
    }

    size_t field_count = sizeof(fields) / sizeof(fields[0]);
    for (size_t i = 0; i < field_count; i++) {
        const char *key = fields[i].key;
        cJSON *item = cJSON_GetObjectItem(root, key);
        if (!item) {
            fprintf(stderr, "Missing field: %s\n", key);
            fclose(out);
            cJSON_Delete(root_all);
            free(json_data);
            return EXIT_FAILURE;
        }

        if (fields[i].type == FIELD_U8) {
            uint8_t val = (uint8_t)item->valueint;
            fwrite(&val, sizeof(uint8_t), 1, out);
        } else if (fields[i].type == FIELD_STRING) {
            write_string(out, item->valuestring);
        }
    }

    fclose(out);
    cJSON_Delete(root_all);
    free(json_data);

    printf("Binary created: %s (board: %s)\n", output_path, board_name);
    struct stat st;
    if (stat(output_path, &st) == 0) {
        printf("Output binary size: 0x%lx bytes\n", st.st_size);
    } else {
        perror("Could not determine output file size");
    }

    return EXIT_SUCCESS;
}
