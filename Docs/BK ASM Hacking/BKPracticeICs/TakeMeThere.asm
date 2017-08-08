.align
TakeMeThere_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 TakeMeThereState
BEQ a0 zero NormalModeCode_TakeMeThereEnd
	;convert from option number  to level index

    SUBI a0 a0 1
    SLL a0 a0 1
    LA a2 TakeMeThere_WarpLocations
    ADDU a2 a2 a0
    LB a1 0x01(a2) ;exit
    LB a0 0x00(a2) ;level
	JAL @TakeMeThere_LevelReset
	LI a2 1
	SB zero TakeMeThereState

NormalModeCode_TakeMeThereEnd:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP


;--------------------------------
; Variables
;--------------------------------

.align
TakeMeThere_WarpLocations:
.byte 0x01, 0x12 ;SM
.byte 0x02, 0x05 ;MM
.byte 0x07, 0x04 ;TTC
.byte 0x0B, 0x05 ;CC
.byte 0x0D, 0x02 ;BGS
.byte 0x27, 0x01 ;FP
.byte 0x12, 0x08 ;GV
.byte 0x1B, 0x14 ;MMM
.byte 0x31, 0x10 ;RBB
.byte 0x40, 0x07 ;CCW
.byte 0x8E, 0x02 ;FF
.byte 0x93, 0x0A ;DoG
.byte 0x90, 0x01 ;Grunty

.align
TakeMeThere_OptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "SM\0\0\0\0\0"
.asciiz "MM\0\0\0\0\0"
.asciiz "TTC\0\0\0\0"
.asciiz "CC\0\0\0\0\0"
.asciiz "BGS\0\0\0\0"
.asciiz "FP\0\0\0\0\0"
.asciiz "GV\0\0\0\0\0"
.asciiz "MMM\0\0\0\0"
.asciiz "RBB\0\0\0\0"
.asciiz "CCW\0\0\0\0"
.asciiz "FF\0\0\0\0\0"
.asciiz "DOG\0\0\0\0"
.asciiz "GRUNTY\0"