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
HUDTimer_DefStruct:
HUDTimer_State:
.byte 0
HUDTimer_MaxState:
.byte 2

.align
HUDTimer_MenuOptionString:
.word OnOffOptionString
HUDTimer_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
HUDTimer_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word HUDTimer_NormalMode
HUDTimer_Label: 
.asciiz "HUD TIMER: \0\0\0\0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
HUDTimer_PauseMode:
;YOUR PAUSE MODE CODE HERE

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
