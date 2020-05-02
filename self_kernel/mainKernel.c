#include <stddef.h>
#include <stdint.h>
#include "include/strings.h"
/*CODE PARTIALLY COPIED FROM THE OSDEV WIKI*/

void mainKernel()
{
    clearscreen();
    for (int i = 0; i < 2001; i++)
        putstring("a\0");
}
