// Hook
.org 0x8024EE90
JAL 0x80400000

[Return]: 0x8024E420

[P1NewlyPressedButtons]: 0x80281254

.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3

DPadDownCheck:
LW a1 @P1NewlyPressedButtons
LUI a2 0x0400
AND a1 a1 a2 
BEQ a1 zero DPadUpCheck
NOP

LI a1, 0x3f47ae14 // 0.78f
MTC1 a1, f12
LI a1 0x8029B5EC
JAL 0x80324EAC
B Done
NOP

DPadUpCheck:
LW a1 @P1NewlyPressedButtons
LUI a2 0x0800
AND a1 a1 a2 
BEQ a1 zero Done
NOP

JAL 0x8029B5EC
NOP

Done:
POP a3
POP a2
POP a1
POP a0
POP ra
J @Return
NOP
