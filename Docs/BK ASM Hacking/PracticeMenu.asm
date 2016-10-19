//Banjo-Kazooie Speedrunning Cheat Menu
//Enter Main Menu by pressing start, then press D-left to switch to practice menu
//  Press D-Right to return to main menu
//
//
//
//


;PAUSE MODE JUMP LOCATION: 0x802E47F4
;NORMAL MODE JUMP LOCATION: 0x80334FFC



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
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH at

LB a0 InPracMenu
BEQ a0 zero NotInPracMenu
NOP 

InPracMenu:
	;;;Pracitce Menu stuff
	;Print Cursor Text
	JAL PrintPracMenuText

	;Highlight cursor position
	LB a0 PracMenuCursorPos
	JAL HighlightCursorPosition
	NOP


	;;;ChangeCursor and topPos based on controls
	LA a0 @P1DPadUp ;Up - up one pos
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 NoDPadUpPress 
	LB a0 PracMenuCursorPos
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
		ADDIU a0 a0 1
		JAL @SelectMinInt
		LI a1 0x03
		SB v0 PracMenuCursorPos
	NoDPadDownPress:

	LA a0 @P1DPadLeft ;left - previous option
	LW a0 0(a0)
	XORI a0, a0, 1
		

	LA a0 @P1DPadRight ;right - next option
	LW a0 0(a0)
	XORI a0, a0, 1


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
	JAL @PauseMenu
	NOP
	;check if entering practice menu
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
; Get Prac Menu Text
; Inputs: byte $a0 PageTopPos
;----------------------------------------------------------------

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

InPracMenu:
.byte 0
PracMenuCursorPos:
.byte 0
PracMenuOptionNumber:
.byte 0
PageTopPos:
.byte 0

MenuItemStr:
.asciiz "PRACTICE MENU 1: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 2: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 3: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 4: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"

MenuLabelStrings:
.asciiz "INFINITES: \0\0\0\0\0"  ; OFF, ON
.asciiz "RESET ON ENTER:\0" ; OFF, SINGLE, ALL
.asciiz "MOVE SET: \0\0\0\0\0\0" ;OFF, NONE, FFM, ALL
.asciiz "TAKE ME THERE: \0"; OFF, SM, MM, TTC, CC, BGS, FP, GV, MMM, RBB, CCW, FF, DOG, GRUNTY
.asciiz "L 2 LEVITATE: \0\0\0" ;ON, OFF
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"



;----------------------------------------------------------------
; Shared Variables
; BitFlags
;----------------------------------------------------------------

