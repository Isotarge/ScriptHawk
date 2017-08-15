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
[DefStruct_State]:0x00
[DefStruct_MaxState]:0x01
[DefStruct_MenuOptionString]:0x04
[DefStruct_PauseModePtr]:0x08
[DefStruct_NormalModePtr]:0x0C
[DefStruct_Label]:0x10

;----------------------------------------------------------------
; Code Run from Pause Mode
;----------------------------------------------------------------

.org 0x80400000
.include "PracticeMenu_GUI.asm"

;----------------------------------------------------------------
; Function Libraries
;----------------------------------------------------------------
.include "BKPracticeICs/TakeMeThere.asm"
.include "BKPracticeICs/ResetOnEnter.asm"
.include "BKPracticeICs/Infinites.asm"
.include "BKPracticeICs/HUDInfo.asm"
.include "BKPracticeICs/HUDTimer.asm"
.include "BKPracticeICs/FreezeClip.asm" //MUST BE PRIOR TO L2Levitate
.include "BKPracticeICs/L2Levitate.asm"
.include "BKPracticeICs/TakeOff.asm"
.include "BKPracticeICs/TransformMe.asm"
.include "BKPracticeICs/InputDisplay.asm"

//.include "BKPracticeICs/SetMoves.asm"

.align
;----------------------------------------------------------------
; Function List
;----------------------------------------------------------------
MenuFunctionList:
.word TakeMeThere_DefStruct
.word ResetOnEnter_DefStruct
.word Infinites_DefStruct
.word HUDInfo_DefStruct
.word HUDTimer_DefStruct
.word FreezeClip_DefStruct
.word L2Levitate_DefStruct
.word TakeOff_DefStruct
.word TransformMe_DefStruct
.word InputDisplay_DefStruct
//SetMoves
.word 0 ;!!!functionListMust end with 0!!!

;----------------------------------------------------------------
; Upon Exiting Practice Menu
;
;----------------------------------------------------------------
.align
ExitingMenuCode: ;DO NOT CHANGE THIS NAME
	ADDIU sp -0x28
	SW ra 0x1C(sp)
	SW a0 0x18(sp)
	SW a1 0x14(sp)
	SW a2 0x10(sp)

	MOV a0 zero
    PauseModeCode_Loop:
    LB at NumberOfOptions
    BEQ a0 at PauseModeCode_Housekeeping
    NOP
        LA a1 MenuFunctionList
        SLL a2 a0 2
        ADDU a2 a1 a2
        LW a2 0(a2)
        ;check if state not equal to 0
        LB a1 @DefStruct_State(a2)
        BEQ a1 zero PauseModeCode_Loop
        ADDIU a0 a0 1
            ;check if code has normal mode code
            LW a1 @DefStruct_PauseModePtr(a2)
            BEQ a1 zero PauseModeCode_Loop
            ADDIU a0 a0 1
                ;jump to function 
                JALR ra a1
                NOP
        B PauseModeCode_Loop
        ADDIU a0 a0 1

    PauseModeCode_Housekeeping:
	LW ra 0x1C(sp)
	LW a0 0x18(sp)
	LW a1 0x14(sp)
	LW a2 0x10(sp)
	ADDIU sp 0x28

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
    ;Menu Setup Code
    
    ;count menu items
	MOV a0 zero
    LA a1 MenuFunctionList
    NormalModeCode_MenuSetup_Count:
    LW a2 0(a1)   
    BEQ a2 zero NormalModeCode_MenuSetup_Count_End
    ADDIU a1 a1 0x04 
        B NormalModeCode_MenuSetup_Count
        ADDIU a0 a0 0x01 
    NormalModeCode_MenuSetup_Count_End:
    SB a0 NumberOfOptions
    SUBI a0 a0 0x04
    BGT a0 zero NormalModeCode_MenuSetup_Count_Fix
        NOP
        LI a0 0x01
    NormalModeCode_MenuSetup_Count_Fix:
    SB a0 PageTopMax
    
    ;asthetic setup
    JAL BetaPauseMenu
	NOP
	MOV a0 zero
NormalModeCode_MenuSetup:

MOV a0 zero
NormalModeCode_Loop:
LB at NumberOfOptions
BEQ a0 at NormalModeCode_Housekeeping
NOP
    LA a1 MenuFunctionList
    SLL a2 a0 2
    ADDU a2 a1 a2
    LW a2 0(a2)
    //check if state not equal to 0
    LB a1 @DefStruct_State(a2)
    BEQ a1 zero NormalModeCode_Loop
    ADDIU a0 a0 1
        //check if code has normal mode code
        LW a1 @DefStruct_NormalModePtr(a2)
        BEQ a1 zero NormalModeCode_Loop
        NOP
            //jump to function 
            JALR ra a1
            NOP
    B NormalModeCode_Loop
    NOP
    
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
.align



.align
OnOffOptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "ON\0\0\0\0\0"

MenuOptionStates: ;DO NOT CHANGE THIS NAME

MoveSet:
.byte 0

.align
MenuLabelStrings: ;DO NOT CHANGE THIS NAME
.asciiz "MOVE SET: \0\0\0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"


MenuOptionMaxStates: ;DO NOT CHANGE THIS NAME

MoveSetMaxState:
.byte 6

.align
MenuOptionStringSet: ;DO NOT CHANGE THIS NAME

MoveSetStringSet:
.word MoveSetOptionString

PreviousLoadzoneState:
.byte 0
.byte 0
.byte 0
.byte 0

/*Option strings*/


MoveSetOptionString: ;6
.asciiz "OFF\0\0\0\0"
.asciiz "NONE\0\0\0"
.asciiz "SM\0\0\0\0\0"
.asciiz "FFM\0\0\0\0" ;FFM no Eggs
.asciiz "FFM EGG" ;FFM Eggs
.asciiz "ALL\0\0\0\0"

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
.align

NumberOfOptions:
.byte 0
PageTopMax:
.byte 0