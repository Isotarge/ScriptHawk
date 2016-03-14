[Print]: 0x802F7870
[IToA]: 0x8033D8A4
[Return]: 0x8024EE90

[XPos]: 0x8037C5A0
[YPos]: 0x8037C5A4
[ZPos]: 0x8037C5A8

[XVelocity]: 0x8037C4B8
[YVelocity]: 0x8037C4BC
[ZVelocity]: 0x8037C4C0

[PositionStringLength]: 6
[UnknownParamValue]: 0xBF000666

[OSDXOffset]: 0x10
[OSDXOffsetValue]: 0x40

// .org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3

// Print X Position Label
LI a1 0x10 // Y Pos
LI a2 @UnknownParamValue
LA a3 XPosStr
JAL @Print
LI a0 @OSDXOffset

// Convert X position to Integer
LA a1 @XPos
LWC1 f31 0(a1)
CVT.W.S f31 f31
MFC1 a1 f31

// Convert to string
LA a0 XPosValueStr
LI a2 0

ClearByteX:
SB r0 0(a0)
ADDIU a2 a2 1
BNEI a2 17 ClearByteX
NOP

LI a2 10
JAL @IToA
nop

// Print X Position Value
LI a1 0x10 // Y Pos
LI a2 @UnknownParamValue
LA a3 XPosValueStr
JAL @Print
LI a0 @OSDXOffsetValue

// Print Y Position Label
LI a1 0x20 // Y Pos
LI a2 @UnknownParamValue
LA a3 YPosStr
JAL @Print
LI a0 @OSDXOffset

// Convert Y position to Integer
LA a1 @YPos
LWC1 f31 0(a1)
CVT.W.S f31 f31
MFC1 a1 f31

// Convert to string
LA a0 YPosValueStr
LI a2 0

ClearByteY:
SB r0 0(a0)
ADDIU a2 a2 1
BNEI a2 17 ClearByteY
NOP

LI a2 10
JAL @IToA
nop

// Print Y Position Value
LI a1 0x20 // Y Pos
LI a2 @UnknownParamValue
LA a3 YPosValueStr
JAL @Print
LI a0 @OSDXOffsetValue

// Print Z Position Label
LI a1 0x30 // Y Pos
LI a2 @UnknownParamValue
LA a3 ZPosStr
JAL @Print
LI a0 @OSDXOffset

// Convert Z position to Integer
LA a1 @ZPos
LWC1 f31 0(a1)
CVT.W.S f31 f31
MFC1 a1 f31

// Convert to string
LA a0 ZPosValueStr
LI a2 0

ClearByteZ:
SB r0 0(a0)
ADDIU a2 a2 1
BNEI a2 17 ClearByteZ
NOP

LI a2 10
JAL @IToA
nop

// Print Y Position Value
LI a1 0x30 // Y Pos
LI a2 @UnknownParamValue
LA a3 ZPosValueStr
JAL @Print
LI a0 @OSDXOffsetValue

POP a3
POP a2
POP a1
POP a0
POP ra
J @Return
NOP

XPosStr:
.asciiz "X POS:"
YPosStr:
.asciiz "Y POS:"
ZPosStr:
.asciiz "Z POS:"
XVelocityStr:
.asciiz "X VEL:"
YVelocityStr:
.asciiz "Y VEL:"
ZVelocityStr:
.asciiz "Z VEL:"
SlopeTimerStr:
.asciiz "SLOPE:"
XPosValueStr:
.ascii "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
YPosValueStr:
.ascii "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
ZPosValueStr:
.ascii "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
