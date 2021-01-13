// Donkey Kong 64 - Cutscene Viewer
// By theballaam96
// http://www.twitter.com/tjballaam


// Cutscene Related Stuff
[SetCutscene]: 0x8061CC40
[ToPlayCutscene]: 0x807FFFF0
[FocusedActor]: 0x807FFFF4
[CutsceneIndex]: 0x807FFFF8
[CutsceneType]: 0x807FFFFC
[CutsceneCount]: 0x807F5BDC
[CutsceneGlobalCount]: 41

// Menu
[SelectedMenuSlot]: 0x807FFFD0
[SelectedType]: 0x807FFFD4
[SelectedCS]: 0x807FFFD8

// MIPS ASM
[ReturnAddressStorage]: 0x807FFFE0
[ReturnAddressStorage2]: 0x807FFFE4

// OSD
[WriteTextZone]: 0x807FCAA0
[PrintText]: 0x806ABB98
[ControllerInput]: 0x80014DC4
[NewlyPressedControllerInput]: 0x807ECD66

// Buttons
[L_Button]: 0x0020
[A_Button]: 0x8000
[D_Up]: 0x0800
[D_Down]: 0x0400
[D_Left]: 0x0200
[D_Right]: 0x0100

.org 	0x805fe354 // write over jump to SecuritySomething
JAL		StartSec

.org 0x805FC164 // retroben's hook but up a few functions
J Start

.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this

StartSec:
	JAL		0x80714060 // SecurityFunction
	NOP
	ADDI	a0, v0, 0x0 // put result in a0
	JAL		0x807132dc	 // v0 = global display list
	NOP
	ADDI	a0, v0, 0x0
	LH		a1, @ControllerInput
	ANDI 	a1, a1, @L_Button
	BEQZ 	a1, SecFinish
	NOP
	LW 		a1, @SelectedCS
	LW 		a3, @SelectedType
	LW 		a2, @CutsceneCount
	BEQZ 	a3, CheckCSIndex
	NOP
	LI 		a2, @CutsceneGlobalCount

	CheckCSIndex:
		SLTU 	a1, a1, a2 // if CSVal > CSMax, Correct
		BNEZ 	a1, StartButtonReading
		NOP
		SW 		a2, @SelectedCS

	StartButtonReading:
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Down
		BEQZ 	a1, CheckDUp
		NOP
		JAL 	IncMenuSlot
		NOP
		B 		ShowText
		NOP

	CheckDUp:
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Up
		BEQZ 	a1, CheckDLeft
		NOP
		JAL 	DecMenuSlot
		NOP

	CheckDLeft:
	// Hovering over CSIndex
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Left
		BEQZ 	a1, CheckDRight
		NOP
		LW 		a1, @SelectedMenuSlot
		BNEZ 	a1, CheckDL2 // Hovering over type or play
		NOP
		LW 		a1, @SelectedCS
		BEQZ 	a1, ShowText // CS = 0, Can't Decrement
		NOP

	DecCSIndex:
		ADDI 	a1, a1, -1
		SW 		a1, @SelectedCS
		B 		ShowText
		NOP

	CheckDL2:
	// Hovering over CSType
		LW 		a1, @SelectedMenuSlot
		LI 		a2, 1
		BNE 	a1, a2, ShowText
		NOP
		LW 		a1, @SelectedType
		LI 		a2, 1
		SUBU 	a1, a2, a1
		SW 		a1, @SelectedType
		B 		ShowText
		NOP

	CheckDRight:
	// Hovering over CSVal
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Right
		BEQZ 	a1, CheckA
		NOP
		LW 		a1, @SelectedMenuSlot
		BNEZ 	a1, CheckDR2 // Hovering over type or play
		NOP
		LW 		a1, @SelectedCS
		LW 		a3, @SelectedType
		LW 		a2, @CutsceneCount
		BEQZ 	a3, IncCSIndex
		NOP
		LI 		a2, @CutsceneGlobalCount

	IncCSIndex:
		SLTU 	a1, a1, a2 // if CSVal < CSMax, Continue
		BEQZ 	a1, ShowText
		NOP
		LW 		a1, @SelectedCS
		ADDIU 	a1, a1, 1
		SW 		a1, @SelectedCS

	CheckDR2:
	// Hovering over CSType
		LW 		a1, @SelectedMenuSlot
		LI 		a2, 1
		BNE 	a1, a2, ShowText
		NOP
		LW 		a1, @SelectedType
		LI 		a2, 1
		SUBU 	a1, a2, a1
		SW 		a1, @SelectedType
		B 		ShowText
		NOP

	CheckA:
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @A_Button
		BEQZ 	a1, ShowText
		NOP
		LW 		a1, @SelectedMenuSlot
		LI 		a2, 2
		BNE 	a1, a2, ShowText
		NOP
		LI 		a1, 1
		SW 		a1, @ToPlayCutscene
		LW 		a1, @SelectedCS
		SW 		a1, @CutsceneIndex
		LW 		a1, @SelectedType
		SLL 	a1, a1, 2 // Type * 4
		ADDIU  	a1, a1, 1
		SW 		a1, @CutsceneType
		B 		ShowText
		NOP

	ShowText:
		JAL 	DisplayText
		NOP

	SecFinish:
		J 		ReturnSecurity
		NOP

ReturnSecurity:
	JAL		0x805fe358
	NOP

Start:
	// Run the code we replaced
	JAL     0x805FC2B0
	NOP
	LW 		a0, @ToPlayCutscene
	BEQZ	a0, Return
	SW 		r0, @ToPlayCutscene
	LW 		a0, @FocusedActor
	LW 		a1, @CutsceneIndex
	LW 		a2, @CutsceneType
	JAL 	@SetCutscene
	NOP

Return:
	J       0x805FC15C // retroben's hook but up a few functions
	NOP

IncMenuSlot:
	LW 		a1, @SelectedMenuSlot
	ADDIU 	a1, a1, 1
	LI 		a2, 3 // Cap Detection
	BNE 	a1, a2, IncMSStore
	NOP
	LI 		a1, 2

	IncMSStore:
		SW 	a1, @SelectedMenuSlot
		JR 	ra
		NOP

DecMenuSlot:
	LW 		a1, @SelectedMenuSlot
	BEQZ 	a1, DecMSStore
	NOP
	ADDI 	a1, a1, -1

	DecMSStore:
		SW 	a1, @SelectedMenuSlot
		JR 	ra
		NOP

DisplayText:
// Code based of GloriousLiar's "Take Me There w/ GUI" code
// twitter.com/gloriousliar
LI		t9, 0x1					// num of menu text items
;		a0 						// global_display_list
LI		a1, 650					// x = 132
LI		a2, 69					// y = 116
LI		a3, 0x3f000000			// scale = 0.5f
LA		t0, CutsceneMenu
ADDI	t0, t0, 0x1
SW 		ra, @ReturnAddressStorage2
B 		PrintLoop
NOP

	PrintLoop:
		LI		a1, 650					// x = 132
		LA		t1, @WriteTextZone
		LH		t1, 0x0(t1)				// t1 = s16[t1]
		LA		t2, CutsceneMenu
		ADD		t1, t1, t2				// t1 = offset + @CutsceneMenu
		ADDI 	t5, t9, -1

	CheckIfCSVal:
		// Digits are offset 0x12, 0x13
		BNEZ 	t5, CheckIfCSType
		NOP
		LW 		t6, @SelectedCS
		LI 		t7, 10
		DIVU 	t6, t7 					// HI = t6 % 10, LO = floor(t6 / 10)
		MFLO 	t6 						// CS 13 => 1
		MFHI 	t7 						// CS 13 => 3
		ADDIU 	t6, t6, 0x30
		ADDIU 	t7, t7, 0x30
		SB 		t6, 0x12 (t1)
		SB 		t7, 0x13 (t1)
		// Cap is offset 0x18, 0x19
		LW 		t6, @SelectedType
		BEQZ 	t6, IsMapVal
		LI 		t7, 10
		

	IsGlobalVal:
		LI 		t6, @CutsceneGlobalCount // Global CS Count
		DIVU 	t6, t7 					// HI = t6 % 10, LO = floor(t6 / 10)
		MFLO 	t6 						// CS 13 => 1
		MFHI 	t7 						// CS 13 => 3
		ADDIU 	t6, t6, 0x30
		ADDIU 	t7, t7, 0x30
		SB 		t6, 0x18 (t1)
		SB 		t7, 0x19 (t1)
		B 		ResizeText
		NOP

	IsMapVal:
		LH 		t6, @CutsceneCount
		SW 		t6, 0x807FFFE8
		DIVU 	t6, t7 					// HI = t6 % 10, LO = floor(t6 / 10)
		MFLO 	t6 						// CS 13 => 1
		MFHI 	t7 						// CS 13 => 3
		ADDIU 	t6, t6, 0x30
		ADDIU 	t7, t7, 0x30
		SB 		t6, 0x18 (t1)
		SB 		t7, 0x19 (t1)

	CheckIfCSType:
		// Text is offset 0x2B, 0x2C, 0x2D
		LI 		t6, 1
		BNE 	t5, t6, ResizeText
		NOP
		LW 		t6, @SelectedType
		BEQZ 	t6, IsMap
		NOP

	IsGlobal:
		LI 		t7, 0x47 // G
		SB 		t7, 0x2B (t1)
		LI 		t7, 0x42 // B
		SB 		t7, 0x2C (t1)
		LI 		t7, 0x4C // L
		SB 		t7, 0x2D (t1)
		B 		ResizeText
		NOP

	IsMap:
		LI 		t7, 0x4D // M
		SB 		t7, 0x2B (t1)
		LI 		t7, 0x41 // A
		SB 		t7, 0x2C (t1)
		LI 		t7, 0x50 // P
		SB 		t7, 0x2D (t1)
		SW 		t1, 0x807FFFEC

	ResizeText:
		SUB		t3, t0, t2				// t3 = offset from @CutsceneMenu
		ADD		t2, t2, t3				// t2 = @CutsceneMenu + t3
		LW 		t4, @SelectedMenuSlot
		BEQ		t5, t4, PrintIsSelected
		NOP
		B 		PrintIsNotSelected
		NOP

	PrintIsSelected:
		LI 		a3, 0x3F19999A 			// scale = 0.75f
		B 		Print
		NOP

	PrintIsNotSelected:
		LI 		a3, 0x3F000000 			// scale = 0.50f

	Print:	
		ADDIU	sp, sp, -0x34	
		SW		t0, 0x10(sp)
		SW		t9, 0x14(sp)
		SW		a1, 0x18(sp)
		SW		a2, 0x22(sp)
		SW		a3, 0x26(sp)
		SW 		ra, @ReturnAddressStorage
		JAL		@PrintText				// PrintText
		NOP
		LW 		ra, @ReturnAddressStorage
		LW		t0, 0x10(sp)
		LW		t9, 0x14(sp)
		LW		a1, 0x18(sp)
		LW		a2, 0x22(sp)
		LW		a3, 0x26(sp)
		ADDIU	sp, sp, 0x34
		ADDI	a0, v0, 0x0				// update global display list
		B 		FindZero
		NOP

	FindZero:
		LB		t1, 0x0(t0)
		BEQZ	t1, SetNextParams
		NOP
		ADDIU	t0, 0x1
		B		FindZero
		NOP
		
	SetNextParams:
		ADDIU	t0, t0, 0x1				// move past nullchar on level text						
		ADDIU	a2, a2, 0x30			// y+=48
		LI 		t1, 4 					// Cap
		ADDI	t9, t9, 0x1				// t9++

	CheckLoop:
		BNE		t1, t9, PrintLoop		// if t9 != cap, loop
		NOP
		B 		PrintReturn
		NOP

	PrintReturn:
		LW 		ra, @ReturnAddressStorage2
		JR 		ra
		NOP

.align
CutsceneMenu:
// TODO: Check whether this can be generalised with some function rather than using a separate table
	.byte 0x0;dummy
	.asciiz "CUTSCENE VALUE - 00 OF 00"
	.asciiz "CUTSCENE TYPE - MAP"
	.asciiz "PLAY"