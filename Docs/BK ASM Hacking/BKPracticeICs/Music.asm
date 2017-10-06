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
.byte 1 ;default on
music_MaxState: ;TOTAL # OF STATES
.byte 2

.align
music_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word OnOffOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

music_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word music_PauseMode ;set to 0 if no code is to be run upon exiting the pause menu

music_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word music_Normal_HouseKeeping ;set to 0 if no code is to be run during Normal menu

music_Label: ;LABEL IN MENU
.asciiz "MUSIC: \0\0\0\0\0\0\0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
music_PauseMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LUI a0 0x8026
ADDIU a0 a0 0xE883
LB a1 music_State
SB a1 0(a0)


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
; Normal Mode Code
;-------------------------------
music_NormalMode:
JR
NOP

;-------------------------------
; Variables
;-------------------------------

