//Banjo-Kazooie Speedrunning Cheat Menu
//Enter Main Menu by pressing start, then press D-left to switch to practice menu
//  Press D-Right to return to main menu
//
//
// TO DO: Append Each menu item's current state to end of sting
//        Create functions for setting enable bits/states for each
//        Create normal mode code section

// HOOKS

;PAUSE MODE JUMP LOCATION: 0x802E47F4
.org 0x802E47F4
JAL 0x80400000
NOP

;NORMAL MODE JUMP LOCATION: 0x80334FFC
.org 0x80334FFC
JAL NormalModeCode
NOP

//EXISTING FUNCTIONS
.include "Docs/BK ASM Hacking/BK_NTSC.S"

//EXISTING VARIABLES
[P1DPadUp]:0x8028115C
[P1DPadDown]:0x80281160
[P1DPadLeft]:0x80281164
[P1DPadRight]:0x80281168
[P1Start]:0x8028116C
[PauseMenuData]:0x8036C4E0
[PauseMenuState]:0x80383010

;----------------------------------------------------------------
; Code Run from Pause Mode
; 
;----------------------------------------------------------------

.org 0x80400000
PauseMode:
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH at
PUSH s3

LB a0 InPracMenu
BEQ a0 zero NotInPracMenu
NOP 

InPracMenu:
    /*UPDATE DISPLAY*/

    ;Calculate Text
    LA a0 MenuLabelStrings
    LB a1 PageTopPos
    SLL a1 a1 4 
    ADD a1 a0 a1
    LA a0 MenuItemStr
    PUSH a0
    PUSH a1
    JAL @CopyString
    NOP
    //append option1's current state
    POP a1
    POP a0
    ADDIU a1 0x10
    ADDIU a0 0x20
    PUSH a0
    PUSH a1
    JAL @CopyString
    NOP
    //append option2's current state
    POP a1
    POP a0
    ADDIU a1 0x10
    ADDIU a0 0x20
    PUSH a0
    PUSH a1
    JAL @CopyString
    NOP
    //append option3's current state
    POP a1
    POP a0
    ADDIU a1 0x10
    ADDIU a0 0x20
    JAL @CopyString
    NOP
    //append option4's current state
	JAL PrintPracMenuText

	;Highlight cursor position
	LB a0 PracMenuCursorPos
	JAL HighlightCursorPosition
	NOP

    
    /* UPDATE OPTION BASED ON BUTTON INPUTS*/
    
	;;;ChangeCursor and topPos based on controls
	LA a0 @P1DPadUp ;Up - up one pos
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 NoDPadUpPress 
	LB a0 PracMenuCursorPos
        BNEZ a0 NotAtPageTop ;if(cursor on bottom option)
        NOP
            PUSH a0
            LB a1 PageTopPos
            ADDI a0 a1 -1
            JAL @SelectMaxInt
            MOV a1 zero  ;PageTopMin
            POP a0
            SB v0 PageTopPos
            B NoDPadUpPress
            NOP
            
        NotAtPageTop:
		ADDI a0 a0 -1
		JAL @SelectMaxInt
		LI a1 0
		SB v0 PracMenuCursorPos
		B NoDPadDownPress
		NOP
	NoDPadUpPress:

	LA a0 @P1DPadDown ;Down - down one pos
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 NoDPadDownPress 
	LB a0 PracMenuCursorPos
        LI a1 0x03
        BNE a0 a1 NotAtPageBottom
        NOP
            PUSH a0
            LB a1 PageTopPos
            ADDI a0 a1 1
            JAL @SelectMinInt
            LI a1 0x01  ;PageTopMax
            POP a0
            SB v0 PageTopPos
            B NoDPadDownPress
            POP a0
        NotAtPageBottom:
		ADDIU a0 a0 1
		JAL @SelectMinInt
		LI a1 0x03
		SB v0 PracMenuCursorPos
	NoDPadDownPress:

	LA a0 @P1DPadLeft ;left - previous option
	LW a0 0(a0)
	XORI a0, a0, 1
    //decrement current option's state
		

	LA a0 @P1DPadRight ;right - next option
	LW a0 0(a0)
	XORI a0, a0, 1
    //increment current option's state


	;check if exiting practice menu
	LA a0 @P1Start
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 StayInPracPause ;If start press
	MOV a0 zero
		SB a0 InPracMenu ;set InPracMenu
		
		;;One Shot Codes
		;If TakeMeThere
			;JAL TakeMeThere
			NOP
		;If GiveMoveSet
			;JAL GiveMoveSet
			NOP
		;Transform Me
			;JAL

		;Copy real menu strings back
		JAL RestoreMainMenuText
		NOP
		JAL PrintPracMenuText
		NOP

	StayInPracPause:
MOV v0 zero 
B HouseKeeping

NotInPracMenu:
    LA a0 @ReturnToLairEnabled
    SB zero 0(a0)
	JAL @PauseMenu
	NOP
	;check if entering practice menu
    LA a0 @PauseMenuState
    LB a0 0(a0)
    LI a1 0x02 ;main pause menu screen open
    BNE a0 a1 StayInNormPause
	NOP
        LA a0 @P1DPadLeft
        LW a0 0(a0)
	    XORI a0, a0, 1
	    BNEZ a0 StayInNormPause ;If d-left press
	    LI a0 0x01
		   SB a0 InPracMenu ;set InPracMenu
		   NOP
	StayInNormPause:
NOP

HouseKeeping:
POP s3
POP at
POP a2
POP a1
POP a0
POP ra
JR
NOP


;----------------------------------------------------------------
; Highlight Cursor Position
; Inputs: byte $a0 Cursor Position
;----------------------------------------------------------------
HighlightCursorPosition:
PUSH ra
PUSH a1
PUSH a2
PUSH a3
PUSH s3

	MOV a1 zero
	LI a2 0x04

	;set all 4 opacities to 80
	HighlightCursorPositionLoop:
	
		LA a3 @PauseMenuState
		SLL s3 a1 2
		ADDU s3 a3 s3
		LW a3 0x10(s3)
		BNE a1 a0 HighlightCursorPositionNotCursorPos
		LI s3 0x80
			LI s3 0xFF
		HighlightCursorPositionNotCursorPos:
		SB s3 0x169(a3)
		
		ADDIU a1 a1 1
		BNE a2 a1 HighlightCursorPositionLoop
		NOP
	;set opacity matching cursor position to FF

POP s3
POP a3
POP a2
POP a1
POP ra
JR
NOP

;----------------------------------------------------------------
; Restore Main Menu Text
; Inputs: void
;----------------------------------------------------------------
RestoreMainMenuText:
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3
PUSH s2

	MOV s2 zero
	LI a2 0x04

	RestoreMainMenuTextLoop:
		LA a1 @PauseMenuData
		SLL a3 s2 4
		ADDU a1 a1 a3
		LW a1 0x08(a1)

		SLL a3 s2 5
		LA a0 MenuItemStr
		ADDU a0 a0 a3 
		JAL @CopyString
		NOP
		ADDIU s2 s2 1
		BNE s2 a2 RestoreMainMenuTextLoop
		NOP

POP s2
POP a3
POP a2
POP a1
POP a0
POP ra
JR
NOP


;----------------------------------------------------------------
; Print practice Menu Text
; Inputs: void
;----------------------------------------------------------------

PrintPracMenuText:
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3
PUSH s2
PUSH s3

	MOV s2 zero
	LI a2 0x04

	PrintPracMenuTextLoop:
		LA a3 @PauseMenuState
		SLL s3 s2 2
		ADDU s3 a3 s3
		LW a0 0x10(s3)
		SLL a3 s2 5
		LA s3 MenuItemStr
		ADDU a1 s3 a3
		JAL @CopyString
		NOP
		ADDIU s2 s2 1
		BNE s2 a2 PrintPracMenuTextLoop
		NOP

POP s3
POP s2
POP a3
POP a2
POP a1
POP a0
POP ra
JR
NOP

;----------------------------------------------------------------
; Code Run from Normal Mode
;
;----------------------------------------------------------------
NormalModeCode:
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH at

;if beatMenuNotSetUp
LB a0 PracMenuSetup
BEQ a0 zero NormalModeCode_MenuSetup
NOP
    JAL BetaPauseMenu
    NOP
    MOV a0 zero
NormalModeCode_MenuSetup:

;If Press-L to levitate ste
	;JAL PressLToLevitate ;Press-L to levitate code
    NOP
;If Ingame-Timer/AutoSplitter
	;JAL Ingame-Timer
	NOP
;If Infinites
	;JAL Infinites
	NOP
;If resetUponEnteringLevel
	;JAL ResetUponEnteringLevel
	NOP
;If FastWarp
	;JAL FastWarp
	NOP
;If SaveStateCode
	;JAL SaveStateCode
	NOP
;If PositionDisplay
	;JAL PositionDisplay
	NOP

POP at
POP a2
POP a1
POP a0
POP ra
JR
NOP

;----------------------------------------------------------------
; Beta Menu Code
;
;----------------------------------------------------------------
BetaPauseMenu:
PUSH a0
PUSH a1

;Enable "Exit to lair
LA a0 @ReturnToLairEnabled
SB zero 0(a0)

;change menu items
LA a0 @PauseMenuStringsBase
LI a1 45
SH a1 0x0C(a0) ;YPos1

ADDIU a0 a0 0x10
LUI a1 0x3DCC
ADDIU a1 a1 0xCCCD
SW a1 0(a0)    ;timing
LI a1 75
SH a1 0x0C(a0) ;YPos2
LI a1 5
SB a1 0x0E(a0) ;Portrait

ADDIU a0 a0 0x10
LUI a1 0x3E4C
ADDIU a1 a1 0xCCCD
SW a1 0(a0)    ;timing
LI a1 105
SH a1 0x0C(a0) ;YPos3

ADDIU a0 a0 0x10
LUI a1 0x3E99
ADDIU a1 a1 0x999A
SW a1 0(a0)    ;timing
LI a1 135
SH a1 0x0C(a0) ;YPos4

POP a1
POP a0
JR
NOP

;----------------------------------------------------------------
; Global Variables
; BitFlags
;----------------------------------------------------------------
PracMenuSetup:
.byte 1
InPracMenu:
.byte 0
PracMenuCursorPos:
.byte 0
PracMenuOptionNumber:
.byte 0
PageTopPos:
.byte 0
InfinitesState:
.byte 0
ResetOnEnterState:
.byte 0
MoveSet:
.byte 0
TakeMeThereState:
.byte 0
L2LevitateState:
.byte 0

MenuItemStr:
.asciiz "PRACTICE MENU 1: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 2: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 3: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 4: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"

MenuLabelStrings:
.asciiz "INFINITES: \0\0\0\0"     ; OFF, ON
.asciiz "RESET ON ENTER:"         ; OFF, ON
.asciiz "MOVE SET: \0\0\0\0\0"    ; OFF, NONE, FFM, ALL
.asciiz "TAKE ME THERE: "         ; OFF, SM, MM, TTC, CC, BGS, FP, GV, MMM, RBB, CCW, FF, DOG, GRUNTY
.asciiz "L 2 LEVITATE: \0\0"      ;ON, OFF
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"





