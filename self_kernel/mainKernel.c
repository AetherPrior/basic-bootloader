#include "include/head.h"
#include "include/strings.h"
#include "include/GDT.h"
/*CODE PARTIALLY COPIED FROM THE OSDEV WIKI*/

void mainKernel()
{
    gdt_install();
    clearscreen();
    for (int i = 0; i < 2001; i++)
        putstring("a\0");
}
