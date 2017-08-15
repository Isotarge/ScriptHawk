PauseMode:
ADDIU sp -0x38
SW ra 0x2C(sp)
SW a0 0x28(sp)
SW a1 0x24(sp)
SW a2 0x20(sp)
SW at 0x1C(sp)
SW s3 0x18(sp)
SW s2 0x14(sp)

LB a0 InPracMenu
BEQ a0 zero NotInPracMenu
NOP

InPracMenu:
	/*UPDATE DISPLAY*/

	MOV s3 zero
//for(s3=0; s3<4; s3++)
	PracticeMenuText_Loop:
        LA a1 MenuFunctionList
		LB a0 PageTopPos
		ADDU a0 a0 s3
		SLL s2 a0 2
		ADDU a1 a1 s2
        LW a1 0(a1)
        SW a1 0x30(sp)
        ADDIU a1 a1 @DefStruct_Label

		LA a0 MenuItemStr
		SLL s2 s3 5
		ADDU a0 a0 s2

		JAL @CopyString
		NOP

		LW a1 0x30(sp)
        LW a2 @DefStruct_MenuOptionString(a1)
		LB a1 @DefStruct_State(a1)
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

	;ChangeCursor and topPos based on controls
	LA a0 @P1DPadUp ;Up - up one pos
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 NoDPadUpPress
	LB a0 PracMenuCursorPos
		BNEZ a0 NotAtPageTop ;if(cursor on bottom option)
		NOP
			SW a0 0x30(sp)
			LB a1 PageTopPos
			ADDI a0 a1 -1
			JAL @SelectMaxInt
			MOV a1 zero  ;PageTopMin
			LW a0 0x30(sp)
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
			LB a1 PageTopPos
			ADDI a0 a1 1
            LB a1 PageTopMax
			JAL @SelectMinInt
			NOP
			SB v0 PageTopPos
			B NoDPadDownPress
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
		LA a1 MenuFunctionList
        SLL a0 a0 2
		ADDU a1 a1 a0
        LW a1 0(a1)
		LB a0 @DefStruct_State(a1)
		//increment current option's state
		BEQZ a0 ClampToZeroOptionState
		NOP
			ADDI a0 a0 -1
		ClampToZeroOptionState:
		SB a0 @DefStruct_State(a1)

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
		LA a1 MenuFunctionList
        MOV s3 a0 ;option number
        SLL a0 a0 2
		ADDU a1 a1 a0
		LW a1 0(a1)
        SW a1 0x30(sp)
        LB a0 @DefStruct_State(a1)
		//increment current option's state
		ADDIU a0 a0 1
		LB a2 @DefStruct_MaxState(a1)
		ADDI a2 a2 -1
		JAL @ClampInt
		MOV a1 zero
        LW a1 0x30(sp)
        SB v0 @DefStruct_State(a1)
		//Need to clamp


	NoDPadRightPress:

	;check if exiting practice menu
	LA a0 @P1Start
	LW a0 0(a0)
	XORI a0, a0, 1
	BNEZ a0 StayInPracPause ;If start press
	MOV a0 zero
		SB a0 InPracMenu ;set InPracMenu

		JAL ExitingMenuCode
		NOP

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
		LA a1 InPracMenu
		SB a0 0(a1) ;set InPracMenu
		NOP
	StayInNormPause:
NOP

HouseKeeping:
LW s2 0x14(sp)
LW s3 0x18(sp)
LW at 0x1C(sp)
LW a2 0x20(sp)
LW a1 0x24(sp)
LW a0 0x28(sp)
LW ra 0x2C(sp)
ADDIU sp 0x38
JR
NOP

;----------------------------------------------------------------
; Highlight Cursor Position
; Inputs: byte $a0 Cursor Position
;----------------------------------------------------------------
HighlightCursorPosition:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a1 0x20(sp)
SW a2 0x1C(sp)
SW a3 0x18(sp)
SW s3 0x14(sp)

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

LW ra 0x24(sp)
LW a1 0x20(sp)
LW a2 0x1C(sp)
LW a3 0x18(sp)
LW s3 0x14(sp)
ADDIU sp 0x28
JR
NOP

;----------------------------------------------------------------
; Restore Main Menu Text
; Inputs: void
;----------------------------------------------------------------
RestoreMainMenuText:
ADDIU sp -0x30
SW ra 0x2C(sp)
SW a0 0x28(sp)
SW a1 0x24(sp)
SW a2 0x20(sp)
SW a3 0x1C(sp)
SW s2 0x18(sp)

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

LW ra 0x2C(sp)
LW a0 0x28(sp)
LW a1 0x24(sp)
LW a2 0x20(sp)
LW a3 0x1C(sp)
LW s2 0x18(sp)
ADDIU sp 0x30
JR
NOP

;----------------------------------------------------------------
; Print practice Menu Text
; Inputs: void
;----------------------------------------------------------------

PrintPracMenuText:
ADDIU sp -0x30
SW ra 0x2C(sp)
SW a0 0x28(sp)
SW a1 0x24(sp)
SW a2 0x20(sp)
SW a3 0x1C(sp)
SW s3 0x18(sp)
SW s2 0x14(sp)

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

LW ra 0x2C(sp)
LW a0 0x28(sp)
LW a1 0x24(sp)
LW a2 0x20(sp)
LW a3 0x1C(sp)
LW s3 0x18(sp)
LW s2 0x14(sp)
ADDIU sp 0x30
JR
NOP

;----------------------------------------------------------------
; Beta Menu Code
;
;----------------------------------------------------------------
BetaPauseMenu:
ADDIU sp -0x20
SW a0 0x18(sp)
SW a1 0x14(sp)

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

LW a0 0x14(sp)
LW a1 0x18(sp)
ADDIU sp 0x20
JR
NOP

;----------------------------------------------------------------
; Static Variables (only used by functions in this file)
;
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

.align
MenuItemStr: ;DO NOT CHANGE THIS NAME
.asciiz "PRACTICE MENU 1: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 2: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 3: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 4: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
