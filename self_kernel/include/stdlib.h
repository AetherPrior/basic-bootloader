#ifndef __STDLIB_H
#define __STDLIB_H
#endif
#include "head.h"
void *memcpy(void* dstptr, const void* srcptr, size_t size);
unsigned char *memset(unsigned char *dest, unsigned char val, size_t count);
uint16_t *memsetw(uint16_t *dest, uint16_t val, size_t count);
unsigned char inb(uint16_t port);
void outb(uint8_t value, uint16_t port);