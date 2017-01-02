// Hook
.org 0x8024EAE0
JAL 0x80400000

[Return]: 0x8024E070
.include "Docs/BK ASM Hacking/BK_PAL.S"
//ENUMERATIONS
.include "Docs/BK ASM Hacking/BK_Enum.S"

.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3

LI a0 0x10 // X Pos
LI a1 0x10 // Y Pos
LI a2 0xBF000666 // Text Size, Float
LA a3 Hello

JAL @Print_TotalMenuFont // Call Print Function
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
