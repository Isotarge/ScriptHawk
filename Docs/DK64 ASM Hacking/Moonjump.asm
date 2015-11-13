[ReturnAddress]: 0x800074A0

[ControllerInput]: 0x80014DC4
[KongObjectPointer]: 0x807FBB4C

[Y_Position]: 0x0080
[L_Button]: 0x0020

//.org 0x807FF500
LUI     t2, @ControllerInput
ORI		t2, t2, @ControllerInput
LH      t2, 0x0000(t2)
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return
NOP

LUI     t0, @KongObjectPointer
ORI		t0, t0, @KongObjectPointer
LW      t0, 0x0000(t0)
ADDIU   t0, t0, @Y_Position
LWC1    F8, 0x0000(t0)
LUI     t2, 0x4080
MTC1    t2, F10
ADD.S   F8, F8, F10
SWC1    F8, 0x0000(t0)

NOP
Return:
LUI     t3, @ReturnAddress
ORI     t3, t3, @ReturnAddress
JR      t3