#include "utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char* u_mktemp() {
    char pattern[] = "/tmp/monero_c_test_XXXXXXXXX";

    char *template = malloc(strlen(pattern) + 1);
    if (!template) {
        perror("malloc failed");
        exit(1);
    }

    strcpy(template, pattern);

    if (mkdtemp(template) == NULL) {
        perror("mkdtemp failed");
        free(template);
        exit(1);
    }

    return template;
}

char* u_cat(const char* a, const char* b) {
    size_t len_a = strlen(a);
    size_t len_b = strlen(b);

    char* result = malloc(len_a + len_b + 1);
    if (!result) {
        perror("malloc failed");
        exit(1);
    }

    memcpy(result, a, len_a);
    memcpy(result + len_a, b, len_b + 1); // include null terminator

    return result;
}

int u_wordcount(const char* str) {
    if (!str) return 0;

    int count = 0;
    int in_word = 0;

    for (size_t i = 0; str[i]; i++) {
        // Japan smh (　= 0xE3 0x80 0x80)
        int is_space = (str[i] == ' ') ||
                       ((unsigned char)str[i]   == 0xE3 &&
                        (unsigned char)str[i+1] == 0x80 &&
                        (unsigned char)str[i+2] == 0x80);

        if (is_space) {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            count++;
        }
    }

    return count;
}
