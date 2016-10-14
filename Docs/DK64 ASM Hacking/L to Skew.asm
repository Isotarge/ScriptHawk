// Hook
.org 0x807140BC

jal 0x807FF500
nop
b 0x80714110
nop

[ControllerInput]: 0x80014DC4
[KongObjectPointer]: 0x807FBB4C

[Z_Rot]: 0xE8
[L_Button]: 0x0020

.org 0x807FF500
LH      t2, @ControllerInput
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return

LW      t0, @KongObjectPointer
LI      t3, 0x3C00 // Skew amount
SH      t3, @Z_Rot(t0)

Return:
JR      ra
NOP