#include "include/IDT.h"
#include "include/stdlib.h"
void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, unsigned char flags)
{
    /* We'll leave you to try and code this function: take the
    *  argument 'base' and split it up into a high and low 16-bits,
    *  storing them in idt[num].base_hi and base_lo. The rest of the
    *  fields that you must set in idt[num] are fairly self-
    *  explanatory when it comes to setup */
    idt[num].base_hi = (uint16_t)((base >> 16) & 0xFFFF);
    idt[num].base_lo = (uint16_t)(base & 0xFFFF);
    idt[num].sel = sel;
    idt[num].flags = flags;
}

/* Installs the IDT */
void idt_install()
{
    /* Sets the special IDT pointer up, just like in 'gdt.c' */
    idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
    idtp.base = (uint32_t)&idt;

    /* Clear out the entire IDT, initializing it to zeros */
    memset((unsigned char*)&idt, 0, sizeof(struct idt_entry) * 256);

    /* Add any new ISRs to the IDT here using idt_set_gate */

    /* Points the processor's internal register to the new IDT */
    idt_load();
}