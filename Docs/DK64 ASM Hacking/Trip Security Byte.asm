[ControllerInput]: 0x80014DC4
[SecurityByte]: 0x807552E0
[ReturnAddress]: 0x800074A0
[L_Button]: 0x0020

//.org 0x807FF500
LH      t2, @ControllerInput
LI      t3, @L_Button
BNE     t2, t3, Return

LI      t0, @SecurityByte
LI      t2, 0x0001
SB      t2, 0x0000(t0)

Return:
J       @ReturnAddress
NOP
