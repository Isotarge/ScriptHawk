//Banjo-Kazooie Speedrunning Cheat Menu
//Enter Main Menu by pressing start, then press D-left to switch to practice menu
//  Press D-Right to return to main menu
//
//
// TO DO: Update Progress flags on reset
//        Save State Code
//        Map ghosts
//

//Variables
[NumberOfOptions]: 0x09
[PageTopMax]: 0x05
;----------------------------------------------------------------
; Code Run from Pause Mode
;----------------------------------------------------------------

.org 0x80400000
.include "PracticeMenu_GUI.asm"

;----------------------------------------------------------------
; Function Libraries
;----------------------------------------------------------------
.include "BKPracticeICs/L2Levitate.asm"
.include "BKPracticeICs/TransformMe.asm"
.include "BKPracticeICs/Infinites.asm"
.include "BKPracticeICs/TakeMeThere.asm"
.include "BKPracticeICs/InputDisplay.asm"
.include "BKPracticeICs/ResetOnEnter.asm"
.include "BKPracticeICs/HUDTimer.asm"
//.include "BKPracticeICs/Ghost.asm"

;----------------------------------------------------------------
; Upon Exiting Practice Menu
;
;----------------------------------------------------------------
.align
ExitingMenuCode: ;DO NOT CHANGE THIS NAME
	ADDIU sp -0x20
	SW ra 0x1C(sp)
	SW a0 0x18(sp)
	SW a1 0x14(sp)
	SW s3 0x10(sp)

	LB s3 MoveSet
	BEQZ s3 KeepCurrentMoveSet
	LI a1 0x01
		//NONE
		MOV a0 zero
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a1 0x02

		//SM Set
		LI a0 0x00009DB9
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a1 0x03

		//FFM
		LI a0 0x000BFDBF
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a1 0x04

		//FFM + EGGS
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a0 0x000BFDFF

		//ALL
		LI a0 0x000FFFFF

	DoNotKeepCurrentMoveSet:
	JAL @SetMovesUnlockedBitfield
	NOP
	JAL @SetHasUsedMovesBitfield
	NOP

	KeepCurrentMoveSet:
	SB zero MoveSet
	
    //JAL Ghost_PauseMode
    //NOP

	LW ra 0x1C(sp)
	LW a0 0x18(sp)
	LW a1 0x14(sp)
	LW s3 0x10(sp)
	ADDIU sp 0x20

	JR	;IMPORTANT
	NOP ;IMPORTANT

;----------------------------------------------------------------
; Code Run from Normal Mode
;
;----------------------------------------------------------------
NormalModeCode: ;DO NOT CHANGE THIS NAME
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

//cheatMenuNotSetUp
LB a0 PracMenuSetup
BEQ a0 zero NormalModeCode_MenuSetup
NOP
	JAL BetaPauseMenu
	NOP
	MOV a0 zero
NormalModeCode_MenuSetup:


//Take Me There
JAL TakeMeThere_NormalMode
NOP

//Transform Me
JAL TransformMe_NormalMode
NOP

//Press-L to Levitate
JAL L2Levitate_NormalMode
NOP

//Ingame-Timer
JAL HUDTimer_NormalMode
NOP

//InputDisplay
JAL InputDisplay_NormalMode
NOP

//Infinites
JAL Infinites_NormalMode
NOP

//ResetUponEnter
JAL ResetOnEnter_NormalMode
NOP

//JAL Ghost_NormalMode
//NOP

		
	
NormalModeCode_Housekeeping:	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP

;----------------------------------------------------------------
; Menu Variables
; BitFlags
;----------------------------------------------------------------
MenuOptionStates: ;DO NOT CHANGE THIS NAME
InfinitesState:
.byte 0
ResetOnEnterState:
.byte 0
TakeMeThereState:
.byte 0
HUDTimerState:
.byte 0
MoveSet:
.byte 0
L2LevitateState:
.byte 0
TransformMeState:
.byte 0
GhostState:
.byte 0
InputDisplayState:
.byte 1

.align
MenuItemStr: ;DO NOT CHANGE THIS NAME
.asciiz "PRACTICE MENU 1: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 2: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 3: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 4: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"

.align
MenuLabelStrings: ;DO NOT CHANGE THIS NAME
.asciiz "INFINITES: \0\0\0\0"
.asciiz "RESET ON ENTER:"
.asciiz "TAKE ME THERE: "
.asciiz "HUD TIMER: \0\0\0\0"
//.asciiz "LOOP: \0\0\0\0\0\0\0\0\0"
.asciiz "MOVE SET: \0\0\0\0\0"
.asciiz "L 2 LEVITATE: \0"
.asciiz "TRANSFORM ME: \0"
.asciiz "GHOST BETA: \0\0\0"
.asciiz "INPUTS: \0\0\0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"


MenuOptionMaxStates: ;DO NOT CHANGE THIS NAME
InfinitesMaxState:
.byte 2
ResetOnEnterMaxState:
.byte 4
TakeMeThereMaxState:
.byte 14
HUDTimerMaxState:
.byte 2
MoveSetMaxState:
.byte 6
L2LevitateMaxState:
.byte 2
TransformMeMaxState:
.byte 8
GhostMaxState:
.byte 2
InputDisplayMaxState:
.byte 2

.align
MenuOptionStringSet: ;DO NOT CHANGE THIS NAME
InfinitesStringSet:
.word OnOffOptionString
ResetOnEnterStringSet:
.word ResetOptionString
TakeMeThereStringSet:
.word TakeMeThereOptionString
HUDTimerOptionString:
.word OnOffOptionString
MoveSetStringSet:
.word MoveSetOptionString
L2LevitateStringSet:
.word OnOffOptionString
TransformMeStringSet:
.word TransformMe_OptionString
GhostStringSet:
.word OnOffOptionString
InputDisplayStringSet:
.word OnOffOptionString

PreviousLoadzoneState:
.byte 0
.byte 0
.byte 0
.byte 0

GhostObjectPointer:
.word 0
GhostCurrentFrame:
.word 0
GhostPrevObjectArray:
.word 0
GhostObjectArrayIndex:
.word 0
GhostCurrentPlaybackPointer:
.word 0
GhostRecordPointer:
.word 0
GhostCurrentTailPointer:
.word GhostArray

/*Option strings*/
.align
OnOffOptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "ON\0\0\0\0\0"

MoveSetOptionString: ;6
.asciiz "OFF\0\0\0\0"
.asciiz "NONE\0\0\0"
.asciiz "SM\0\0\0\0\0"
.asciiz "FFM\0\0\0\0" ;FFM no Eggs
.asciiz "FFM EGG" ;FFM Eggs
.asciiz "ALL\0\0\0\0"

TakeMeThereOptionString:
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

ResetOptionString:
.asciiz " OFF\0\0\0"
.asciiz " 100\0\0\0"
.asciiz " ANY\0\0\0"
.asciiz " NO RBA"

temp1:
.word 0
temp2:
.word 0

.align
TEMPValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
TEMP2ValueStr:
.asciiz ".\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.align
HUDTimerValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

GhostArray:
//ghost struct:
//	half Map
//	half Exit
//	word TotalFrames
//	word NextGhostStruct
//  word PrevGhostStruct
//  frame[0]:
//  	float XPos
//		float YPos
//		float ZPos
//  frame[1]:
//  	float XPos
//		float YPos
//		float ZPos
//	etc...