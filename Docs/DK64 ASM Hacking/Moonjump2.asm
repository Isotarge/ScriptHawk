[ReturnAddress]: 0x800074A0

// Controller stuff
[ControllerInput]: 0x80014DC4

[A_Button]: 0x8000
[B_Button]: 0x4000
[Z_Button]: 0x2000

[L_Button]: 0x0020
[R_Button]: 0x0010

[DPAD_Up]: 0x0800
[DPAD_Down]: 0x0400
[DPAD_Left]: 0x0200
[DPAD_Right]: 0x0100

// Frame counters
[Frames_Lag]: 0x8076AF10
[Frames_Real]: 0x807F0560

// Kong Object stuff
[KongObjectPointer]: 0x807FBB4C

[ModelPointer]: 0x00
[BoneArrayPointer]: 0x04

[X_Position]: 0x007C
[Y_Position]: 0x0080
[Z_Position]: 0x0084

[Floor]: 0x00A4

[X_Rotation]: 0x00E4
[Y_Rotation]: 0x00E6
[Z_Rotation]: 0x00E8

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