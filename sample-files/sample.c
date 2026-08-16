/*
 * C sample: preprocessor directives, structs, pointers, enums, format strings.
 */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEFAULT_HEX "#EEFFFF"
#define MAX_DEPTH 8
#define ARRAY_LEN(array) (sizeof(array) / sizeof((array)[0]))

#ifndef PALETTE_VERSION
#define PALETTE_VERSION "1.0.0"
#endif

typedef enum {
    TOKEN_COMMENT = 0,
    TOKEN_KEYWORD,
    TOKEN_STRING,
    TOKEN_NUMBER
} token_kind_t;

typedef struct swatch {
    char label[64];
    char hex[8];
    uint8_t depth;
    bool active;
    struct swatch *next;
} swatch_t;

static const char *const KIND_NAMES[] = {
    "comment",
    "keyword",
    "string",
    "number",
};

static double luminance(const char *hex)
{
    unsigned int red = 0, green = 0, blue = 0;

    if (hex == NULL || sscanf(hex, "#%2x%2x%2x", &red, &green, &blue) != 3) {
        return -1.0;
    }

    return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255.0;
}

static swatch_t *swatch_create(const char *label, const char *hex)
{
    swatch_t *swatch = calloc(1, sizeof(*swatch));

    if (swatch == NULL) {
        fprintf(stderr, "allocation failed\n");
        return NULL;
    }

    strncpy(swatch->label, label, sizeof(swatch->label) - 1);
    strncpy(swatch->hex, hex != NULL ? hex : DEFAULT_HEX, sizeof(swatch->hex) - 1);
    swatch->active = true;
    swatch->next = NULL;

    return swatch;
}

static void swatch_free(swatch_t *head)
{
    while (head != NULL) {
        swatch_t *next = head->next;
        free(head);
        head = next;
    }
}

int main(int argc, char *argv[])
{
    const char *name = (argc > 1) ? argv[1] : "Themes of Shibbir";
    swatch_t *head = swatch_create("background", "#263238");

    if (head == NULL) {
        return EXIT_FAILURE;
    }

    head->next = swatch_create("keyword", "#C792EA");

    printf("%s v%s\n", name, PALETTE_VERSION);

    for (swatch_t *cursor = head; cursor != NULL; cursor = cursor->next) {
        double value = luminance(cursor->hex);

        printf("  %-12s %s  luminance=%.4f  %s\n",
               cursor->label,
               cursor->hex,
               value,
               value < 0.5 ? "dark" : "light");
    }

    for (size_t i = 0; i < ARRAY_LEN(KIND_NAMES); ++i) {
        printf("kind[%zu] = %s\n", i, KIND_NAMES[i]);
    }

    swatch_free(head);

    return EXIT_SUCCESS;
}
