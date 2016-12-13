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

//Variables
[NumberOfOptions]: 0x06
[PageTopMax]: 0x02

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
PUSH s2

LB a0 InPracMenu
BEQ a0 zero NotInPracMenu
NOP 

InPracMenu:
    /*UPDATE DISPLAY*/

	MOV s3 zero
//for(s3=0; s3<4; s3++)
	PracticeMenuText_Loop:
    	LA a1 MenuLabelStrings
    	LB a0 PageTopPos
		ADDU a0 a0 s3
		SLL s2 a0 4
		ADDU a1 a1 s2
		
    	LA a0 MenuItemStr 
		SLL s2 s3 5
		ADDU a0 a0 s2
		
    	JAL @CopyString
		NOP
		
		LA a1 MenuOptionStates
		LA a2 MenuOptionStringSet
		ADDU a1 a1 s3
		LB a0 PageTopPos
		ADDU a1 a1 a0
		LB a1 0(a1)
		ADDU a0 a0 s3
		SLL a0 a0 2
		ADDU a2 a2 a0		
		LW a2 0(a2)
		SLL a1 a1 3
		ADDU a1 a1 a2
		
		LA a0 MenuItemStr 
		SLL s2 s3 5
		ADDU a0 a0 s2
		
		JAL @AppendString
		NOP
		
		ADDIU s3 s3 1 ;s3++
		LI a0 0x04
		BNE s3 a0 PracticeMenuText_Loop
		NOP
	
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
            LI a1 @PageTopMax
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
	BNEZ a0 NoDPadLeftPress 
		NOP
		//Get CurrentHighlighted Option
		LB a0 PageTopPos
		LB a1 PracMenuCursorPos
		ADDU a0 a0 a1
		LA a1 MenuOptionStates
		ADDU a1 a1 a0
		LB a0 0(a1)
		//increment current option's state
		BEQZ a0 ClampToZeroOptionState
		NOP
			ADDI a0 a0 -1
		ClampToZeroOptionState:
		SB a0 0(a1)
		
		//Need to clamp
		
	NoDPadLeftPress:
    
		

	LA a0 @P1DPadRight ;right - next option
	LW a0 0(a0)
	XORI a0, a0, 1
    
	BNEZ a0 NoDPadRightPress 
		NOP
		//Get CurrentHighlighted Option
		LB a0 PageTopPos
		LB a1 PracMenuCursorPos
		ADDU a0 a0 a1
		LA a1 MenuOptionStates
		ADDU a1 a1 a0
		MOV s3 a0 ;option number
		LB a0 0(a1)
		//increment current option's state
		ADDIU a0 a0 1
		LA s2 MenuOptionMaxStates
		ADDU s2 s2 s3
		LB a2 0(s2)
		ADDI a2 a2 -1
		MOV a1 zero
		JAL @ClampInt
		NOP
		LA a1 MenuOptionStates
		ADDU a1 a1 s3
		SB v0 0(a1)
		//Need to clamp
		
		
	NoDPadRightPress:
	
	

	;check if exiting practice menu
	LA a0 @P1Start
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 StayInPracPause ;If start press
	MOV a0 zero
		SB a0 InPracMenu ;set InPracMenu
		
		//ONE SHOT EXITING MENU CODES
		;If GiveMoveSet
		LB s3 MoveSet
		BEQZ s3 KeepCurrentMoveSet
		LI a1 0x01
			//NONE
			JAL @LockAllMoves
			NOP
			BEQ s3 a1 KeepCurrentMoveSet
			LI a1 0x02
			
			//SM Set
			LUI a0 0x000B
			ADDIU a0 a0 0xFDBF
			JAL @SetMovesUnlockedBitfield
			NOP
			BEQ s3 a1 KeepCurrentMoveSet
			LI a1 0x03
			
			//FFM
			LUI a0 0x000B
			ADDIU a0 a0 0xFDBF
			JAL @SetMovesUnlockedBitfield
			NOP
			BEQ s3 a1 KeepCurrentMoveSet
			LI a1 0x03
			
			//FFM + EGGS
			LUI a0 0x000B
			ADDIU a0 a0 0xFDFF
			JAL @SetMovesUnlockedBitfield
			NOP
			BEQ s3 a1 KeepCurrentMoveSet
			
			//ALL
			LUI a0 0x000F
			ADDIU a0 a0 0xFFFF
			JAL @SetMovesUnlockedBitfield
			NOP
			
		KeepCurrentMoveSet:
		SB zero MoveSet

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
POP s2
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
		SLL s3 s2 2    ; i*4
		ADDU s3 a3 s3  ; i*4
		LW a0 0x10(s3)
		SLL a3 s2 5
		LA s3 MenuItemStr
		ADDU a1 s3 a3 ;menuItemStr + i<<5
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

//cheatMenuNotSetUp
LB a0 PracMenuSetup
BEQ a0 zero NormalModeCode_MenuSetup
NOP
    JAL BetaPauseMenu
    NOP
    MOV a0 zero
NormalModeCode_MenuSetup:

//Take Me There
LB a0 TakeMeThereState
BEQ a0 zero NormalModeCode_TakeMeThereEnd
	;convert from option number  to level index
	
	LI at 0x01
	;Reorder levels
	BEQL a0 at TakeMeThereWorkLoad
	LI a0 0x0B
		LI at 0x08
		BEQL a0 at TakeMeThereWorkLoad
		LI a0 0x0A
			LI at 0x0A
			BEQL a0 at TakeMeThereWorkLoad
			LI a0 0x08
				LI at 0x0D
				BEQL a0 at TakeMeThereWorkLoad
				LI a0 0x0C
					LI at 0x06
					SUB at a0 at
					BLEZL at TakeMeThereWorkLoad
					SUBI a0 a0 1
						LI a1 0x01
						LI at 0x0B
						BEQL a0 at TakeMeThereNotLevel
						LI v0 0x8E
							LI a1 0x0A
							LI at 0x0C
							BEQL a0 at TakeMeThereNotLevel
							LI v0 0x93
	TakeMeThereWorkLoad:
	JAL @GetMainExitFromLevelIndex
	NOP
	JAL @GetMainMapFromLevelIndex
	MOV a1 v0
	TakeMeThereNotLevel:
	LI a2 1
	JAL @TakeMeThere_LevelReset
	MOV a0 v0
	SB zero TakeMeThereState
	
NormalModeCode_TakeMeThereEnd:

LB a0 TransformMeState
BEQ a0 zero NormalModeCode_TransformMeEnd

	LB a0 TransformMeState
	JAL @SetMumboTransformation
	NOP
	JAL @UpdatePlayerModelToMumboTransFormation
	NOP
	SB zero TransformMeState
	
NormalModeCode_TransformMeEnd:

;If Press-L to levitate ste
	;JAL PressLToLevitate ;Press-L to levitate code
LB a0 L2LevitateState
BEQ a0 zero NormalModeCode_LToLevitateNormal
NOP
	JAL @GetButtonPressTimer
	LI a0 0x02 ;L button Index
	BEQ v0 zero NormalModeCode_LToLevitateNormal
	LUI a0 0x4220
		MTC1 zero f12
		JAl @SetYVelocity ;Vel increases while airborn, if Vel > pos change then banjo still falls
		LUI a0 0x41a0
		MTC1 a0 f12
		JAl @AddToYPos
		NOP
NormalModeCode_LToLevitateNormal:

;If Ingame-Timer/AutoSplitter
	;JAL Ingame-Timer
	NOP

;If Infinites
LB a0 InfinitesState
BEQ a0 zero NormalModeCode_InfinitesNormal
NOP
	LI a1 @ItemBase  
	LI a0 900
	SW a0 0x30(a1) ;Notes
	LI a0 100
	SW a0 0x34(a1) ;Eggs
	SW a0 0x98(a1) ;Jiggies
	LI a0 50
	SW a0 0x3C(a1) ;Reds
	LI a0 50
	SW a0 0x40(a1) ;Golds
	LI a0 5
	SW a0 0x50(a1) ;Health
	LI a0 9
	SW a0 0x58(a1) ;Lives
	LI a0 0xE10
	SW a0 0x5C(a1) ;Air
	LI a0 99
	SW a0 0x70(a1) ;MumboTokens_OnHand
	SW a0 0x94(a1) ;MumboTokens
	SW a0 0x9C(a1) ;JokerCards
	
	
NormalModeCode_InfinitesNormal:

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

MenuOptionStates:
InfinitesState:
.byte 0
ResetOnEnterState:
.byte 0
TakeMeThereState:
.byte 0
MoveSet:
.byte 0
L2LevitateState:
.byte 0
TransformMeState:
.byte 0

MenuItemStr:
.asciiz "PRACTICE MENU 1: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 2: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 3: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 4: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"

/*Option string*/
/*TO DO: CHANGE TO STUCT {ascii, MaxOptions, Pointer to Option Sting}*/ 
MenuLabelStrings:
.asciiz "INFINITES: \0\0\0\0"     ; OFF, ON
.asciiz "RESET ON ENTER:"         ; OFF, ON
.asciiz "TAKE ME THERE: "         ; OFF, SM, MM, TTC, CC, BGS, FP, GV, MMM, RBB, CCW, FF, DOG, GRUNTY
.asciiz "MOVE SET: \0\0\0\0\0"    ; OFF, NONE, FFM, ALL
.asciiz "L 2 LEVITATE: \0"      ;ON, OFF
.asciiz "TRANSFORM ME: \0"	  ;OFF, BANJO, TERMITE, CROC, WALRUS, PUMPKIN, BEE, WASHY
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

MenuOptionMaxStates:
InfinitesMaxState:
.byte 2
ResetOnEnterMaxState:
.byte 2
TakeMeThereMaxState:
.byte 14
MoveSetMaxState:
.byte 6
L2LevitateMaxState:
.byte 2
TransformMeMaxState:
.byte 1

.align 2 0
MenuOptionStringSet:
InfinitesStringSet:
.word OnOffOptionString
ResetOnEnterStringSet:
.word OnOffOptionString
TakeMeThereStringSet:
.word TakeMeThereOptionString
MoveSetStringSet:
.word MoveSetOptionString
L2LevitateStringSet:
.word OnOffOptionString
TransformMeStringSet:
.word OnOffOptionString

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




