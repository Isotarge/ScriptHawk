// Hook
.org 0x807140BC

jal 0x807FF500
nop
b 0x80714110
nop

[ControllerInput]: 0x80014DC4
[KongObjectPointer]: 0x807FBB4C

[Y_Position]: 0x80
[Y_Velocity]: 0xC0
[L_Button]: 0x0020

.org 0x807FF500
LH      t2, @ControllerInput
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return

LW      t0, @KongObjectPointer
LWC1    F8, @Y_Position(t0)
LUI     t2, 0x4080
MTC1    t2, f10
ADD.S   f8, f8, f10
SWC1    f8, @Y_Position(t0)
SW      r0, @Y_Velocity(t0)

Return:
JR      ra
NOP