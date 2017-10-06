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
SetMoves_DefStruct:
SetMoves_State: ;STATE AT STARTUP
.byte 0
SetMoves_MaxState: ;TOTAL # OF STATES
.byte 7

.align
SetMoves_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word MoveSetOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

SetMoves_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word SetMoves_PauseMode ;set to 0 if no code is to be run upon exiting the pause menu

SetMoves_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word 0 ;set to 0 if no code is to be run during Normal menu

SetMoves_Label: ;LABEL IN MENU
.asciiz "SET MOVES: \0\0\0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
SetMoves_PauseMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 SetMoves_State
BEQ a0 zero SetMoves_Pause_Housekeeping
NOP

SUBI a0 a0 1
LA a1 MoveSet_BitfieldValues
SLL a0 a0 2
ADDU a1 a0 a1
LW a0 0(a1);
JAL @SetMovesUnlockedBitfield
NOP
JAL @SetHasUsedMovesBitfield
NOP
SB zero SetMoves_State

SetMoves_Pause_Housekeeping:
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
SetMoves_NormalMode:

;-------------------------------
; Variables
;-------------------------------

MoveSetOptionString: ;6
.asciiz "OFF\0\0\0\0"
.asciiz "NONE\0\0\0"
.asciiz "SM\0\0\0\0\0"
.asciiz "FFM\0\0\0\0" ;FFM no Eggs
.asciiz "FFM EGG" ;FFM Eggs
.asciiz "ALL\0\0\0\0"
.asciiZ "DEMO\0\0\0"

MoveSet_BitfieldValues:
.word 0
.word 0x00009DB9
.word 0x000BFDBF
.word 0x000BFDFF
.word 0x000FFFFF
.word 0xFFFFFFFF