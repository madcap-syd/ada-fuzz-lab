#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern void parse_from_c(void *data, size_t len);

int main(int argc, char **argv) {
    if (argc < 2) return 1;
    FILE *f = fopen(argv[1], "rb");
    if (!f) return 1;
    fseek(f, 0, SEEK_END);
    long file_size = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *buffer = malloc(file_size);
    fread(buffer, 1, file_size, f);
    fclose(f);
    
    parse_from_c(buffer, (size_t)file_size);
    free(buffer);
    return 0;
}
