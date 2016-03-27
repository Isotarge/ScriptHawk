[ReturnAddress]: 0x800074A0

[ControllerInput]: 0x80014DC4
[KongObjectPointer]: 0x807FBB4C

[Y_Position]: 0x80
[L_Button]: 0x0020

.org 0x807FF500
LH      t2, @ControllerInput
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return

LW      t0, @KongObjectPointer
LWC1    F8, @Y_Position(t0)
LUI     t2, 0x4080
MTC1    t2, F10
ADD.S   F8, F8, F10
SWC1    F8, @Y_Position(t0)

Return:
LBU     t9, 6(sp) // These 4 lines appear to be replaced by Subdrag's hook, they don't contribute to our code but they might prevent some crashes/weirdness so I'll keep them
ANDI    t0, t9, 0x00C0
SRA     t1, t0, 0x04
ANDI    t2, t1, 0x00FF
J       @ReturnAddress
NOP
