#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../tests/all.h"


int main() {
    monero_test_creation();
    monero_test_restore();
    printf("All tests passed\n");
    return 0;
}
