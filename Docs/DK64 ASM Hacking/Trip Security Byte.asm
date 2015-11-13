[ControllerInput]: 0x80014DC4
[SecurityByte]: 0x807552E0
[ReturnAddress]: 0x800074A0
[LButton]: 0x0020

//.org 0x807FF500
LUI     t2, @ControllerInput
ORI		t2, t2, @ControllerInput
LH      t2, 0x0000(t2)
ADDIU   t3, r0, @LButton
BNE     t2, t3, Return
NOP

LUI     t0, @SecurityByte
ORI		t0, t0, @SecurityByte
ADDIU   t2, r0, 0x0001
SB		t2, 0x0000(t0)

NOP
Return:
LUI     t3, @ReturnAddress
ORI     t3, t3, @ReturnAddress
JR      t3