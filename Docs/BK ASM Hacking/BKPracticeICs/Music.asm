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
music_DefStruct:
music_State: ;STATE AT STARTUP
.byte 0
music_MaxState: ;TOTAL # OF STATES
.byte 2

.align
music_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word musicOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

music_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word 0 ;set to 0 if no code is to be run upon exiting the pause menu

music_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word music_NormalMode ;set to 0 if no code is to be run during Normal menu

music_Label: ;LABEL IN MENU
.asciiz "MUSIC: \0\0\0\0\0\0\0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
music_PauseMode:
;YOUR PAUSE MODE CODE HERE


;-------------------------------
; Normal Mode Code
;-------------------------------
music_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LI at 0x06
LUI a0 0x8028
ADDIU a0 a0 0x184E
music_Normal_Loop:
    SUBI at at 1
    SH zero 0(a0)
    ADDIU a0 a0 0x1A0
    BNE at zero music_Normal_Loop

music_Normal_HouseKeeping:
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
musicOptionString:
.asciiz " ON\0\0\0\0"
.asciiz " OFF\0\0\0"
.asciiz " DRUMS\0"
