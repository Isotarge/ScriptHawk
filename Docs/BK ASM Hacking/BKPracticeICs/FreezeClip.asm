;--------------------------------------------------
; Function Definition Structure
;--------------------------------------------------
.align
FreezeClip_DefStruct:
FreezeClip_State:
.byte 0
FreezeClip_MaxState:
.byte 2

.align
FreezeClip_MenuOptionString:
.word OnOffOptionString
FreezeClip_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
FreezeClip_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word FreezeClip_NormalMode
FreezeClip_Label: 
.asciiz "FREEZE CLIP: \0\0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
FreezeClip_PauseMode:
;YOUR PAUSE MODE CODE HERE

;-------------------------------
; Normal Mode Code
;-------------------------------

FreezeClip_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)


LB a0 @PlayerGrounded
BNE a0 zero FreezeClip_HouseKeeping
NOP
    LA a0 @MaxFallVelocity
    LWC1 f12 0(a0)
    JAL @SetYVelocity
    NOP
    
FreezeClip_HouseKeeping:
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP