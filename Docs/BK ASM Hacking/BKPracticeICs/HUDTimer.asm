.align

;-------------------------------
; Pause Mode Code
;-------------------------------

;-------------------------------
; Normal Mode Code
;-------------------------------

HUDTimer_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 HUDTimerState
BEQ a0 zero NormalModeCode_HUDTimerNormal
NOP

	LA a0 HUDTimerValueStr
	SW zero 0(a0)

	JAL @GetInGameTimeInSeconds
	NOP
	JAL @TimeToString
	MOV a0 v0
	
	LA a0 HUDTimerValueStr
	JAL @CopyString
	MOV a1 v0

	LI a1 0x35 // Y Pos
	LA a2 HUDTimerValueStr
	JAL @Print_CharFont_Background
	LI a0 0x10 //X Pos
	
NormalModeCode_HUDTimerNormal:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP