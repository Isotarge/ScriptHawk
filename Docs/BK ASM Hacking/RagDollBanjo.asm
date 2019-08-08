// Hook
.org 0x80334FFC
JAL 0x80400000

//ENUMERATIONS
.include "Docs/BK ASM Hacking/BK_Enum.S"
//FUNCTIONS AND VARIABLES
.include "Docs/BK ASM Hacking/BK_NTSC.S"

//CODE
.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH at

LA a0 @PlayerPointer
LW a1 0(a0); // PlayerPtr
LW a0 0(a1); // AnimationPtr
LI a1 0x09; // DeathAnimation
SW a1 0x10(a0);

HouseKeeping:
POP at
POP a2
POP a1
POP a0
POP ra
JR
NOP

// See animation_types table in bk.lua for values
// 0x09 death *****
// 0x0A climbing *****
