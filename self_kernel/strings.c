#define MAX_X 79
#define MAX_Y 24
#include "include/stdlib.h"


int cur_X = 0, cur_Y = 0;

void moveCursor(char x, char y)
{
    uint16_t loc = ((uint16_t)y) * 80 + ((uint16_t)x);
    char *ptr = (char *)&loc;
    outb(0x0f, 0x3d4);
    outb(*ptr, 0x3d5);
    outb(0x0e, 0x3d4);
    outb(*(ptr + 1), 0x3d5);
}
void clearscreen()
{
    char *restrict s = (char *)0xB8000;
    int x = 2000;
    __asm__(
        "pusha;"
        "cld;");
    while (x--)
    {
        *s = ' ';
        ++s;
        *s = '\x07';
        ++s;
    }
    cur_X = 0;
    cur_Y = 0;
    __asm__(
        "popa;");
    moveCursor(0, 0);
}
void scroll()
{
    memcpy((void *)0xB8000, (void *)0xB80A0, 1920);
    __asm__(
        ".intel_syntax noprefix;"
        "pusha;"
        "mov edi, 0xB8F00;"
        "mov cx, 80;"
        "mov al, ' ';"
        "mov ah, 0x07;"
        "rep stosw;"
        "popa;"
        ".att_syntax;");
    cur_X = 0;
    cur_Y = 24;
    moveCursor(cur_X, cur_Y);
}
void putstring(char *str)
{
    uint32_t addr = 0xB8000 + cur_Y * 80 * 2 + cur_X * 2;
    char *s = (char *)addr;
    while (*str != '\0')
    {
        *s = *str;
        s++;
        str++;
        *s = '\x07';
        s++;
        cur_X++;
        if (cur_X > MAX_X)
        {
            cur_X = 0;
            cur_Y++;
            if (cur_Y > MAX_Y)
            {
                scroll();
            }
        }
    }
    moveCursor(cur_X, cur_Y);
}

size_t strlen(char *str)
{
    size_t i;
    for (i = 0; str[i] != '\0'; i++)
        ;
    return i;
}