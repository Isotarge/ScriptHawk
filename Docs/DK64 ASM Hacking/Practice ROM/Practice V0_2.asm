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
// [DONE] Load / save flags
	// loading warps you to last entrance save was from

// Bugs
// [FIXED] Non-DK Kongs don't have moves
// Warping causes some oddities. Add storing the following:
	// Stored Position
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
[TBVoidByte]: 0x807FBB63
[CurrentMap]: 0x8076A0A8
[DestExit]: 0x807444E8

// Buttons
[L_Button]: 0x0020
[D_Up]: 0x0800
[D_Down]: 0x0400
[D_Left]: 0x0200
[D_Right]: 0x0100
[B_Button]: 0x4000
[A_Button]: 0x8000
[Z_Button]: 0x2000
[R_Button]: 0x0010

// MIPS ASM
[ReturnAddress]: 0x807FFFE0
[ReturnAddress2]: 0x807FFFE4
[ReturnAddress3]: 0x807FFFE8 // Compact Functions

// OSD
[WriteTextZone]: 0x807FCAA0
[ControllerInput]: 0x80014DC4
[NewlyPressedControllerInput]: 0x807ECD66
[WarpY]: 69
[WipeY]: 117
[PauseMenuTextPointer]: 0x807FC7E0
[PauseMenuPointer]: 0x807FC640
[MinCooldown]: 2
[MaxCooldown]: 6

// Tag Anywhere
[Player]: 0x807FBB4C
[SwapObject]: 0x807FC924
[Character]: 0x8074E77C

// FUNCTIONS
[SetFlag]: 0x8073129C
[CheckFlag]: 0x8073110C
[PrintText]: 0x806ABB98
[PlaySFX]: 0x80609140 // a0 = Sound Effect, a1 = 0x7FFF, a2 = 427C0000, a3 = 0x3f800000, sp+0x10 = 0, sp + 0x14 = 0
[InitiateTransition]: 0x805FF378
[GetFlagBlockAddress]: 0x8060E25C
[IsAddressActor]: 0x8067AF44 // a0 = InputAddress, v0 = Output Bool

// Sound Effects
[Banana]: 0x2A0
[Okay]: 0x23C
[UhOh]: 0x150
[Bell]: 0x1F
[KLumsy]: 0x31C

// INTERNAL
[MenuOpen]: 0x807FFFFF // u8
[MapArrayIndex]: 0x807FFFFE // u8
[HasSavedPosition]: 0x807FFFFD // u8
[InManualWarp]: 0x807FFFFC // u8
[MenuPosition]: 0x807FFFFB // u8
[MenuActionCooldown]: 0x807FFFFA // u8 - Prevents crashes
[MenuMaxCooldown]: 0x807FFFF9 // u8
[HasASavestate]: 0x807FFFF8 // u8 - Bool
[MenuSavestateAction]: 0x807FFFF6 // u8 - 0 = Save, 1 = Load
[StickWasNonNeutral]: 0x807FFFF5 // u8 - Bool
[PauseMenuScreen]: 0x807FFFF4 // u8
[StoredMainMenuTextPointer]: 0x807FFFF0 // u32 pointer

// OSD Arrays
[SavestateText]: 0x807FFF00 // 0x8
[NewPauseMenu]: 0x807FFF10 // 0x70
[LevelsArray]: 0x807FFF80 // 0x38

// SAVEPOSITION STORAGE
[SavedHVelocity]: 0x807FFEB0 // f32
[SavedVVelocity]: 0x807FFEB4 // f32
[SavedVAccel]: 0x807FFEB8 // f32
[SavedFloor]: 0x807FFEBC // f32
[SavedStoredPosition1]: 0x807FFEC0 // 3x s16
[SavedStoredPosition2]: 0x807FFEC6 // 3x s16
[SavedSkewAngle]: 0x807FFECC // u16 Rot Z
[SavedFacing]: 0x807FFECE // u16
[SavedPositions]: 0x807FFED0 // 3x f32
[SavedMovement]: 0x807FFEDC // u8
[SavedMovementProgress]: 0x807FFEDD // u8

// Savestates
[SavedMap]: 0x807FFC00 // u8
[SavedExit]: 0x807FFC01 // u8
[SavedCharacter]: 0x807FFC02 // u8
[SavedPermanentFlags]: 0x807FFC04 // 0x13B in size 

.org 0x805FC164 // retroben's hook but up a few functions
J Start

.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this

Start:
	// Run the code we replaced
	JAL     0x805FC2B0
	NOP
	// Load in pointer to alt menu
	LW 		a1, @StoredMainMenuTextPointer
	BNEZ 	a1, SetOtherVariables // Text pointer not loaded in
	NOP
	LI 		a1, @StoredMainMenuTextPointer
	LI 		a2, @NewPauseMenu
	SW 		a2, 0x0(a1)

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
		JAL 	UpdateLevelArray
		NOP
		JAL 	UpdateSavestateArray
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
		JAL 	WarpToMap
		NOP
		JAL 	UpdateAltMenu
		NOP
		JAL 	OpenMenu
		NOP
		JAL 	UpdateMenuPosition
		NOP
		JAL 	AlterMenuCode
		NOP
		JAL 	ToggleSelectedSavestateAction
		NOP
		JAL 	GlobalSavestateHandler
		NOP
		JAL 	Credits
		NOP

	Finish:
		J       0x805FC15C // retroben's hook but up a few functions
		NOP

UnlockMoves:
	LI 		a0, 4
	LI 		a1, @MovesBase
	WriteMoves:
		LI 		t3, 0x0303
		SH 		t3, 0x0 (a1) // Special | Slam Level | Guns | Ammo Belt
		LI 		t3, 0x0702
		SH 		t3, 0x2 (a1)
		LI 		t3, 15
		SB 		t3, 0x4 (a1) // Instrument
		BEQZ 	a0, WriteMoveFlags
		NOP
		ADDI 	a0, a0, -1 // Decrement Value for next kong
		ADDIU 	a1, a1, 0x5E // Next kong base
		B 		WriteMoves
		NOP
	
	WriteMoveFlags:
	SW 		a1, 0x807FFFEC
	// How were your trading barrels this run?
	// Dive Barrel
	SW 		ra, @ReturnAddress
	JAL 	CodedSetPermFlag
	LI      a0, 386
	// Vine Barrel
	JAL 	CodedSetPermFlag
	LI      a0, 387
	// Orange Barrel
	JAL 	CodedSetPermFlag
	LI      a0, 388
	// Barrel Barrel
	JAL 	CodedSetPermFlag
	LI      a0, 389
	// BFI Camera/Shockwave
	JAL 	CodedSetPermFlag
	LI      a0, 377
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP

// Fast File
FastFile:
	SW 		ra, @ReturnAddress
	// Waterfall CS
	JAL 	CodedSetPermFlag
	LI      a0, 378
	// Escape CS
	JAL 	CodedSetPermFlag
	LI      a0, 390
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP


// Unlock Kongs
UnlockKongs:
	SW 		ra, @ReturnAddress
	// Diddy
	JAL 	CodedSetPermFlag
	LI      a0, 6
	// Tiny
	JAL 	CodedSetPermFlag
	LI      a0, 66
	// Lanky
	JAL 	CodedSetPermFlag
	LI      a0, 70
	// Chunky
	JAL 	CodedSetPermFlag
	LI      a0, 117
	// DK
	JAL 	CodedSetPermFlag
	LI      a0, 385
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP

// Tag Anywhere
TagAnywhere:
	LBU 	a1, @TBVoidByte
	ANDI 	a1, a1, 2
	BNEZ 	a1, FinishTagAnywhere
	NOP
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
	SW 		ra, @ReturnAddress
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
		// Actual Positions
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
		// Facing Angle
		LI 		a3, @SavedFacing
		LHU		a2, 0x0 (a3)
		SH 		a2, 0xE6 (a1)
		// Skew Angle
		LI 		a3, @SavedSkewAngle
		LHU		a2, 0x0 (a3)
		SH 		a2, 0xE8 (a1)
		// Speed/Accel
		LI 		a3, @SavedHVelocity
		LW 		a2, 0x0 (a3)
		SW 		a2, 0xB8 (a1)
		LI 		a3, @SavedVVelocity
		LW 		a2, 0x0 (a3)
		SW 		a2, 0xC0 (a1)
		LI 		a3, @SavedVAccel
		LW 		a2, 0x0 (a3)
		SW 		a2, 0xC4 (a1)
		// Floor
		LI 		a3, @SavedFloor
		LW 		a2, 0x0 (a3)
		SW 		a2, 0xA4 (a1)
		B 		FinishPositionWrite
		NOP

	SavePosition:
		LW 		a1, @Player
		// Actual Positions
		LI 		a3, @SavedPositions
		LW 		a2, 0x7C (a1) // X Position
		SW 		a2, 0x0 (a3)
		LW 		a2, 0x80 (a1) // Y Position
		SW 		a2, 0x4 (a3)
		LW 		a2, 0x84 (a1) // Z Position
		SW 		a2, 0x8 (a3)
		// Facing Angle
		LI 		a3, @SavedFacing
		LHU 	a2, 0xE6 (a1)
		SH 		a2, 0x0 (a3)
		// Skew Angle
		LI 		a3, @SavedSkewAngle
		LHU 	a2, 0xE8 (a1)
		SH 		a2, 0x0 (a3)
		// Speed/Accel
		LI 		a3, @SavedHVelocity
		LW 		a2, 0xB8 (a1)
		SW 		a2, 0x0 (a3)
		LI 		a3, @SavedVVelocity
		LW 		a2, 0xC0 (a1)
		SW 		a2, 0x0 (a3)
		LI 		a3, @SavedVAccel
		LW 		a2, 0xC4 (a1)
		SW 		a2, 0x0 (a3)
		// Floor
		LI 		a3, @SavedFloor
		LW 		a2, 0xA4 (a1)
		SW 		a2, 0x0 (a3)
		// Saved Boolean
		LI 		a1, 1
		SB 		a1, @HasSavedPosition
		// Play Bell SFX
		JAL 	CodedPlaySFX
		LI 		a0, @Bell

	FinishPositionWrite:
		LW 		ra, @ReturnAddress
		JR 		ra
		NOP

ClearPositions:
	SB 		r0, @HasSavedPosition
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
	JAL 	CodedSetPermFlag
	LI      a0, 770
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
	JAL 	CodedPlaySFX
	LI 		a0, @Okay
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

// Updates Level Array for pause menu
UpdateLevelArray:
	LI 		a2, @LevelsArray
	// Isles
	LA 		a1, PauseMenu_Warp_Isles
	SW 		a1, 0x0(a2)
	// Japes
	LA 		a1, PauseMenu_Warp_Japes
	SW 		a1, 0x4(a2)
	// Aztec
	LA 		a1, PauseMenu_Warp_Aztec
	SW 		a1, 0x8(a2)
	// Factory
	LA 		a1, PauseMenu_Warp_Factory
	SW 		a1, 0xC(a2)
	// Galleon
	LA 		a1, PauseMenu_Warp_Galleon
	SW 		a1, 0x10(a2)
	// Fungi
	LA 		a1, PauseMenu_Warp_Fungi
	SW 		a1, 0x14(a2)
	// Caves
	LA 		a1, PauseMenu_Warp_Caves
	SW 		a1, 0x18(a2)
	// Castle
	LA 		a1, PauseMenu_Warp_Castle
	SW 		a1, 0x1C(a2)
	// Helm
	LA 		a1, PauseMenu_Warp_Helm
	SW 		a1, 0x20(a2)
	// DK Phase
	LA 		a1, PauseMenu_Warp_PhaseDK
	SW 		a1, 0x24(a2)
	// Diddy Phase
	LA 		a1, PauseMenu_Warp_PhaseDiddy
	SW 		a1, 0x28(a2)
	// Lanky Phase
	LA 		a1, PauseMenu_Warp_PhaseLanky
	SW 		a1, 0x2C(a2)
	// Tiny Phase
	LA 		a1, PauseMenu_Warp_PhaseTiny
	SW 		a1, 0x30(a2)
	// ChunkyPhase
	LA 		a1, PauseMenu_Warp_PhaseChunky
	SW 		a1, 0x34(a2)
	// End
	JR 		ra
	NOP

// Update Alt. Pause Menu Array
UpdateAltMenu:
	LI 		a2, @LevelsArray
	// First item is warp
	LBU 	a1, @MapArrayIndex
	SLL 	a1, a1, 2
	ADD 	a1, a2, a1
	LW 		a1, 0x0(a1)
	LI 		a2, @NewPauseMenu
	SW 		a1, 0x0(a2)
	// Blank Entries
	LI 		a1, 0x19
	LI 		a3, 8
	Blank:
		ADD 	t6, a2, a3
		LA 		t9, PauseMenuCredits
		SW 		t9, 0x0(t6)
		BEQZ 	a1, SavestateMenu
		NOP
		ADDI 	a1, a1, -1
		ADDIU 	a3, a3, 4
		B 		Blank
		NOP

	SavestateMenu:
		// Savestate
		LBU 	a1, @MenuSavestateAction
		BNEZ 	a1, SavestateMenu_Load
		LA 		a1, PauseMenu_Savestate_Save
		B  		WriteToMenu
		NOP

	SavestateMenu_Load:
		LA 		a1, PauseMenu_Savestate_Load

	WriteToMenu:
		SW 		a1, 0x4(a2) // Save
		SW 		a1, 0x10(a2) // Restart

	FinishAltMenu:
		JR 		ra
		NOP

// Update Savestate Text Array
UpdateSavestateArray:
	LI 		a2, @SavestateText
	// Save State
	LA 		a1, PauseMenu_Savestate_Save
	SW 		a1, 0x0(a2)
	// Load State
	LA 		a1, PauseMenu_Savestate_Load
	SW 		a1, 0x4(a2)
	JR 		ra
	NOP

// Detect opening of menu
OpenMenu:
	LBU 	a1, @TBVoidByte
	ANDI 	a1, a1, 2
	BEQZ 	a1, CorrectStoredPointer
	NOP
	// Pause Menu is open
	LBU 	a1, @PauseMenuScreen
	BNEZ 	a1, FinishOpenMenu
	NOP
	// Not on main screen
	LHU 	a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @D_Up
	BEQZ 	a1, FinishOpenMenu
	NOP
	// D-Up Pressed
		// Set default savestate option
		LBU 	a3, @HasASavestate
		SB 		a3, @MenuSavestateAction
		// Toggle Menu Byte
		LI 		a3, @MenuOpen
		LBU 	a1, 0x0(a3)
		LI 		a2, 1
		SUBU 	a1, a2, a1
		SB 		a1, 0x0(a3)

		// Swap Pointers
		LW 		a1, @PauseMenuTextPointer
		LW 		a2, @StoredMainMenuTextPointer
		SW 		a2, @PauseMenuTextPointer
		SW 		a1, @StoredMainMenuTextPointer
		B 		FinishOpenMenu
		NOP

	CorrectStoredPointer:
		LI 		a1, @NewPauseMenu
		SW 		a1, @StoredMainMenuTextPointer
		SB 		r0, @MenuOpen

	FinishOpenMenu:
		JR 	ra
		NOP

CodedSetPermFlag:
	// a0 is parameter for encoded flag
	SW 		ra, @ReturnAddress3
	LI      a1, 1
	JAL     @SetFlag
	LI      a2, 0
	LW 		ra, @ReturnAddress3
	JR 		ra
	NOP

CodedPlaySFX:
	// a0 is paramater for sound effect index
	SW 		ra, @ReturnAddress3
	LI 		a1, 0x7FFF
	LI 		a2, 0x427C0000
	LI 		a3, 0x3F800000
	SW 		r0, 0x10 (sp)
	JAL 	@PlaySFX
	SW 		r0, 0x14 (sp)
	LW 		ra, @ReturnAddress3
	JR 		ra
	NOP

UpdateMenuPosition:
	SW 		ra, @ReturnAddress3
	LW 		a0, @PauseMenuPointer
	JAL 	@IsAddressActor
	NOP
	BEQZ 	v0, FinishMenuPositionUpdate
	NOP
	LW 		a0, @PauseMenuPointer
	LI 		a1, 95 // Pause Menu Actor
	LW 		a2, 0x58(a0)
	BNE 	a1, a2, FinishMenuPositionUpdate
	NOP
	LBU 	a1, 0x18F(a0)
	SB 		a1, @MenuPosition
	LBU 	a1, 0x197(a0)
	SB 		a1, @PauseMenuScreen

	FinishMenuPositionUpdate:
		LW 	ra, @ReturnAddress3
		JR 	ra
		NOP

// OSD Map
ChangeSelectedMap:
	SW 		ra, @ReturnAddress
	// Update Max Cooldown
	LBU 	a1, @MenuMaxCooldown
	BNEZ  	a1, TickCooldown
	LI 		a1, @MaxCooldown
	SB 		a1, @MenuMaxCooldown

	// Tick Down Menu Cooldown
	TickCooldown:
		LBU 	a1, @MenuActionCooldown
		BEQZ 	a1, CheckMenuOpen
		ADDI 	a1, a1, -1
		SB 		a1, @MenuActionCooldown

	CheckMenuOpen:
		LBU 	a1, @MenuOpen
		BEQZ 	a1, FinishChange // Menu not open
		NOP
		LBU 	a1, @MenuPosition
		BNEZ 	a1, FinishChange // Menu not in position 0
		NOP
		LBU 	a2, @MenuActionCooldown
		BNEZ 	a2, FinishChange // Cooldown isn't at 0
		NOP
		LI 		a2, @ControllerInput
		LB 		a1, 0x2(a2) // Controller Stick X
		ADDIU 	a1, a1, 40
		BGTZ 	a1, CheckMenuRight
		NOP
		LBU 	a1, @MapArrayIndex
		BEQZ 	a1, LoopToEnd // If array index == 0, loop to end
		NOP
		ADDI 	a1, a1, -1
		B 		SetChange
		NOP

	CheckMenuRight:
		LB 		a1, 0x2(a2)
		ADDI 	a1, a1, -40
		BLEZ 	a1, NeutralStick
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

	NeutralStick: 
		LI 		a1, @MaxCooldown
		SB 		a1, @MenuMaxCooldown
		B 		FinishChange
		NOP

	SetChange:
		SB 		a1, @MapArrayIndex
		// Play Banana SFX
		JAL 	CodedPlaySFX
		LI 		a0, @Banana
		// Decrement Max Cooldown
		LBU 	a1, @MenuMaxCooldown
		ADDI 	a1, a1, -1
		SLTIU 	a2, a1, @MinCooldown
		BNEZ  	a2, FinishChange
		SB 		a1, @MenuActionCooldown
		SB 		a1, @MenuMaxCooldown

	FinishChange:
		LW 		ra, @ReturnAddress 
		JR 		ra
		NOP

// Alter pause menu code
AlterMenuCode:
	LBU 	a0, @MenuOpen
	BEQZ 	a0, NormalCode
	NOP

	PatchedCode:
		// Z
		SH 	r0, 0x806A8662
		// R
		SH 	r0, 0x806A862A
		// A
		SH 	r0, 0x806A871E
		SH 	r0, 0x806A87FA
		B 	FinishAlteringMenuCode
		NOP
	NormalCode:
		// Z
		LI 	a0, @Z_Button
		SH 	a0, 0x806A8662
		// R
		LI 	a0, @R_Button
		SH 	a0, 0x806A862A
		// A
		LI 	a0, @A_Button
		SH 	a0, 0x806A871E
		SH 	a0, 0x806A87FA

	FinishAlteringMenuCode:
		JR 	ra
		NOP

// OSD Savestate
ToggleSelectedSavestateAction:
	SW 		ra, @ReturnAddress

	CheckMenuOpen_ss:
		LBU 	a1, @MenuOpen
		BEQZ 	a1, FinishChange_ss // Menu not open
		NOP
		LBU 	a1, @MenuPosition
		LI 		a2, 1
		BNE		a1, a2, FinishChange_ss // Menu not in position 1
		NOP
		LBU 	a1, @HasASavestate
		BEQZ 	a1, FinishChange_ss
		NOP
		LI 		a2, @ControllerInput
		LB 		a1, 0x2(a2) // Controller Stick X
		ADDIU 	a1, a1, 40
		BGTZ 	a1, CheckMenuRight_ss
		NOP
		B 		CheckStickBool_ss
		NOP

	CheckMenuRight_ss:
		LB 		a1, 0x2(a2)
		ADDI 	a1, a1, -40
		BLEZ 	a1, NeutralStick_ss
		NOP
		BNE 	a1, a2, CheckStickBool_ss
		NOP

	NeutralStick_ss: 
		SB 		r0, @StickWasNonNeutral
		B 		FinishChange
		NOP

	CheckStickBool_ss:
		LBU 	a2, @StickWasNonNeutral
		BNEZ 	a2, FinishChange_ss // Stick Not at new non-neutral
		NOP

	SetChange_ss:
		LI 		a2, 1
		SB 		a2, @StickWasNonNeutral
		LBU 	a1, @MenuSavestateAction
		SUBU 	a1, a2, a1
		SB 		a1, @MenuSavestateAction
		// Play Banana SFX
		JAL 	CodedPlaySFX
		LI 		a0, @Banana
		
	FinishChange_ss:
		LW 		ra, @ReturnAddress 
		JR 		ra
		NOP

// Savestate Handler
GlobalSavestateHandler:
	SW 		ra, @ReturnAddress
	LBU 	a1, @MenuOpen
	BEQZ 	a1, FinishStateHandler // Menu not open
	NOP
	LBU 	a1, @MenuPosition
	LI 		a2, 1
	BNE 	a1, a2, FinishStateHandler // Menu not in position 1
	NOP
	LH 		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @A_Button
	BEQZ 	a1, FinishStateHandler // A not pressed
	NOP
	LBU 	a1, @MenuSavestateAction
	BNEZ 	a1, Handler_Load
	NOP

	Handler_Save:
		LI 		a0, 1
		SB 		a0, @HasASavestate
		JAL 	@GetFlagBlockAddress
		ADDIU 	a0, r0, 0 // Flag Type 0 (Permanent)
		LI 		a0, 0x13C
		LI 		a1, @SavedPermanentFlags
		ADDIU 	a3, v0, 0 // Copy v0
		SW 		a3, 0x807FFFEC

		ReadFlags:
			LW 		a2, 0x0(a3)
			SW 		a2, 0x0(a1)
			BEQZ 	a0, SaveMap
			NOP
			ADDI 	a0, a0, -4
			ADDIU 	a3, a3, 4
			ADDIU 	a1, a1, 4
			B 		ReadFlags
			NOP

		SaveMap:
			// Play "Okay" SFX
			JAL 	CodedPlaySFX
			LI 		a0, @Okay
			LW 		a1, @CurrentMap
			SB 		a1, @SavedMap
			LW 		a1, @DestExit
			SB 		a1, @SavedExit
			LBU		a1, @Character
			SB 		a1, @SavedCharacter
			B 		FinishStateHandler
			NOP

	Handler_Load:
		JAL 	@GetFlagBlockAddress
		ADDIU	a0, r0, 0 // Flag Type 0 (Permanent)
		LI 		a0, 0x13C
		LI 		a1, @SavedPermanentFlags
		ADDIU 	a3, v0, 0 // Copy v0

		WriteFlags:
			LW 		a2, 0x0(a1)
			SW 		a2, 0x0(a3)
			BEQZ 	a0, ConfirmFlags
			NOP
			ADDI 	a0, a0, -4
			ADDIU 	a3, a3, 4
			ADDIU 	a1, a1, 4
			B 		WriteFlags
			NOP

		ConfirmFlags:
			LI 		a0, 0
			LI 		t0, 0x9E0

			ConfirmFlagProcess:
				JAL 	@CheckFlag
				LI 		a1, 2
				ADDIU 	a1, v0, 0 // Copy output of check flag to a1
				JAL 	@SetFlag
				LI 		a2, 0
				BEQZ 	t0, LoadWarp
				NOP
				ADDIU 	a0, a0, 1
				ADDI 	t0, t0, -1
				B 		ConfirmFlagProcess
				NOP

		LoadWarp:
			LBU 	a0, @SavedCharacter
			SB 		a0, @Character
			LBU 	a0, @SavedMap // Destination Map
			SB 		r0, @CutsceneWillPlay // Prevents Meme bugs/crashes
			LBU 	a1, @SavedExit // Destination Exit
			JAL 	@InitiateTransition
			NOP

	FinishStateHandler:
		LW 	ra, @ReturnAddress
		JR 	ra
		NOP

// Credits line - Not sure what to do with this.
// Tried toggling TB Void - Pause menu makes this kinda iffy to do
Credits:
	SW 		ra, @ReturnAddress
	LBU 	a1, @MenuOpen
	BEQZ 	a1, FinishTBVoidToggle // Menu not open
	NOP
	LBU 	a1, @MenuPosition
	LI 		a2, 2
	BNE 	a1, a2, FinishTBVoidToggle // Menu not in position 2
	NOP
	LH 		a1, @NewlyPressedControllerInput
	ANDI 	a1, a1, @A_Button
	BEQZ 	a1, FinishTBVoidToggle // A not pressed
	NOP
	// Play K.Lumsy Takeoff wave SFX
	JAL 	CodedPlaySFX
	LI 		a0, @KLumsy

	FinishTBVoidToggle:
		LW 	ra, @ReturnAddress
		JR 	ra
		NOP

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
	.byte 0x02 // Tiny - Purple Suit
	.byte 0x01 // Chunky - Red Suit

.align
PauseMenu_Warp_Isles:
	.asciiz "GO TO ISLES"

.align
PauseMenu_Warp_Japes:
	.asciiz "GO TO JAPES"

.align
PauseMenu_Warp_Aztec:
	.asciiz "GO TO AZTEC"

.align
PauseMenu_Warp_Factory:
	.asciiz "GO TO FACTORY"

.align
PauseMenu_Warp_Galleon:
	.asciiz "GO TO GALLEON"

.align
PauseMenu_Warp_Fungi:
	.asciiz "GO TO FUNGI"

.align
PauseMenu_Warp_Caves:
	.asciiz "GO TO CAVES"

.align
PauseMenu_Warp_Castle:
	.asciiz "GO TO CASTLE"

.align
PauseMenu_Warp_Helm:
	.asciiz "GO TO HELM"

.align
PauseMenu_Warp_PhaseDK:
	.asciiz "GO TO DK PHASE"

.align
PauseMenu_Warp_PhaseDiddy:
	.asciiz "GO TO DIDDY PHASE"

.align
PauseMenu_Warp_PhaseLanky:
	.asciiz "GO TO LANKY PHASE"

.align
PauseMenu_Warp_PhaseTiny:
	.asciiz "GO TO TINY PHASE"

.align
PauseMenu_Warp_PhaseChunky:
	.asciiz "GO TO CHUNKY PHASE"

.align
PauseMenu_Savestate_Save:
	.asciiz "SAVE STATE"

.align
PauseMenu_Savestate_Load:
	.asciiz "LOAD STATE"

PauseMenuCredits:
	.asciiz "V0.2 BY BALLAAM"

.align
PauseMenu_Null:
	.byte 0x0