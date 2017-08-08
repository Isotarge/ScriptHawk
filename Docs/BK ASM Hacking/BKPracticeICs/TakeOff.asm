.align

;-------------------------------
; Pause Mode Code
;-------------------------------

;-------------------------------
; Normal Mode Code
;-------------------------------

TakeOff_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 TakeOff_State
BEQ a0 zero TakeOff_HouseKeeping
NOP
    LA a2 @RawP1Buttons
    LH a0 0x00(a2)
	
	//A
	ANDI a1 a0 0x0400
	BEQ a1 zero TakeOff_HouseKeeping
    LI a0 0x1
        JAL @SetMiscFlag 
        NOP

    
TakeOff_HouseKeeping:    
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP