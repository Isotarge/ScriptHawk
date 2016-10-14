// Hook
.org 0x807140BC

jal 0x807FF500
nop
b 0x80714110
nop

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

[X_Position]: 0x7C
[Y_Position]: 0x80
[Z_Position]: 0x84

[Floor]: 0xA4

[Y_Velocity]: 0xC0

[X_Rotation]: 0xE4
[Y_Rotation]: 0xE6
[Z_Rotation]: 0xE8

[Speed]: 0x4080

.org 0x807FF500
LUI     t1, @Speed
MTC1    t1, F10

// Get controller input
LH      t2, @ControllerInput

// Defererence Kong Object pointer
LW      t0, @KongObjectPointer

// Check for L button
LI      t3, @L_Button
// or BNEI t2, @L_Button
BNE     t2, t3, Up

// Y Position += Speed
LWC1    F8, @Y_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @Y_Position(t0)
SW      r0, @Y_Velocity(t0)

// U +, +
Up:
LI      t3, @DPAD_Up
// or BNEI t2, @DPAD_Up
BNE     t2, t3, Down

// X Position += Speed
LWC1    F8, @X_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position += Speed
LWC1    F8, @Z_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)

// D -, -
Down:
LI      t3, @DPAD_Down
// or BNEI t2, @DPAD_Down
BNE     t2, t3, Left

// X Position -= Speed
LWC1    F8, @X_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position -= Speed
LWC1    F8, @Z_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)

// L +, -
Left:
LI      t3, @DPAD_Left
// or BNEI t2, @DPAD_Left
BNE     t2, t3, Right

// X Position += Speed
LWC1    F8, @X_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position -= Speed
LWC1    F8, @Z_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)

// R -, +
Right:
LI      t3, @DPAD_Right
// or BNEI t2, @DPAD_Right
BNE     t2, t3, Return

// X Position -= Speed
LWC1    F8, @X_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position += Speed
LWC1    F8, @Z_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)

Return:
JR      ra
NOP