MEMORY{
    RAM: ORIGIN = 0x80000000, LENGTH = 8M 
}

SECTIONS{
   .=0x80400000;
   .start :
   {
        *(.start)
   } 
   .data :
   {
        .=ALIGN(4);
        *(.data)
   }
}