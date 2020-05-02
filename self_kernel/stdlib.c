#include <stddef.h>
#include <stdint.h>
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