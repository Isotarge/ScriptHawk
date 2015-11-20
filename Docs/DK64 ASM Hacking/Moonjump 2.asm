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
[KongObjectPointer]: 0x8080BB4C

[ModelPointer]: 0x00
[BoneArrayPointer]: 0x04

[X_Position]: 0x7C
[Y_Position]: 0x80
[Z_Position]: 0x84

[Floor]: 0xA4

[X_Rotation]: 0xE4
[Y_Rotation]: 0xE6
[Z_Rotation]: 0xE8

[Speed]: 0x4080

//.org 0x807FF500
// Store return address for later
//OR      t7, RA, r0

LUI     t1, @Speed
MTC1    t1, F10

// Get controller input
LUI     t2, @ControllerInput
LH      t2, @ControllerInput(t2)

// Defererence Kong Object pointer
LUI     t0, @KongObjectPointer
LW      t0, @KongObjectPointer(t0)

// Check for L button
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Up

// Y Position += Speed
LWC1    F8, @Y_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @Y_Position(t0)
NOP

// U +, +
Up:
ADDIU   t3, r0, @DPAD_Up
BNE     t2, t3, Down

// X Position += Speed
LWC1    F8, @X_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position += Speed
LWC1    F8, @Z_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)
NOP

// D -, -
Down:
ADDIU   t3, r0, @DPAD_Down
BNE     t2, t3, Left

// X Position -= Speed
LWC1    F8, @X_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position -= Speed
LWC1    F8, @Z_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)
NOP

// L +, -
Left:
ADDIU   t3, r0, @DPAD_Left
BNE     t2, t3, Right

// X Position += Speed
LWC1    F8, @X_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position -= Speed
LWC1    F8, @Z_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)
NOP

// R -, +
Right:
ADDIU   t3, r0, @DPAD_Right
BNE     t2, t3, Return

// X Position -= Speed
LWC1    F8, @X_Position(t0)
SUB.S   F8, F8, F10
SWC1    F8, @X_Position(t0)

// Z Position += Speed
LWC1    F8, @Z_Position(t0)
ADD.S   F8, F8, F10
SWC1    F8, @Z_Position(t0)
NOP

Return:
// Restore RA register
//OR      RA, t7, r0

// Return to hooked function
LUI     t3, @ReturnAddress
ORI     t3, t3, @ReturnAddress
JR      t3