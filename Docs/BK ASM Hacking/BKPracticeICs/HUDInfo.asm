[OSDXOffset]: 0x08

;--------------------------------------------------
; Function Definition Structure
;--------------------------------------------------
; This struct contains all the info needed for the 
; practice menu to successfully run the function
; in the practice menu
;
; Add X_DefStruct to the function list in PracticeMenu.asm
;--------------------------------------------------
.align
HUDInfo_DefStruct:
HUDInfo_State:
.byte 0
HUDInfo_MaxState:
.byte 2

.align
HUDInfo_MenuOptionString:
.word OnOffOptionString
HUDInfo_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
HUDInfo_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word HUDInfo_NormalMode
HUDInfo_Label: 
.asciiz "HUD INFO: \0\0\0\0\0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
HUDInfo_PauseMode:
;YOUR PAUSE MODE CODE HERE

;-------------------------------
; Normal Mode Code
;-------------------------------
HUDInfo_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)



// Convert X position to String
LA a0 XPosValueStr
LA a1 XPosStr //label
JAL @CopyString
NOP
LA a1 @XPos
LW a1 0(a1)
LA a0 XPosValueStr
JAL @FToA
LI a2 3

// Print X Position
LI a1 0x08 // Y Pos
LA a2 XPosValueStr
JAL @Print_CharFont_Background
LI a0 @OSDXOffset

// Convert Y position to String
LA a0 YPosValueStr
LA a1 YPosStr //label
JAL @CopyString
NOP
LA a1 @XPos
LW a1 4(a1)
LA a0 YPosValueStr
JAL @FToA
LI a2 3

// Print Y Position
LI a1 0x14 // Y Pos
LA a2 YPosValueStr
JAL @Print_CharFont_Background
LI a0 @OSDXOffset

// Convert Z position to String
LA a0 ZPosValueStr
LA a1 ZPosStr //label
JAL @CopyString
NOP
LA a1 @XPos
LW a1 8(a1)
LA a0 ZPosValueStr
JAL @FToA
LI a2 3

// Print Z Position
LI a1 0x20 // Y Pos
LA a2 ZPosValueStr
JAL @Print_CharFont_Background
LI a0 @OSDXOffset

// Convert XZ velocity to String
LA a0 XZVelocityValueStr
LA a1 XZVelocityStr
JAL @CopyString
NOP
JAL @GetXZVelocity
NOP
mfc1 a1 f0
LA a0 XZVelocityValueStr
JAL @FToA
LI a2 3

// Print XZ Velocity
LI a1 0x34 // Y Pos
LA a2 XZVelocityValueStr
JAL @Print_CharFont_Background
LI a0 @OSDXOffset

// Convert Y velocity to String
LA a0 YVelocityValueStr
LA a1 YVelocityStr
JAL @CopyString
NOP
LA a1 @XVelocity
LW a1 4(a1)
LA a0 YVelocityValueStr
JAL @FToA
LI a2 3

// Print Y Velocity
LI a1 0x40 // Y Pos
LA a2 YVelocityValueStr
JAL @Print_CharFont_Background
LI a0 @OSDXOffset

// Convert SlopeTimer to String
LA a0 SlopeTimerValueStr
LA a1 SlopeTimerStr
JAL @CopyString
NOP
LA a1 @SlopeTimer
LW a1 0(a1)
LA a0 SlopeTimerValueStr
JAL @FToA
LI a2 3

// Print SlopeTimer
LI a1 0x54 // Y Pos
LA a2 SlopeTimerValueStr
JAL @Print_CharFont_Background
LI a0 @OSDXOffset

HUDInfo_HouseKeeping:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP

.align
XPosStr:
.asciiz "X:\0\0"
YPosStr:
.asciiz "Y:\0\0"
ZPosStr:
.asciiz "Z:\0\0"
XZVelocityStr:
.asciiz "XZ':\0\0"
YVelocityStr:
.asciiz "Y':\0"
ZVelocityStr:
.asciiz "Z':\0"
SlopeTimerStr:
.asciiz "ST:\0"

XPosValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
YPosValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
ZPosValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
YVelocityValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
XZVelocityValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
SlopeTimerValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"