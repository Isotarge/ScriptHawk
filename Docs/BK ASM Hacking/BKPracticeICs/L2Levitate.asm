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
L2Levitate_DefStruct:
L2Levitate_State:
.byte 0
L2Levitate_MaxState:
.byte 2

.align
L2Levitate_MenuOptionString:
.word OnOffOptionString
L2Levitate_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
L2Levitate_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word L2Levitate_NormalMode
L2Levitate_Label: 
.asciiz "L 2 LEVITATE: \0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
L2Levitate_PauseMode:
;YOUR PAUSE MODE CODE HERE


;-------------------------------
; Normal Mode Code
;-------------------------------
L2Levitate_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)


JAL @GetButtonPressTimer
LI a0 0x02 ;L button Index
BEQ v0 zero L2Levitate_Normal_Off
LUI a0 0x4220
    MTC1 zero f12
    JAl @SetYVelocity ;Vel increases while airborn, if Vel > pos change then banjo still falls
    LUI a0 0x41a0
    MTC1 a0 f12
    JAL @AddToYPos
    NOP
L2Levitate_Normal_Off:
	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP