MEMORY{
    /* ROM */
    RAM: ORIGIN = 0x80000000, LENGTH = 0x800000 /*8M 
}

SECTIONS{
    .existingGameBlock:
    {
        
    }
    .=0x400000;
    .text :
    {
        .=ALIGN(4);
        *(.start)
    } 
    .data :
    {
        .=ALIGN(4);
        *(.data)
    }
}