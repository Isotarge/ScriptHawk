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
OpenSeasons_DefStruct:
OpenSeasons_State: ;STATE AT STARTUP
.byte 0
OpenSeasons_MaxState: ;TOTAL # OF STATES
.byte 5

.align
OpenSeasons_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word OpenSeasons_OptionString ;set must be 7 character (8 including trailing 0), Must be all caps

OpenSeasons_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word 0 ;set to 0 if no code is to be run upon exiting the pause menu

OpenSeasons_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word OpenSeasons_NormalMode ;set to 0 if no code is to be run during Normal menu

OpenSeasons_Label: ;LABEL IN MENU
.asciiz "OPEN SEASONS: \0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
OpenSeasons_PauseMode:
;YOUR PAUSE MODE CODE HERE


;-------------------------------
; Normal Mode Code
;-------------------------------
OpenSeasons_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

;Open Spring
LI a0 @GameProgressFlag_CCWSpringOpen
JAL @SetGameProgressFlag
LI a1 1
LB a2 OpenSeasons_State
LI at 1
BEQ a2 at OpenSeasons_Normal_HouseKeeping
LI a0 @GameProgressFlag_CCWSummerOpen
    JAL @SetGameProgressFlag
    LI at 2
    BEQ a2 at OpenSeasons_Normal_HouseKeeping
    LI a0 @GameProgressFlag_CCWAutumnOpen
        JAL @SetGameProgressFlag
        LI at 3
        BEQ a2 at OpenSeasons_Normal_HouseKeeping
        LI a0 @GameProgressFlag_CCWWinterOpen
            JAL @SetGameProgressFlag
            NOP 

OpenSeasons_Normal_HouseKeeping:

SB zero OpenSeasons_State

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
OpenSeasons_OptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "SPRING\0"
.asciiz "SUMMER\0"
.asciiz "AUTUMN\0"
.asciiz "ALL\0\0\0\0"