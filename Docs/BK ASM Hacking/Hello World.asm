[Print]: 0x802F7870
[Return]: 0x8024EE90

.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3

LI a0 0x10 // X Pos
LI a1 0x10 // Y Pos
LI a2 0xBF000666 // Unknown param
LI a3 Hello

JAL @Print // Call Print Function
NOP

POP a3
POP a2
POP a1
POP a0
POP ra
J @Return
NOP

Hello:
.asciiz "HELLO WORLD"
