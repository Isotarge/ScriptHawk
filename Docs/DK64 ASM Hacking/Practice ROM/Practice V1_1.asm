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

// BUGS & AIMS FOR V1.1
// (Just because something is listed here doesn't mean it'll make it in for 1.1. Solution may be too tough)

// [Aim] Integrate Position storage with save state
	// Maybe try and sneak in the bonus barrel code, see whether we can get a position warp that way
// [Bug] Loading stored positions on an object causes problems
	// Maybe this is as simple as turning off the grounded bit in the player object when warping, which will correct itself when you warp?
// [Aim] D-Pad controls for pause menu
	// If this *can* be done within reason, shift activation of alt menu to L
// [Aim] Store more variables within savestate storage
	// Inventory Counts
// [Bug] Load position in autowalk softlocks the game
	// I feel like there has to be a bit inside the kong object which controls whether the kong is autowalking
		// And also handling where they're autowalking to. Might be useful for savestate integration

[InCutscene]: 0x807444EC
[TransitionSpeed]: 0x807FD88C
[CutsceneWillPlay]: 0x8075533B
[MysteryWriteOffset]: 0x29C
[CurrentCharacter]: 0x36F
[KRoolRound]: 0x80750AD4
[MovesBase]:  0x807FC950 // End: 0x807FCB28
[MovesBaseSize]: 0x1D8
[PlayerOneColour]: 0x807552F4
[Mode]: 0x80755318
[TBVoidByte]: 0x807FBB63
[CurrentMap]: 0x8076A0A8
[DestExit]: 0x807444E8
[StorySkip]: 0x8074452C
[HelmTimerOn]: 0x80755350
[TempFlagBlock]: 0x807FDD90
[InSubmap]: 0x8076A170
[ParentMap]: 0x8076A172
[ParentExit]: 0x8076A174

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
[Wrong]: 0x98

// COLLECTABLES
[Ammo]: 0x807FCC40 // u16
[Oranges]: 0x807FCC44 // u16
[Crystals]: 0x807FCC46 // u16
[Film]: 0x807FCC48 // u16
[Health]: 0x807FCC4B // u8
[Melons]: 0x807FCC4C // u8

// INTERNAL
[MenuOpen]: 0x807FFFFF // u8
[MapArrayIndex]: 0x807FFFFE // u8
[SavedPositionMap]: 0x807FFFFD // u8
[InManualWarp]: 0x807FFFFC // u8
[MenuPosition]: 0x807FFFFB // u8
[MenuActionCooldown]: 0x807FFFFA // u8 - Prevents crashes
[MenuMaxCooldown]: 0x807FFFF9 // u8
[HasASavestate]: 0x807FFFF8 // u8 - Bool
[InBadMap]: 0x807FFFF7 // u8 - Bool
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
[SavedKongBase]: 0x807FFA00 // 0x1D8 in size
[SavedMap]: 0x807FFC00 // u8
[SavedExit]: 0x807FFC01 // u8
[SavedCharacter]: 0x807FFC02 // u8
[SavedParentMap]: 0x807FFC03 // u8
[SavedParentExit]: 0x807FFC04 // u8
[SavedInSubmap]: 0x807FFC05 // u8
[SavedPermanentFlags]: 0x807FFC08 // 0x13B in size 

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
		SB 		t3, @StorySkip
		// Turn off BoM Timer
		SB 		r0, @HelmTimerOn
		// Unlock Mystery Menu
		LI      t6, 0x807ED558
		LI      t0, 0xFFFFFFFF
		SW      t0, 0(t6)
		SW      t0, 4(t6)
		// Set K Rool to round 11 (Cause the sound effect is the best one)
		LI 		t6, 11
		SB 		t6, @KRoolRound
		LBU 	t0, @InCutscene
		LI 		t6, 6
		BEQ 	t0, t6, TransitionFunctions
		NOP
		LBU 	t0, @InManualWarp
		BNEZ 	t0, TransitionFunctions
		NOP
		LW 		t0, @TransitionSpeed
		LUI 	t6, 0x3F80 // f32 = 1
		BNE 	t0, t6, EveryFrameFunctions
		NOP

	TransitionFunctions:
		JAL 	CheckManualWarpClear
		NOP
		JAL 	FileInit
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
		JAL 	CheckMapType
		NOP
		JAL 	Credits
		NOP

	Finish:
		J       0x805FC15C // retroben's hook but up a few functions
		NOP

FileInit:
	LI 		a0, 4
	LI 		a1, @MovesBase
	WriteMoves:
		LI 		t3, 0x0303
		SH 		t3, 0x0 (a1) // Special | Slam Level | Guns | Ammo Belt
		LI 		t3, 0x0702
		SH 		t3, 0x2 (a1)
		LI 		t3, 15
		SB 		t3, 0x4 (a1) // Instrument
		LI 		t3, 10
		SH 		t3, 0x8 (a1) // Instrument Ammo
		BEQZ 	a0, WriteMoveFlags
		NOP
		ADDI 	a0, a0, -1 // Decrement Value for next kong
		ADDIU 	a1, a1, 0x5E // Next kong base
		B 		WriteMoves
		NOP
	
	WriteMoveFlags:
	SW 		ra, @ReturnAddress
	// How were your trading barrels this run?
	// Dive Barrel
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
	// Waterfall CS
	JAL 	CodedSetPermFlag
	LI      a0, 378
	// Escape CS
	JAL 	CodedSetPermFlag
	LI      a0, 390
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
	// Standard Ammo
	LI 		a1, 200
	SH 		a1, @Ammo
	// Oranges
	LI 		a1, 20
	SH 		a1, @Oranges
	// Crystals
	LI 		a1, 3000 // Each crystal is 150, so this is 20 Crystals
	SH 		a1, @Crystals
	// Film
	LI 		a1, 20
	SH 		a1, @Film
	// Melons
	LI 		a1, 3
	SB 		a1, @Melons
	// Health
	LI 		a1, 12
	SB 		a1, @Health
	LW 		ra, @ReturnAddress
	JR 		ra
	NOP

// Tag Anywhere
TagAnywhere:
	LBU 	a1, @TBVoidByte
	ANDI 	a1, a1, 2
	BNEZ 	a1, FinishTagAnywhere // Pause Menu
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
		ADDIU	a2, a2, 2
		SB 		a2, 0x36F (a1)
		LW 		a1, @SwapObject
		BEQZ 	a1, FinishTagAnywhere // If swap object isn't in RDRAM, cancel
		LI 		a2, 0x3B
		SH 		a2, 0x29C (a1) // Initiate Swap

	FinishTagAnywhere:
		JR 		ra
		NOP

// Position Savestate
PositionSavestates:
	SW 		ra, @ReturnAddress

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
		LBU 	a1, @SavedPositionMap
		LW 		a3, @CurrentMap
		BNE 	a1, a3, FinishPositionWrite // If not equal to the last stored map, prevent write
		NOP
		LW 		a1, @Player
		// Actual Positions
		LI 		a3, @SavedPositions
		LW 		a2, 0x0 (a3) // X
		SW 		a2, 0x7C (a1)
		LW 		a2, 0x4 (a3) // Y
		SW 		a2, 0x80 (a1)
		LW 		a2, 0x8 (a3) // Z
		SW 		a2, 0x84 (a1)
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
		LW 		a1, @CurrentMap
		SB 		a1, @SavedPositionMap
		// Play Bell SFX
		JAL 	CodedPlaySFX
		LI 		a0, @Bell

	FinishPositionWrite:
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

	// Clear some K Rool stuff to prevent Bugs
	// Binary Strings
	// Setting
	// 0xB: 0010 0001 -|-|DK Phase Intro|-|-|-|-|Tiny Phase Intro
	// CLEARING
	// 0xA: 0001 1110 -|-|-|Toe 4|Toe 3|Toe 2|Toe 1|-
	// 0xB: 1000 0000 Gorilla Gone CS|-|-|-|-|-|-|-
	LI 		a0, @TempFlagBlock
	LH 		a1, 0xA(a0)
	ORI 	a1, a1, 0x0021
	ANDI 	a1, a1, 0xE17F
	SH 		a1, 0xA(a0)
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
	SLTI 	a3, a0, 0xD0
	BEQZ 	a3, FinishWarp // Not warping to K Rool
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
	LUI 	a0, 0x8069	
	SB 		r0, 0xA62F(a0) // 0x8068A62F // Enable colouring for 1-player gameplay
	SW 		r0, 0xA450(a0) // 0x8068A450 // Turn off low poly models
	SW 		r0, 0xA458(a0) // 0x8068A458 // Turn off low poly models
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
	LA 		a1, PauseMenu_Warp_List
	LA 		t0, PauseMenu_Warp_Length
	LI 		t9, 14

	LevelArrayProcess:
		SW 		a1, 0x0 (a2)
		BEQZ 	t9, FinishGeneratingLevelArray
		LBU 	a0, 0x0 (t0)
		ADD 	a1, a1, a0
		ADDIU 	a2, a2, 4
		ADDIU 	t0, t0, 1
		B 		LevelArrayProcess
		ADDI 	t9, t9, -1

	FinishGeneratingLevelArray:
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
		ADDIU 	a3, a3, 4
		B 		Blank
		ADDI 	a1, a1, -1

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
	ANDI 	a3, a1, 0xA010 // AZR not pressed
	BNEZ 	a3, FinishOpenMenu
	NOP
	// A not pressed
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
	LBU 	a1, 0x18F(a0)
	SB 		a1, @MenuPosition
	LBU 	a1, 0x197(a0)
	SB 		a1, @PauseMenuScreen

	FinishMenuPositionUpdate:
		LW 		ra, @ReturnAddress3
		JR 		ra
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
	LUI		a1, 0x806B

	PatchedCode:
		// Z
		SH 	r0, 0x8662(a1) //0x806A8662
		// R
		SH 	r0, 0x862A(a1) //0x806A862A
		// A
		SH 	r0, 0x871E(a1) //0x806A871E
		SH 	r0, 0x87FA(a1) //0x806A87FA
		B 	FinishAlteringMenuCode
		NOP
	NormalCode:
		// Z
		LI 	a0, @Z_Button
		SH 	a0, 0x8662(a1) //0x806A8662
		// R
		LI 	a0, @R_Button
		SH 	a0, 0x862A(a1) //0x806A862A
		// A
		LI 	a0, @A_Button
		SH 	a0, 0x871E(a1) //0x806A871E
		SH 	a0, 0x87FA(a1) //0x806A87FA

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
	JAL 	@GetFlagBlockAddress
	ADDIU 	a0, r0, 0 // Flag Type 0 (Permanent)
	LI 		a0, 0x13C
	LBU 	a1, @MenuSavestateAction
	BNEZ 	a1, Handler_Load
	ADDIU 	a3, v0, 0 // Copy v0
	LBU		a1, @InBadMap
	BEQZ 	a1, Handler_Save
	NOP
	JAL 	CodedPlaySFX
	LI 		a0, @Wrong
	B 		FinishStateHandler
	NOP

	Handler_Save:
		LI 		a1, 1
		SB 		a1, @HasASavestate
		LI 		a1, @SavedPermanentFlags

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
			LI 		a0, @MovesBase
			LI 		a1, @MovesBaseSize
			LI 		a2, @SavedKongBase
		
			SaveKongBase:
				// Store Kong Base
				LW 		a3, 0x0(a0)
				SW 		a3, 0x0(a2)
				BEQZ 	a1, SaveMapVars
				NOP
				ADDIU 	a0, a0, 4
				ADDIU  	a2, a2, 4
				ADDI 	a1, a1, -4
				B 		SaveKongBase
				NOP

		SaveMapVars:
			// Store Map & Kong variables
			LBU 	a1, @InSubmap
			SB 		a1, @SavedInSubmap
			LH		a1, @ParentMap
			SB 		a1, @SavedParentMap
			LBU		a1, @ParentExit
			SB 		a1, @SavedParentExit
			LW 		a1, @CurrentMap
			SB 		a1, @SavedMap
			LW 		a1, @DestExit
			SB 		a1, @SavedExit
			LBU		a1, @Character
			SB 		a1, @SavedCharacter
			B 		FinishStateHandler
			NOP

	Handler_Load:
		LI 		a1, @SavedPermanentFlags

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
			LI 		a0, @MovesBase
			LI 		a1, @MovesBaseSize
			LI 		a2, @SavedKongBase
		
			LoadKongBase:
				// Load Kong Base
				LW 		a3, 0x0(a2)
				SW 		a3, 0x0(a0)
				BEQZ 	a1, LoadMapVars
				NOP
				ADDIU 	a0, a0, 4
				ADDIU  	a2, a2, 4
				ADDI 	a1, a1, -4
				B 		LoadKongBase
				NOP

		LoadMapVars:
			// Load Map & Kong Variables
			LBU		a0, @SavedInSubmap
			SB 		a0, @InSubmap
			LBU 	a0, @SavedParentMap
			SH		a0, @ParentMap
			LBU 	a0, @SavedParentExit
			SB		a0, @ParentExit
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

// Check if in Bad Map
CheckMapType:
	LW 		a0, @CurrentMap
	LA 		a1, BadSavestateMaps

	TypeCheckLoop:
		LBU 	a2, 0x0(a1)
		BEQ 	a0, a2, MapTypeInvalid
		NOP
		BNEZ 	a2, TypeCheckLoop
		ADDIU 	a1, a1, 1
		SLTI 	a2, a0, 0x73
		BNEZ 	a2, MapTypeValid
		SLTI 	a3, a0, 0x97
		BEQZ 	a3, MapTypeValid
		NOP

	MapTypeInvalid:
		LI 		a0, 1
		SB 		a0, @InBadMap
		B 		FinishMapCheck
		NOP

	MapTypeValid:
		SB 		r0, @InBadMap

	FinishMapCheck:
		JR 		ra
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
PauseMenu_Warp_List:
	.asciiz "GO TO ISLES"
	.asciiz "GO TO JAPES"
	.asciiz "GO TO AZTEC"
	.asciiz "GO TO FACTORY"
	.asciiz "GO TO GALLEON"
	.asciiz "GO TO FUNGI"
	.asciiz "GO TO CAVES"
	.asciiz "GO TO CASTLE"
	.asciiz "GO TO HELM"
	.asciiz "GO TO DK PHASE"
	.asciiz "GO TO DIDDY PHASE"
	.asciiz "GO TO LANKY PHASE"
	.asciiz "GO TO TINY PHASE"
	.asciiz "GO TO CHUNKY PHASE"

.align
PauseMenu_Warp_Length:
	.byte 12 //11
	.byte 12 //11
	.byte 12 //11
	.byte 14 //13
	.byte 14 //13
	.byte 12 //11
	.byte 12 //11
	.byte 13 //12
	.byte 11 //10
	.byte 15 //14
	.byte 18 //17
	.byte 18 //17
	.byte 17 //16
	//.byte 19 //18 - Chunky phase, not needed

.align
BadSavestateMaps:
	.byte 0x01 // Funky's
	.byte 0x03 // Lanky's Maze
	.byte 0x05 // Cranky's Lab
	.byte 0x08 // Japes: Dillo
	.byte 0x0A // KKosh (V Easy)
	.byte 0x0F // Snide's
	.byte 0x12 // TTTrouble (V Easy)
	.byte 0x19 // Candy's
	.byte 0x20 // BBBandit (Easy)
	.byte 0x23 // DK Target Minigame
	.byte 0x2A // Troff n Scoff
	.byte 0x32 // Tiny Mush Bounce Minigame
	.byte 0x35 // Crown - Beaver Bother
	.byte 0x41 // SSnoop (Normal)
	.byte 0x42 // MMMaul (Hard)
	.byte 0x43 // SSnatch (Hard)
	.byte 0x44 // MMMaul (Easy)
	.byte 0x45 // MMMaul (Normal)
	.byte 0x49 // Crown - Kritter Karnage
	.byte 0x4A // SSnatch (Easy)
	.byte 0x4B // SSnatch (Hard)
	.byte 0x4D // MMayhem (Easy)
	.byte 0x4E // BBBarrage (Easy)
	.byte 0x4F // BBBarrage (Normal)
	.byte 0x53 // Fungi: Dogadon
	.byte 0x60 // SSSalvage (Normal)
	.byte 0x63 // SSSortie (Easy)
	.byte 0x65 // Krazy KK (Easy)
	.byte 0x66 // BBBash (V Easy)
	.byte 0x67 // SSeek (V Easy)
	.byte 0x68 // BBother (Easy)
	.byte 0x6F // Galleon: Pufftoss
	// All values between 0x73 and 0x96 (Inclusive). Various bonus minigames
	.byte 0x9A // Factory: Jack
	.byte 0x9B // Crown - Arena Ambush
	.byte 0x9C // Crown - More Kritter Karnage
	.byte 0x9D // Crown - Forest Fracas
	.byte 0x9E // Crown - Bish Bash Brawl
	.byte 0x9F // Crown - Kamikaze Kremlings
	.byte 0xA0 // Crown - Plinth Panic
	.byte 0xA1 // Crown - Pinnacle Palaver
	.byte 0xA2 // Crown - Shockwave Showdown
	.byte 0xA5 // Diddy Kremling Game
	.byte 0xC4 // Caves: Dillo
	.byte 0xC5 // Aztec: Dogadon
	.byte 0xC7 // Castle: Kut Out
	.byte 0xC9 // Diddy Rocketbarrel Game
	.byte 0xCA // Lanky Shooting Game
	.byte 0xD1 // Chunky ? Box Game
	.byte 0xD2 // Tiny "Floor is Lava" Game
	.byte 0xD3 // Chunky Shooting Game
	.byte 0xD4 // DK Rambi Game
	.byte 0x0 // Terminator

.align
PauseMenu_Savestate_Save:
	.asciiz "SAVE STATE"

.align
PauseMenu_Savestate_Load:
	.asciiz "LOAD STATE"

PauseMenuCredits:
	.asciiz "V1.1 BY BALLAAM"