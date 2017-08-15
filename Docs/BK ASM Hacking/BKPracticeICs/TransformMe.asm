;--------------------------------------------------
; Function Definition Structure
;--------------------------------------------------
.align
TransformMe_DefStruct:
TransformMe_State:
.byte 0
TransformMe_MaxState:
.byte 8

.align
TransformMe_MenuOptionString:
.word TransformMe_OptionString
TransformMe_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
TransformMe_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word TransformMe_NormalMode
TransformMe_Label: 
.asciiz "TRANSFORM ME: \0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
TransformMe_PauseMode:
;YOUR PAUSE MODE CODE HERE

;-------------------------------
; Normal Mode Code
;-------------------------------

TransformMe_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 TransformMe_State
LUI a1 0x07
BNE a0 a1 TransformMe_notWishyWashy
LUI a1 0x01
JAL @SetCheatFlag
LUI a0 0x9D 
LUI a0 0x01

TransformMe_notWishyWashy:
LB a0 TransformMe_State
JAL @TransformMe
NOP
SB zero TransformMe_State

TransformMe_NormalMode_End:

	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP


;-------------------------------
; Variables
;-------------------------------

.align
TransformMe_OptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "BANJO\0\0"
.asciiz "TERMITE"
.asciiz "PUMPKN\0"
.asciiz "WALRUS\0"
.asciiz "CROC\0\0\0"
.asciiz "BEE\0\0\0\0"
.asciiz "WASHY\0\0"