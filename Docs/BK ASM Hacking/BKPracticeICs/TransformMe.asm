.align

;-------------------------------
; Pause Mode Code
;-------------------------------

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

LB a0 TransformMeState
BEQ a0 zero TransformMe_NormalMode_End

	LUI a1 0x07
	BNE a0 a1 TransformMe_notWishyWashy
	LUI a1 0x01
	JAL @SetCheatFlag
	LUI a0 0x9D 
	LUI a0 0x01
	
	TransformMe_notWishyWashy:
	LB a0 TransformMeState
	JAL @TransformMe
	NOP
	SB zero TransformMeState

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