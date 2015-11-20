[ReturnAddress]: 0x800074A0

[ControllerInput]: 0x80014DC4
[KongObjectPointer]: 0x8080BB4C

[Y_Position]: 0x80
[L_Button]: 0x0020

//.org 0x807FF500
LUI     t2, @ControllerInput
LH      t2, @ControllerInput(t2)
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return

LUI     t0, @KongObjectPointer
LW      t0, @KongObjectPointer(t0)
LWC1    F8, @Y_Position(t0)
LUI     t2, 0x4080
MTC1    t2, F10
ADD.S   F8, F8, F10
SWC1    F8, @Y_Position(t0)

Return:
LUI     t3, @ReturnAddress
ORI     t3, t3, @ReturnAddress
JR      t3