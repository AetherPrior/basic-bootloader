#include "include/head.h"
void *memcpy(void *restrict dstptr, const void *restrict srcptr, size_t size)
{
    unsigned char *dst = (unsigned char *)dstptr;
    const unsigned char *src = (const unsigned char *)srcptr;
    for (size_t i = 0; i < size; i++)
        dst[i] = src[i];
    return dstptr;
}
void outb(uint8_t value, uint16_t port)
{
    __asm__(
        ".intel_syntax noprefix;"
        "outb %w1, %b0;"
        ".att_syntax;" ::"a"(value),
        "d"(port));
}

unsigned char inb(uint16_t port)
{
    unsigned char rv;
    __asm__(
        ".intel_syntax noprefix;"
        " inb %b0, %w1;"
        ".att_syntax;"
        : "=a"(rv)
        : "d"(port));
    return rv;
}

unsigned char *memset(unsigned char *dest, unsigned char val, size_t count)
{
    for (size_t i = 0; i < count; i++)
    {
        *(dest + i) = val;
    }
    return dest;
}

uint16_t *memsetw(uint16_t *dest, uint16_t val, size_t count)
{
    for (size_t i = 0; i < count; i++)
    {
        *(dest + i) = val;
    }
    return dest;
}

