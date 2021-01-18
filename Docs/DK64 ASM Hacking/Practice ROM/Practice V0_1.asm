// Donkey Kong 64 - Practice ROM
// By theballaam96
// http://www.twitter.com/tjballaam

// Note: Eventually we'll use Mittenz' Mr. Patcher to streamline this process dramatically
// https://github.com/MittenzHugg/Mr.Patcher
// It's very manual and hacky for now but it will improve

// To turn this patch into a ROM hack:

// You'll need:
// - DK64 US ROM
// - BizHawk + ScriptHawk
// - Hex editor
// - gedecompress
// - Decompressed DK64 ROM files (specifically 0113F0_ZLib.bin)
// - n64crc

// Method:
// TODO: Make this more readable and generalize it
// TODO: This might be slightly outdated now with version 4
// Use ScriptHawk's loadASMPatch() to assemble this file into vanilla DK64 US running RDRAM
// Copy the 4 patched bytes at the hook location into notepad or a hex editor, 0x5FC164 in RDRAM
// Find the original hook location using surrounding bytes in the decompressed version of 0113F0_ZLib.bin
// Overwrite the hook with the patched version
// Recompress the patched 0113F0_ZLib.bin with gedecompress
// If the recompressed 0113F0_ZLib.bin is smaller or the same size as the original (fits between 113F0 and C29D4 in ROM), overwrite it in ROM
// If it's bigger, you're out of luck for now (will be possible when tools & knowledge improve), try and decrease the entropy of the patch so it's smaller when recompressed
// Open BizHawk's hex editor and navigate to the main code in RDRAM at 0xDE88
// Copy all the patched bytes
// Overwrite the same bytes in ROM (it's uncompressed, near the start)
// Navigate to 0x3154 in ROM and replace with 0x00000000, this disables the security(or is it error?) checks on compressed files
// Save the patched ROM
// Fix the patched ROM's CRCs with n64crc

// Ideas
// [DONE] Map Warping - Might be able to do all maps, but at least the major ones:
	// Japes, Aztec, Factory, Galleon, Fungi, Caves, Castle, Isles
	// Helm (BoM off by default)
	// All 5 K Rool Phase maps (Temp flag shenanigans to prevent timer/phase bugs)
// [DONE] Unlock all moves/kongs/main menu bonuses
// [DONE] Position Warping - L+DR to save, L+DL to load
// [DONE] Tag Anywhere (1 button, simplified)
// On-Screen timer

// Bugs
// Trying to open OSD crashes on N64
// Non-DK Kongs don't have moves
// Warping causes some oddities. Add storing the following:
	// Stored Position
	// Facing Angle
	// Movement State
// Tag Anywhere Hand State


[InCutscene]: 0x807444EC
[TransitionSpeed]: 0x807FD88C
[CutsceneWillPlay]: 0x8075533B
[MysteryWriteOffset]: 0x29C
[CurrentCharacter]: 0x36F
[KRoolRound]: 0x80750AD4
[MovesBase]:  0x807FC950
[PlayerOneColour]: 0x807552F4
[Mode]: 0x80755318

// Buttons
[L_Button]: 0x0020
[D_Up]: 0x0800
[D_Down]: 0x0400
[D_Left]: 0x0200
[D_Right]: 0x0100
[B_Button]: 0x4000
[A_Button]: 0x8000

// MIPS ASM
[ReturnAddress]: 0x807FFFC0
[ReturnAddress2]: 0x807FFFC4

// OSD
[WriteTextZone]: 0x807FCAA0
[ControllerInput]: 0x80014DC4
[NewlyPressedControllerInput]: 0x807ECD66
[WarpY]: 69
[WipeY]: 117

// Tag Anywhere
[Player]: 0x807FBB4C
[SwapObject]: 0x807FC924
[Character]: 0x8074E77C

// FUNCTIONS
[SetFlag]: 0x8073129C
[PrintText]: 0x806ABB98
[PlaySFX]: 0x80609140 // a0 = Sound Effect, a1 = 0x7FFF, a2 = 427C0000, a3 = 0x3f800000, sp+0x10 = 0, sp + 0x14 = 0
[InitiateTransition]: 0x805FF378
[GetFlagBlockAddress]: 0x8060E25C

// Sound Effects
[Banana]: 0x2A0
[Okay]: 0x23C
[UhOh]: 0x150

// INTERNAL
[MenuOpen]: 0x807FFFFF // u8
[MapArrayIndex]: 0x807FFFFE // u8
[HasSavedPosition]: 0x807FFFFD // u8
[InManualWarp]: 0x807FFFFC // u8
[MenuPosition]: 0x807FFFFB // u8
[SavedPositions]: 0x807FFFE0 // 3x f32

.org 0x805FC164 // retroben's hook but up a few functions
J Start

.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this

StartSec:
	ADDI 	sp, sp, -0x10
	SW 		ra, 0x4(sp)
	JAL		0x80714060 // SecurityFunction
	NOP
	ADDI	a0, v0, 0x0 // put result in a0
	JAL		0x807132dc	 // v0 = global display list
	NOP
	ADDI	a0, v0, 0x0
	LH		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @D_Up
	BEQZ 	a1, CheckWhetherMenuShouldBeOpen
	NOP

	ToggleMenu:
		LI 		a2, 1
		LBU 	a1, @MenuOpen
		SUBU 	a1, a2, a1
		SB 		a1, @MenuOpen

	CheckWhetherMenuShouldBeOpen:
		LBU 	a1, @MenuOpen
		BEQZ 	a1, SecFinish
		NOP

	ShowText:
		JAL 	DisplayText
		NOP

	SecFinish:
		LW 		ra, 0x4(sp)
		ADDIU 	sp, sp, 0x10
		JR 		ra
		NOP

Start:
	// Run the code we replaced
	JAL     0x805FC2B0
	NOP
	// Load in Security hook
	LBU 	t3, @Mode
	SLTIU 	t3, t3, 5
	BNEZ 	t3, SetOtherVariables
	NOP
	LI 		t3, 0x0C0037A2
	SW 		t3, 0x805FE354
	SetOtherVariables:
	// Story Skip On
	LI 		t3, 1
	SB 		t3, 0x8074452C
	// Unlock Mystery Menu
	LI      t6, 0x807ED558
	LI      t0, 0xFFFFFFFF
	SW      t0, 0(t6)
	SW      t0, 4(t6)
	// Set K Rool to round 11 (Cause the sound effect is the best one)
	LI 		t6, 11
	LI 		t0, @KRoolRound
	SB 		t6, 0x0 (t0)
	LBU 	t0, @InCutscene
	LI 		t6, 6
	BEQ 	t0, t6, TransitionFunctions
	NOP
	LBU 	t0, @InManualWarp
	BNEZ 	t0, TransitionFunctions
	NOP
	LW 		t0, @TransitionSpeed
	LI 		t6, 0x3F800000
	BNE 	t0, t6, EveryFrameFunctions
	NOP

	TransitionFunctions:
		JAL 	CheckManualWarpClear
		NOP
		JAL 	UnlockMoves
		NOP
		JAL		FastFile
		NOP
		JAL		UnlockKongs
		NOP
		JAL 	ClearPositions
		NOP
		B 		Finish
		NOP

	EveryFrameFunctions:
		JAL 	TagAnywhere
		NOP
		JAL 	ChangeColour
		NOP
		JAL 	PositionSavestates
		NOP
		JAL 	ChangeSelectedMap
		NOP
		JAL 	ToggleMenu
		NOP
		JAL 	WarpToMap
		NOP
		JAL 	WipeFileHandler
		NOP

	Finish:
		J       0x805FC15C // retroben's hook but up a few functions
		NOP

UnlockMoves:
	LI 		a0, 4
	LI 		a1, @MovesBase
	WriteMoves:
		// Cranky
		LI 		t3, 3
		SB 		t3, 0x0 (a1) // Special
		SB 		t3, 0x1 (a1) // Slam Level
		LI 		t3, 7
		SB 		t3, 0x2 (a1) // Guns
		LI 		t3, 2
		SB 		t3, 0x3 (a1) // Ammo Belt
		LI 		t3, 15
		SB 		t3, 0x4 (a1) // Instrument
		BNEZ 	a0, WriteMoves
		ADDI 	a0, a0, -1 // Decrement Value for next kong
		ADDIU 	a1, a1, 0x5E // Next kong base

	// How were your trading barrels this run?
	// Dive Barrel
	SW 		ra, @ReturnAddress
	LI      a0, 386
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Vine Barrel
	LI      a0, 387
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Orange Barrel
	LI      a0, 388
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Barrel Barrel
	LI      a0, 389
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// BFI Camera/Shockwave
	LI      a0, 377
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP

// Fast File
FastFile:
	SW 		ra, @ReturnAddress
	// Waterfall CS
	LI      a0, 378
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Escape CS
	LI      a0, 390
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP


// Unlock Kongs
UnlockKongs:
	SW 		ra, @ReturnAddress
	// Diddy
	LI      a0, 6
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Tiny
	LI      a0, 66
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Lanky
	LI      a0, 70
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Chunky
	LI      a0, 117
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// DK
	LI      a0, 385
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP

// Tag Anywhere
TagAnywhere:
	LBU 	a1, @MenuOpen
	BNEZ 	a1, FinishTagAnywhere
	NOP
	LH 		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @D_Down
	BEQZ 	a1, FinishTagAnywhere // Not Pressing DDown
	NOP
	LBU 	a2, @Character
	ADDIU 	a2, a2, 1 // New Character Value
	LI 		a1, 5
	BNE 	a1, a2, ChangeCharacter // If Character + 1 != 5, Don't wrap around to 0
	NOP

	WrapAround:
		LI 	a2, 0

	ChangeCharacter:
		LW 		a1, @Player
		BEQZ 	a1, FinishTagAnywhere // If player isn't in RDRAM, cancel
		NOP
		ADDIU	a2, a2, 2
		SB 		a2, 0x36F (a1)
		LW 		a1, @SwapObject
		BEQZ 	a1, FinishTagAnywhere // If swap object isn't in RDRAM, cancel
		NOP
		LI 		a2, 0x3B
		SH 		a2, 0x29C (a1) // Initiate Swap

	FinishTagAnywhere:
		JR 		ra
		NOP

// Position Savestate
PositionSavestates:
	LH 		a1, @ControllerInput
	ANDI 	a1, a1, @L_Button
	BEQZ 	a1, FinishPositionWrite // Not holding L
	NOP

	CheckLeft:
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Left
		BEQZ 	a1, CheckRight
		NOP 
		B 		LoadPosition
		NOP

	CheckRight:
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Right
		BEQZ 	a1, FinishPositionWrite
		NOP
		B 		SavePosition
		NOP

	LoadPosition:
		LBU 	a1, @HasSavedPosition
		BEQZ 	a1, FinishPositionWrite // If no position saved, clear movement write
		NOP
		LW 		a1, @Player
		LI 		a3, @SavedPositions
		LW 		a2, 0x0 (a3) // X
		SW 		a2, 0x7C (a1)
		SW 		a2, 0x88 (a1)
		LW 		a2, 0x4 (a3) // Y
		SW 		a2, 0x80 (a1)
		SW 		a2, 0x8C (a1)
		LW 		a2, 0x8 (a3) // Z
		SW 		a2, 0x84 (a1)
		SW 		a2, 0x90 (a1)
		B 		FinishPositionWrite
		NOP

	SavePosition:
		LW 		a1, @Player
		LI 		a3, @SavedPositions
		LW 		a2, 0x7C (a1) // X Position
		SW 		a2, 0x0 (a3)
		LW 		a2, 0x80 (a1) // Y Position
		SW 		a2, 0x4 (a3)
		LW 		a2, 0x84 (a1) // Z Position
		SW 		a2, 0x8 (a3)
		LI 		a1, 1
		SB 		a1, @HasSavedPosition

	FinishPositionWrite:
		JR 		ra
		NOP

ClearPositions:
	LI 		a3, @SavedPositions
	SW 		r0, 0x0 (a3)
	SW 		r0, 0x4 (a3)
	SW 		r0, 0x8 (a3)
	SB 		r0, @HasSavedPosition
	JR 		ra
	NOP

// OSD Map
ChangeSelectedMap:
	SW 		ra, @ReturnAddress
	LBU 	a1, @MenuOpen
	BEQZ 	a1, FinishChange // Menu not open
	NOP
	LBU 	a1, @MenuPosition
	BNEZ 	a1, FinishChange // Menu not in position 0
	NOP
	LH 		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @D_Left
	BEQZ 	a1, CheckMenuRight
	NOP
	LBU 	a1, @MapArrayIndex
	BEQZ 	a1, LoopToEnd // If array index == 0, loop to end
	NOP
	ADDI 	a1, a1, -1
	B 		SetChange
	NOP

	CheckMenuRight:
		LH 		a1, @NewlyPressedControllerInput
		ANDI 	a1, a1, @D_Right
		BEQZ 	a1, FinishChange
		NOP
		LBU 	a1, @MapArrayIndex
		ADDIU 	a1, a1, 1
		LI 		a2, 14
		BNE 	a1, a2, SetChange
		NOP

	LoopToStart:
		LI 		a1, 0
		B 		SetChange
		NOP

	LoopToEnd:
		LI 		a1, 13
		B 		SetChange
		NOP

	SetChange:
		SB 		a1, @MapArrayIndex
		// Play Banana SFX
		LI 		a0, @Banana
		LI 		a1, 0x7FFF
		LI 		a2, 0x427C0000
		LI 		a3, 0x3F800000
		SW 		r0, 0x10 (sp)
		JAL 	@PlaySFX
		SW 		r0, 0x14 (sp)

	FinishChange:
		LW 		ra, @ReturnAddress 
		JR 		ra
		NOP

// Warp
WarpToMap:
	SW 		ra, @ReturnAddress
	LBU 	a1, @MenuOpen
	BEQZ 	a1, FinishWarp // Menu not open
	NOP
	LBU 	a1, @MenuPosition
	BNEZ 	a1, FinishWarp // Menu not in position 0
	NOP
	LH 		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @A_Button
	BEQZ 	a1, FinishWarp // A not pressed
	NOP
	// Close Menu
	SB 		r0, @MenuOpen
	// Turn BoM off (Helm)
	LI      a0, 770
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	// Clear some K Rool stuff to prevent Bugs
	// Tiny Phase Toe 1
	LI      a0, 81
	LI      a1, 0
	JAL     @SetFlag
	LI      a2, 2
	// Tiny Phase Toe 2
	LI      a0, 82
	LI      a1, 0
	JAL     @SetFlag
	LI      a2, 2
	// Tiny Phase Toe 3
	LI      a0, 83
	LI      a1, 0
	JAL     @SetFlag
	LI      a2, 2
	// Tiny Phase Toe 4
	LI      a0, 84
	LI      a1, 0
	JAL     @SetFlag
	LI      a2, 2
	// DK Phase Intro (Prevents fake phase)
	LI      a0, 93
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 2
	// Tiny Phase Intro (It's long)
	LI      a0, 88
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 2
	// Gorilla Gone CS
	LI      a0, 95
	LI      a1, 0
	JAL     @SetFlag
	LI      a2, 2
	// Play "Okay" SFX
	LI 		a0, @Okay
	LI 		a1, 0x7FFF
	LI 		a2, 0x427C0000
	LI 		a3, 0x3F800000
	SW 		r0, 0x10 (sp)
	JAL 	@PlaySFX
	SW 		r0, 0x14 (sp)
	// Set in manual warp
	LI 		a0, 1
	SB 		a0, @InManualWarp
	// Set Transition
	LA 		a1, WarpMapCodes
	LBU		a2, @MapArrayIndex
	ADD 	a1, a1, a2
	LBU 	a0, 0x1 (a1) // Destination Map
	SB 		r0, @CutsceneWillPlay // Prevents Meme bugs/crashes
	LI 		a1, 0 // Destination Exit
	JAL 	@InitiateTransition
	NOP
	SLTI 	a3, a0, 0xCB
	BNEZ	a3, FinishWarp // Not warping to K Rool
	NOP
	ADDI 	a3, a0, -0xCB // Get Character Index
	SB 		a3, @Character
	LI 		a3, 0xCD
	BEQ 	a0, a3 FinishWarp // If Lanky Phase, don't do some things
	NOP

	// Lanky Phase Bugs
	// Reset everything
	LI      a0, 92
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 2

	FinishWarp:
		LW 		ra, @ReturnAddress
		JR 		ra
		NOP

// Who says it's only Link's tunic which can change colour
ChangeColour:
	SW 		ra, @ReturnAddress
	SB 		r0, 0x8068A62F // Enable colouring for 1-player gameplay
	SW 		r0, 0x8068A450 // Turn off low poly models
	SW 		r0, 0x8068A458 // Turn off low poly models
	JAL 	0x8068A508
	NOP
	LA 		a0, KongColours
	LBU 	a1, @Character
	ADD 	a0, a0, a1
	LBU 	a1, 0x1 (a0)
	SW 		a1, @PlayerOneColour

	FinishColourChange:
		LW 		ra, @ReturnAddress
		JR 		ra
		NOP

CheckManualWarpClear:
	LW 		a0, @TransitionSpeed
	LI 		a1, 0xBF800000
	BNE 	a0, a1, FinishWarpClear
	NOP
	SB 		r0, @InManualWarp

	FinishWarpClear:
		JR 	ra
		NOP

WipeFile:
	SW 		ra, @ReturnAddress
	JAL 	@GetFlagBlockAddress
	NOP
	LI 		a0, 0x13B
	
	WipeProcess:
		SW 		r0, 0x0 (v0)
		BEQZ 	a0, WipeFinish
		NOP
		ADDI 	a0, a0, -1
		ADDI 	v0, v0, 4
		B 		WipeProcess
		NOP 		

	WipeFinish:
		LW 	ra, @ReturnAddress
		JR	ra
		NOP

ToggleMenu:
	SW 		ra, @ReturnAddress
	LBU 	a0, @MenuOpen
	BEQZ 	a0, FinishToggle
	NOP
	LH 		a0, @NewlyPressedControllerInput
	ANDI 	a0, a0, @D_Down
	BEQZ 	a0, FinishToggle
	NOP
	LBU 	a0, @MenuPosition
	LI 		a1, 1
	SUBU 	a0, a1, a0
	SB 		a0, @MenuPosition
	// Play Banana SFX
	LI 		a0, @Banana
	LI 		a1, 0x7FFF
	LI 		a2, 0x427C0000
	LI 		a3, 0x3F800000
	SW 		r0, 0x10 (sp)
	JAL 	@PlaySFX
	SW 		r0, 0x14 (sp)

	FinishToggle:
		LW 		ra, @ReturnAddress
		JR 		ra
		NOP

// Warp
WipeFileHandler:
	SW 		ra, @ReturnAddress2
	LBU 	a1, @MenuOpen
	BEQZ 	a1, FinishWipe // Menu not open
	NOP
	LBU 	a1, @MenuPosition
	BEQZ 	a1, FinishWipe // Menu in position 0
	NOP
	LH 		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @A_Button
	BEQZ 	a1, FinishWipe // A not pressed
	NOP
	JAL 	WipeFile
	NOP
	JAL 	UnlockMoves
	NOP
	JAL		FastFile
	NOP
	JAL		UnlockKongs
	NOP
	// Play UhOh SFX
	LI 		a0, @UhOh
	LI 		a1, 0x7FFF
	LI 		a2, 0x427C0000
	LI 		a3, 0x3F800000
	SW 		r0, 0x10 (sp)
	JAL 	@PlaySFX
	SW 		r0, 0x14 (sp)

	FinishWipe:
		LW 		ra, @ReturnAddress2
		JR 		ra
		NOP

DisplayText:
// Code based of GloriousLiar's "Take Me There w/ GUI" code
// twitter.com/gloriousliar
	LI		t9, 0x1					// num of menu text items
	;		a0 						// global_display_list
	LI		a1, 650					// x = 132
	LI		a2, @WarpY				// y = 116
	LBU		a3, @MapArrayIndex
	BEQZ 	a3, SetToVisible
	LI 		a3, 0					// Visibility
	B 		SetRestOfParams
	NOP

	SetToVisible:
		LI 	a3, 1

	SetRestOfParams:
		LA		t0, MenuText
		ADDI	t0, t0, 0x1
		SW 		ra, @ReturnAddress2
		B 		PrintLoop
		NOP

	PrintLoop:
		LI		a1, 650					// x = 132
		LA		t1, @WriteTextZone
		LH		t1, 0x0(t1)				// t1 = s16[t1]
		LA		t2, MenuText
		ADD		t1, t1, t2				// t1 = offset + @MenuText
		ADDI 	t5, t9, -1

	Print:	
		BEQZ 	a3, PrintReadjust		// If invisible, skip print
		NOP
		LI 		a3, @WarpY
		BNE 	a2, a3, NotWarp
		NOP
		// Is Warp
		LBU		a3, @MenuPosition
		BEQZ 	a3, ItemSelected
		NOP
		B 		ItemUnselected
		NOP

	NotWarp:
		LI 		a3, @WipeY
		BEQ 	a2, a3, IsWipe
		NOP
		B 		ItemUnselected
		NOP

	IsWipe:
		LBU		a3, @MenuPosition
		BNEZ 	a3, ItemSelected
		NOP
		B 		ItemUnselected
		NOP

	ItemSelected:
		LI 		a3, 0x3F19999A
		B 		PrintProcess
		NOP

	ItemUnselected:
		LI 		a3, 0x3f000000

	PrintProcess:
		ADDIU	sp, sp, -0x34	
		SW		t0, 0x10(sp)
		SW		t9, 0x14(sp)
		SW		a1, 0x18(sp)
		SW		a2, 0x22(sp)
		SW		a3, 0x26(sp)
		SW 		ra, @ReturnAddress
		JAL		@PrintText				// PrintText
		NOP
		LW 		ra, @ReturnAddress
		LW		t0, 0x10(sp)
		LW		t9, 0x14(sp)
		LW		a1, 0x18(sp)
		LW		a2, 0x22(sp)
		LW		a3, 0x26(sp)
		ADDIU	sp, sp, 0x34
		ADDI	a0, v0, 0x0				// update global display list
	
	PrintReadjust:
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
		LBU 	a3, @MapArrayIndex
		BEQ 	a3, t9, SetNextParams2  // If array index == Counter, set as visible
		LI 		a3, 1					// Set next array text as visible
		LI 		a3, 0 					// Set next array text as invisible
		
	CheckForWipe:
		LI 		a3, 14
		BNE 	a3, t9, CheckForROMName
		NOP
		LI 		a3, 1
		ADDIU	a2, a2, 48
		B 		SetNextParams2
		NOP

	CheckForROMName:
		LI 		a3, 15
		BNE 	a3, t9, CheckForROMVersion
		NOP
		LI 		a3, 1
		LI 		a2, 800
		B 		SetNextParams2
		NOP

	CheckForROMVersion:
		LI 		a3, 16
		BNE 	a3, t9, SetNextParams2
		LI 		a3, 0
		LI 		a3, 1
		ADDIU 	a2, a2, 48

	SetNextParams2:	
		LI 		t1, 18 					// Cap
		ADDI	t9, t9, 0x1				// t9++

	CheckLoop:
		BNE		t1, t9, PrintLoop		// if t9 != cap, loop
		NOP
		B 		PrintReturn
		NOP

	PrintReturn:
		LW 		ra, @ReturnAddress2
		JR 		ra
		NOP

.align
MenuText:
	.byte 0x0;dummy
	.asciiz "MAP - ISLES"
	.asciiz "MAP - JAPES"
	.asciiz "MAP - AZTEC"
	.asciiz "MAP - FACTORY"
	.asciiz "MAP - GALLEON"
	.asciiz "MAP - FUNGI"
	.asciiz "MAP - CAVES"
	.asciiz "MAP - CASTLE"
	.asciiz "MAP - HELM"
	.asciiz "MAP - K. ROOL DK PHASE"
	.asciiz "MAP - K. ROOL DIDDY PHASE"
	.asciiz "MAP - K. ROOL LANKY PHASE"
	.asciiz "MAP - K. ROOL TINY PHASE"
	.asciiz "MAP - K. ROOL CHUNKY PHASE"
	.asciiz "WIPE FILE"
	.asciiz "PRACTICE THROUGH VERTICAL WALLS"
	.asciiz "V0.1 BY BALLAAM"

.align
WarpMapCodes:
	.byte 0x00;dummy
	.byte 0x22 // Isles
	.byte 0x07 // Japes
	.byte 0x26 // Aztec
	.byte 0x1A // Factory
	.byte 0x1E // Galleon
	.byte 0x30 // Fungi
	.byte 0x48 // Caves
	.byte 0x57 // Castle
	.byte 0x11 // Helm
	.byte 0xCB // DK Phase
	.byte 0xCC // Diddy Phase
	.byte 0xCD // Lanky Phase
	.byte 0xCE // Tiny Phase
	.byte 0xCF // Chunky Phase

.align
KongColours:
	.byte 0x00;dummy
	.byte 0x02 // DK - Green Body
	.byte 0x02 // Diddy - Yellow Cap
	.byte 0x01 // Lanky - Green Straps
	.byte 0x03 // Tiny - Red Suit
	.byte 0x03 // Chunky - Purple Suit

.align
OperationMenu:
	.byte 0x0;dummy
	.asciiz "MAP - ISLES"