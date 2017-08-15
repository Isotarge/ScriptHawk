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
Template_DefStruct:
Template_State: ;STATE AT STARTUP
.byte 0
Template_MaxState: ;TOTAL # OF STATES
.byte 2

.align
Template_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word OnOffOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

Template_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word 0 ;set to 0 if no code is to be run upon exiting the pause menu

Template_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word Template_NormalMode ;set to 0 if no code is to be run during Normal menu

Template_Label: ;LABEL IN MENU
.asciiz "TEMPLATE: \0\0\0\0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
Template_PauseMode:
;YOUR PAUSE MODE CODE HERE


;-------------------------------
; Normal Mode Code
;-------------------------------
Template_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

;YOUR NORMAL MODE CODE HERE

Template_Normal_HouseKeeping:
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