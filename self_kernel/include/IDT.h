#ifndef __IDT_H
#define __IDT_H
#endif

//equivalent to #pragma once 

#include "head.h"
/* Defines an IDT entry */
/*CODE COPIED FROM OSDEVER.net*/
struct idt_entry
{
    uint16_t base_lo;
    uint16_t sel;        /* Our kernel segment goes here! */
    unsigned char always0;     /* This will ALWAYS be set to 0! */
    unsigned char flags;       /* Set using the above table! */
    uint16_t base_hi;
} __attribute__((packed));

struct idt_ptr
{
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

/* Declare an IDT of 256 entries. Although we will only use the
*  first 32 entries in this tutorial, the rest exists as a bit
*  of a trap. If any undefined IDT entry is hit, it normally
*  will cause an "Unhandled Interrupt" exception. Any descriptor
*  for which the 'presence' bit is cleared (0) will generate an
*  "Unhandled Interrupt" exception */
struct idt_entry idt[256];
struct idt_ptr idtp;

extern void idt_load(); //in bootloader.asm