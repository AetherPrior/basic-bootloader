ENTRY(start)
SECTIONS
{
    . = 0x7c00;
    .text 0x7c00:
    {
        
        boot.o(.text);
        *(.text);
        . = ALIGN(4096);
    }

    .data :
    {
        
        *(.data);
        *(.rodata);
        . = ALIGN(4096);
    }

    .bss :
    {
        
        *(.bss);
        . = ALIGN(4096);
    }

}