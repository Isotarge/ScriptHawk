// Donkey Kong 64 - Tag Anywhere (V5) (U)
// Made with love by Isotarge

// With help from:
// Tom Ballaam
// 2dos
// Mittenz
// retroben
// Kaze Emanuar
// SubDrag
// runehero123
// Skill
// TJ Blakely

// See https://www.romhacking.net/hacks/4961/ for more info & download
// See https://pastebin.com/m82XBvYm for more info & download

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
// TODO: This might be slightly outdated now with version 5
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

// Tag Anywhere V5

// - Two modes, toggled by story skip

// Story Skip Off:
// DONE - Only DK unlocked from start, but can tag once others unlocked

// Story Skip On:
// STORY SKIP text starts at 0x804AD7F0, could overwrite it with SPEED MODE where map == 80 (main menu)
// DONE - All Kongs Unlocked from beginning
// DONE - GB Dances Skipped
// DONE - All FTT Skipped from beginning
// DONE - All moves, guns, camera, tbarrels completed from beginning
// DONE - Spawn in DK Isle

// Stretch goals (if there's enough space in ROM)
// - K. Lumsy cutscenes compressed
// DONE - Snide's cutscenes compressed
// - Fix origin warp when tagging just before grabbing a tree
// - Add L to tag next kong for TJ as per V1
// - Set Arcade high scores to max to skip high score entry during 101 run

[NewlyPressedControllerInput]: 0x807ECD66
[ControllerInput]: 0x80014DC4
[HUDPointer]: 0x80754280
[KongObjectPointer]: 0x807FBB4C
[MysteryObjectPointer]: 0x807FC924
[InCutscene]: 0x807444EC
[CutsceneIndex]: 0x807476F4 // u16
[CutsceneTimer]: 0x807476F0 // u16
[ParentMap]: 0x8076A172 // u16
[PreviousMap]: 0x8076AEF3
[CurrentMap]: 0x8076A0A8
[CurrentExit]: 0x8076A0AC
[NextMap]: 0x807444E4
[NextExit]: 0x807444E8
[StorySkip]: 0x8074452C
[LZFadeoutProgress]: 0x807FD888
[ActorSpawnerArrayPointer]: 0x807FDC8C

[Actor_HandState]: 0x147
[Actor_GunState]: 0x20C
[Actor_MovementState]: 0x154
[Actor_CurrentCharacter]: 0x36F
[Actor_EffectBitfield]: 0x372

[MysteryWriteOffset]: 0x29C

[setFlag]: 0x8073129C // a0 is flag index, a1 is 0 or 1 (0 to clear, 1 to set), a2 is block type (0 permanent, 1 global?, 2 temporary)
[checkFlag]: 0x8073110C // a0 is flag index, a1 is block type (0 permanent, 1 global?, 2 temporary)

[L_Button]: 0x0020
[D_Down]: 0x0400
[D_Left]: 0x0200
[D_Right]: 0x0100

.org 0x805FC164 // retroben's hook but up a few functions
J Start

.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this
Start:
// Run the code we replaced
JAL     0x805FC2B0
NOP

// Check whether story skip is on
// If not, skip over the extra unlocks granted by speedrun mode
LB t0, @StorySkip
BEQZ t0, ++
NOP

lw t0, @CurrentMap
li t1, 15 // Snide's H.Q.
bne t1, t0, +
nop

SnidesCutsceneCompression:
// The cutscene the game chooses is based on the parent map (the method used to detect which Snide's H.Q. you're in)
// The shortest contraption cutscene is chosen with parent map 0
// So we swap out the original parent map with 0 at the right moment to get short cutscenes
// Then swap the original value back in at the right moment so that the player isn't taken back to test map when exiting Snide's H.Q.

lhu t0, @CutsceneIndex
li t1, 5
beq t0, t1, Cutscene5Playing
NOP
li t1, 2
beq t0, t1, Cutscene2Playing
NOP
B SnidesTurnInCompression

Cutscene5Playing:
    lhu t0, @CutsceneTimer
    li t1, 199
    BEQ t0, t1, CutsceneTimerIs199
    nop
    li t1, 200
    BEQ t0, t1, CutsceneTimerIs200
    nop
    B SnidesTurnInCompression

    CutsceneTimerIs199:
        // Make a backup copy of the current parent map to restore later
        LHU t2, @ParentMap
        SH  t2, BackupParentMap
        B SnidesTurnInCompression
        NOP

    CutsceneTimerIs200:
        // Set parent map to 0
        SH r0, @ParentMap
        B SnidesTurnInCompression
        NOP

Cutscene2Playing:
    // Restore the backup copy of the parent map
    LH  t2, BackupParentMap
    SH  t2, @ParentMap

SnidesTurnInCompression:
// Dereference the spawner array
lw t0, @ActorSpawnerArrayPointer
BEQZ t0, + // If there's no array loaded, don't bother
NOP

// Find a snide entry (enemy type 7)
lb t1, 0(t0) // Get enemy type at slot 0
li t2, 7 // Snide enemy type 
BNE t1, t2, + // if enemy != snide, don't bother
NOP

// Dereference the Snide Actor pointer from it
lw t0, 0x18(t0)
BEQZ t0, + // If there's no actor loaded as Snide, don't bother
NOP

// Read the turn count (Snide + 0x232)
lb t1, 0x232(t0)

// If it's != 0, overwrite it with 1
beqz t1, +
nop
li t2, 1
sb t2, 0x232(t0)

+:
lw t0, @CurrentMap
li t1, 80 // Main Menu
bne t0, t1, +
nop
lw t0, @NextMap
li t1, 176 // Training Grounds
bne t0, t1, +
nop

li t1, 34 // DK Isles Overworld
sw t1, @NextMap
sw r0, @NextExit // Exit 0

+:

// Is the game loading?
// If so, update the ExplicitDisableMap byte and then return
LW      t2, @LZFadeoutProgress
BNEZ    t2, MapIsLoading
//LW      t2, 0x8076A064 // TODO: Switch to this for CPU cycle saves during LZs when we have a hook that runs when this is 0
//BEQZ    t2, MapIsLoading
NOP

// Check if we're in a map that's explicitly been disabled
LBU     t2, ExplicitDisableMap
BNEZ    t2, Return
NOP

// Check if we're in a cutscene
LBU     t2, @InCutscene
BNEZ    t2, Return
NOP

// Check if we're Rambi/Enguarde
LBU     t2, 0x8074E77C
LI      t3, 6 // Rambi
BEQ     t2, t3, Return
NOP
LI      t3, 7 // Enguarde
BEQ     t2, t3, Return
NOP

// Check if there's any collectible counters updating
// This prevents wrong collection
LW      t2, @HUDPointer
BEQZ    t2, Return // if hud == null { return }
NOP

LW      t3, 0x20(t2) // Coloured Banana
BNEZ    t3, Return
LW      t1, 0x50(t2) // Banana Coin
BNEZ    t1, Return
LW      t3, 0x110(t2) // Crystal Coconut
BNEZ    t3, Return
LW      t1, 0x1A0(t2) // GB Count (Character) // Note: We can't add the bottom counter because it's always shown in lobbies
BNEZ    t1, Return
LW      t3, 0x200(t2) // Banana Medal
BNEZ    t3, Return
LW      t1, 0x260(t2) // Blueprint
BNEZ    t1, Return
LW      t3, 0x290(t2) // Coloured Banana?
BNEZ    t3, Return
LW      t1, 0x2C0(t2) // Banana Coin?
BNEZ    t1, Return
NOP

// Check if DPAD-Left is newly pressed
LH      t2, @NewlyPressedControllerInput
ANDI    t3, t2, @D_Left
BEQZ    t3, CheckDRight
NOP

LI      t4, -1 // New kong will be left in the tag barrel
B       UpdateKong
NOP

// Check if DPAD-Right is newly pressed
CheckDRight:
ANDI    t3, t2, @D_Right
BEQZ    t3, Return
NOP

LI      t4, 1 // New kong will be right in the tag barrel

// Update Player Actor with new character value
UpdateKong:
LW      t2, @KongObjectPointer
BEQZ    t2, Return
NOP

// Check whether we're in a movement state where tagging should be disabled
LBU     t0, @Actor_MovementState(t2)
// Load the start of the array
LA      t1, ExplicitDisableMovementStates

// Loop through and check for movementState == disabledMovementState or null terminator
MovementCheckLoop:
LBU     t3, 0(t1)
BEQ     t0, t3, Return
NOP
BNEZ    t3, MovementCheckLoop
ADDIU   t1, t1, 1

// Check if we're in Gorilla Gone
LHU     t3, @Actor_EffectBitfield(t2)
ANDI    t1, t3, 0x0040 // Gorilla Gone
BNEZ    t1, Return
NOP

// We're in a movement/effect state that allows tagging!
LBU     t3, @Actor_CurrentCharacter(t2)

// Kong += t4
-:
ADD     t3, t3, t4

// If Kong == 1 { Kong = 6 }
LI      t6  1
BNE     t3, t6, HighKongCheck
NOP
LI      t3, 6
B       UnlockedCheck
NOP

// If Kong == 7 { Kong = 2 }
HighKongCheck:
LI      t6  7
BNE     t3, t6, UnlockedCheck
NOP
LI      t3, 2

// Check whether the kong is unlocked before tagging them
UnlockedCheck:
li t5, 2
beq t3, t5, GunCheck // If Desiredkong == dk then skip the unlocked check 
nop

la t5, SpeedrunModeFlags

or t6, t3, r0 // Calculate the flag array address using the kong index (multiply by 2)
sll t6, t6, 1
addu a0, t6, t5

// Save values of temporary registers that checkFlag() fiddles with
ADDIU sp -0x30
SW t0 0x24(sp)
SW t1 0x20(sp)
SW t2 0x1C(sp)
SW t3 0x18(sp)
SW t4 0x14(sp)
SW t5 0x10(sp)

lhu a0, 0(a0) // Read the flag index from the array
JAL @checkFlag // Check whether it's set
//LI V0, 1 // DEBUG
li a1, 0 // Flag block type is "permanent"

// Restore values of temporary registers that checkFlag() fiddles with
LW t0 0x24(sp)
LW t1 0x20(sp)
LW t2 0x1C(sp)
LW t3 0x18(sp)
LW t4 0x14(sp)
LW t5 0x10(sp)
ADDIU sp 0x30

BEQZ v0, - // Desired kong isn't unlocked :(
NOP

GunCheck:
LA      t4, GunBitfields
SLL     t1, t3, 2 // Kong = Kong * 4
LW      t4, t1(t4) // Load pointer to gun bitfield
LBU     t1, 0(t4) // Read gun unlocked bitfield for new kong
ANDI    t4, t1, 0x01 // Is gun unlocked?
BEQZ    t4, PutGunAway
NOP
LBU     t1, @Actor_GunState(t2) // Was the gun out when switching kong?
BEQZ    t1, PutGunAway
NOP

TakeGunOut:
LA      t4, HandStatesGun
LBU     t4, t3(t4)
SB      t4, @Actor_HandState(t2)
LI      t4, 1
SB      t4, @Actor_GunState(t2)
B       WriteCharacter
NOP

PutGunAway:
LA      t4, HandStatesNoGun
LBU     t4, t3(t4)
SB      t4, @Actor_HandState(t2)
SB      r0, @Actor_GunState(t2)

WriteCharacter:
SB      t3, @Actor_CurrentCharacter(t2)

// Update Mystery Object (cause a tag)
LW      t2, @MysteryObjectPointer
LI      t3, 0x003B
SH      t3, @MysteryWriteOffset(t2)

Return:
J       0x805FC15C // retroben's hook but up a few functions
NOP

MapIsLoading:


UnlockMysteryMenu:
    LI      t6, 0x807ED558
    LI      t0, 0xFFFFFFFF
    SW      t0, 0(t6)
    SW      t0, 4(t6)

DontSkipGBDances:
    LI t0 0x806EFB9C
    LI t1 0xA1EE0154
    SW t1, 0(t0) // Cancel Movement Write
    LI t0 0x806EFC1C
    LI t1 0x0C189E52
    SW t1, 0(t0) // Cancel CS Play Function Call
    LI t0 0x806EFB88
    LI t1 0x0C18539E
    SW t1, 0(t0) // Cancel Animation Write Function Call
    LI t0 0x806EFC0C
    LI t1 0xA58200E6
    SW t1, 0(t0) // Cancel Change Rotation Write
    LI t0 0x806EFBA8
    LI t1 0xA3000155
    SW t1, 0(t0) // Cancel Control State Progress Zeroing

// Check whether story skip is on
// If not, skip over the extra unlocks granted by speedrun mode
LB t0, @StorySkip
BEQZ t0, CasualMode

SkipGBDances:
    LI t0 0x806EFB9C
    SW r0, 0(t0) // Cancel Movement Write
    LI t0 0x806EFC1C
    SW r0, 0(t0) // Cancel CS Play Function Call
    LI t0 0x806EFB88
    SW r0, 0(t0) // Cancel Animation Write Function Call
    LI t0 0x806EFC0C
    SW r0, 0(t0) // Cancel Change Rotation Write
    LI t0 0x806EFBA8
    SW r0, 0(t0) // Cancel Control State Progress Zeroing

SetSpeedrunModeFlags:
ADDIU	sp, sp, -0x18 // Push S0
SW		s0, 0x10(sp)
NOP

// Load flag array base into register to loop with
LA      s0, SpeedrunModeFlags

-:
    LHU     a0, 0(s0) // Load the flag index from the array
    BEQZ    a0, + // If the flag index is 0, exit the loop
    LI      a1, 1
    JAL     @setFlag
    LI      a2, 0 // It's not a temporary flag
    B       -
    ADDIU   s0, s0, 2 // Move on to the next flag in the array

+:

SetSpeedrunModeTemporaryFlags:
// Load flag array base into register to loop with
LA      s0, SpeedrunModeTemporaryFlags

-:
    LHU     a0, 0(s0) // Load the flag index from the array
    BEQZ    a0, + // If the flag index is 0, exit the loop
    LI      a1, 1
    JAL     @setFlag
    LI      a2, 2 // This time it IS a temporary flag
    B       -
    ADDIU   s0, s0, 2 // Move on to the next flag in the array

+:
LW		s0, 0x10(sp)  // Pop S0
ADDIU	sp, sp, 0x18
NOP

UnlockMoves:
li t4, 0x807FC950 // DK Base
li t6, 0x807FCB26 // Krusha base (ends the loop)

GunlockLoop:
    li t0 3
    sb t0, 0(t4) // Unlock moves
    sb t0, 1(t4) // Unlock sim slam
    sb t0, 3(t4) // Unlock ammo belt
    li t0 7
    sb t0, 2(t4) // Unlock weapon
    li t0 15
    sb t0, 4(t4) // Unlock instrument
    BNE t4, t6, GunlockLoop
    ADDIU t4, t4, 0x5E // Move onto the next kong

CasualMode:

CheckMapDisable:
// Load the start of the array
LW      t0, @NextMap
LA      t2, ExplicitDisableMaps

// Loop through and check for map == nextmap or null terminator
MapCheckLoop:
LBU     t3, 0(t2)
BEQ     t0, t3, MapMatchFound
NOP
BNEZ    t3, MapCheckLoop
ADDIU   t2, t2, 1

// No match found
SB      r0, ExplicitDisableMap
B       Return
NOP

MapMatchFound:
LI      t2, 1
SB      t2, ExplicitDisableMap
B       Return
NOP

// Magic number to find the following addresses in the hex editor
.word 0x00042069

BackupParentMap:
.half 0 // This is used by the Snide's H.Q. cutscene compression logic

ExplicitDisableMap:
.byte 0 // We'll check this when the map loads to save looping through the array each frame

ExplicitDisableMaps:
.byte 1 // Funky's Store
.byte 2 // DK Arcade
.byte 3 // K. Rool Barrel: Lanky's Maze
.byte 5 // Cranky's Lab
.byte 6 // Jungle Japes: Minecart
.byte 9 // Jetpac
.byte 10 // Kremling Kosh! (very easy)
.byte 14 // Angry Aztec: Beetle Race // Note: Softlock at the end if enabled?
.byte 15 // Snide's H.Q.
.byte 18 // Teetering Turtle Trouble! (very easy)
.byte 25 // Candy's Music Shop
.byte 27 // Frantic Factory: Car Race
.byte 31 // Gloomy Galleon: K. Rool's Ship // TODO: Test
.byte 32 // Batty Barrel Bandit! (easy)
.byte 35 // K. Rool Barrel: DK's Target Game
.byte 37 // Jungle Japes: Barrel Blast // Note: The barrels don't work as other kongs so not much point enabling it on this map
.byte 41 // Angry Aztec: Barrel Blast
.byte 42 // Troff 'n' Scoff
.byte 50 // K. Rool Barrel: Tiny's Mushroom Game
.byte 54 // Gloomy Galleon: Barrel Blast
.byte 55 // Fungi Forest: Minecart
.byte 76 // DK Rap
.byte 77 // Minecart Mayhem! (easy)
.byte 78 // Busy Barrel Barrage! (easy)
.byte 79 // Busy Barrel Barrage! (normal)
.byte 80 // Main Menu
.byte 82 // Crystal Caves: Beetle Race
.byte 83 // Fungi Forest: Dogadon
.byte 101 // Krazy Kong Klamour! (easy) // Note: Broken with switch kong
.byte 102 // Big Bug Bash! (very easy) // Note: Broken with switch kong
.byte 103 // Searchlight Seek! (very easy) // Note: Broken with switch kong
.byte 104 // Beaver Bother! (easy) // Note: Broken with switch kong
.byte 106 // Creepy Castle: Minecart
//.byte 107 // Kong Battle: Battle Arena  // TODO: Would be really cool to get multiplayer working, currently just voids you out when activated
//.byte 109 // Kong Battle: Arena 1  // TODO: Would be really cool to get multiplayer working, currently just voids you out when activated
.byte 110 // Frantic Factory: Barrel Blast
.byte 111 // Gloomy Galleon: Puftoss
.byte 115 // Kremling Kosh! (easy)
.byte 116 // Kremling Kosh! (normal)
.byte 117 // Kremling Kosh! (hard)
.byte 118 // Teetering Turtle Trouble! (easy)
.byte 119 // Teetering Turtle Trouble! (normal)
.byte 120 // Teetering Turtle Trouble! (hard)
.byte 121 // Batty Barrel Bandit! (easy)
.byte 122 // Batty Barrel Bandit! (normal)
.byte 123 // Batty Barrel Bandit! (hard)
.byte 131 // Busy Barrel Barrage! (hard)
.byte 136 // Beaver Bother! (normal)
.byte 137 // Beaver Bother! (hard)
.byte 138 // Searchlight Seek! (easy)
.byte 139 // Searchlight Seek! (normal)
.byte 140 // Searchlight Seek! (hard)
.byte 141 // Krazy Kong Klamour! (normal)
.byte 142 // Krazy Kong Klamour! (hard)
.byte 143 // Krazy Kong Klamour! (insane)
.byte 144 // Peril Path Panic! (very easy) // Note: Broken with switch kong
.byte 145 // Peril Path Panic! (easy)
.byte 146 // Peril Path Panic! (normal)
.byte 147 // Peril Path Panic! (hard)
.byte 148 // Big Bug Bash! (easy)
.byte 149 // Big Bug Bash! (normal)
.byte 150 // Big Bug Bash! (hard)
//.byte 152 // Hideout Helm (Intro Story) // Note: Handled by cutscene check
//.byte 153 // DK Isles (DK Theatre) // Note: Handled by cutscene check
.byte 165 // K. Rool Barrel: Diddy's Kremling Game
//.byte 172 // Rock (Intro Story) // Note: Handled by cutscene check
.byte 185 // Enguarde Arena // Note: Handled by character check
.byte 186 // Creepy Castle: Car Race
.byte 187 // Crystal Caves: Barrel Blast
.byte 188 // Creepy Castle: Barrel Blast
.byte 189 // Fungi Forest: Barrel Blast
.byte 190 // Kong Battle: Arena 2 // TODO: Would be really cool to get multiplayer working, currently just voids you out when activated
.byte 191 // Rambi Arena // Note: Handled by character check
.byte 192 // Kong Battle: Arena 3 // TODO: Would be really cool to get multiplayer working, currently just voids you out when activated
.byte 198 // Training Grounds (End Sequence) // Note: Handled by cutscene check
.byte 199 // Creepy Castle: King Kut Out // Note: Doesn't break the kong order but since this fight is explicitly about tagging we might as well disable
.byte 201 // K. Rool Barrel: Diddy's Rocketbarrel Game
.byte 202 // K. Rool Barrel: Lanky's Shooting Game
.byte 203 // K. Rool Fight: DK Phase // Note: Enabling here breaks the fight and may cause softlocks
.byte 204 // K. Rool Fight: Diddy Phase // Note: Enabling here breaks the fight and may cause softlocks
.byte 205 // K. Rool Fight: Lanky Phase // Note: Enabling here breaks the fight and may cause softlocks
.byte 206 // K. Rool Fight: Tiny Phase // Note: Enabling here breaks the fight and may cause softlocks
.byte 207 // K. Rool Fight: Chunky Phase // Note: Enabling here breaks the fight and may cause softlocks
.byte 208 // Bloopers Ending // Note: Handled by cutscene check
.byte 209 // K. Rool Barrel: Chunky's Hidden Kremling Game
.byte 210 // K. Rool Barrel: Tiny's Pony Tail Twirl Game
.byte 211 // K. Rool Barrel: Chunky's Shooting Game
.byte 212 // K. Rool Barrel: DK's Rambi Game
.byte 213 // K. Lumsy Ending // Note: Handled by cutscene check
.byte 214 // K. Rool's Shoe
.byte 215 // K. Rool's Arena // Note: Handled by cutscene check?
.byte 0 // NULL TERMINATOR (ends loop)

ExplicitDisableMovementStates:
//.byte 0x02 // First Person Camera
//.byte 0x03 // First Person Camera (Water)
.byte 0x04 // Fairy Camera
.byte 0x05 // Fairy Camera (Water)
.byte 0x06 // Locked (Bonus Barrel)
.byte 0x15 // Slipping
.byte 0x16 // Slipping
.byte 0x18 // Baboon Blast Pad
.byte 0x1B // Simian Spring
//.byte 0x1C // Simian Slam // Note: As far as I know this doesn't break anything, so we'll save the CPU cycles
.byte 0x20 // Falling/Splat // Note: Prevents quick recovery from fall damage, and I guess maybe switching to avoid fall damage?
.byte 0x2D // Shockwave
.byte 0x2E // Chimpy Charge
.byte 0x31 // Damaged
.byte 0x32 // Stunlocked
.byte 0x33 // Damaged
.byte 0x35 // Damaged
.byte 0x36 // Death
.byte 0x37 // Damaged (Underwater)
.byte 0x38 // Damaged
.byte 0x39 // Shrinking
.byte 0x42 // Barrel
.byte 0x43 // Barrel (Underwater)
.byte 0x44 // Baboon Blast Shot
.byte 0x45 // Cannon Shot
.byte 0x52 // Bananaporter
.byte 0x53 // Monkeyport
.byte 0x54 // Bananaporter (Multiplayer)
.byte 0x56 // Locked
.byte 0x57 // Swinging on Vine
.byte 0x58 // Leaving Vine
.byte 0x59 // Climbing Tree
.byte 0x5A // Leaving Tree
.byte 0x5B // Grabbed Ledge
.byte 0x5C // Pulling up on Ledge
.byte 0x63 // Rocketbarrel // Note: Covered by crystal HUD check except for Helm & K. Rool
.byte 0x64 // Taking Photo
.byte 0x65 // Taking Photo
.byte 0x67 // Instrument
.byte 0x69 // Car
.byte 0x6A // Learning Gun // Note: Handled by map check
.byte 0x6B // Locked
.byte 0x6C // Feeding T&S // Note: Handled by map check
.byte 0x6D // Boat
.byte 0x6E // Baboon Balloon
.byte 0x6F // Updraft
.byte 0x70 // GB Dance
.byte 0x71 // Key Dance
.byte 0x72 // Crown Dance
.byte 0x73 // Loss Dance
.byte 0x74 // Victory Dance
.byte 0x78 // Gorilla Grab
.byte 0x79 // Learning Move // Note: Handled by map check
.byte 0x7A // Locked
.byte 0x7B // Locked
.byte 0x7C // Trapped (spider miniBoss)
.byte 0x7D // Klaptrap Kong (beaver bother) // Note: Handled by map check
.byte 0x83 // Fairy Refill
.byte 0x87 // Entering Portal
.byte 0x88 // Exiting Portal
.byte 0 // NULL TERMINATOR (ends loop)

.align
SpeedrunModeFlags:
.half 367 // Diddy FTT // Note: These two flags are first to align the flag array index with the character index inside the actor object
.half 368 // Lanky FTT // DO NOT MOVE THEM OR THINGS WILL BREAK!!!
.half 385 // Kong Unlocked: DK
.half 6 // Kong Unlocked: Diddy
.half 70 // Kong Unlocked: Lanky
.half 66 // Kong Unlocked: Tiny
.half 117 // Kong Unlocked: Chunky
.half 369 // Tiny FTT
.half 370 // Chunky FTT
.half 42 // Japes: Cutscene by far W1 played // Diddy's help me cutscene
.half 93 // Aztec: Lanky's help me cutscene
.half 94 // Aztec: Tiny's help me cutscene
.half 140 // Factory: Chunky's help me cutscene

//.half 375 // Cranky's Lab Simian Slam Tutorial
.half 384 // Cranky's Lab Simian Slam Tutorial
.half 27 // Japes: Cutscene at the start played
.half 95 // Aztec: FT Cutscene
.half 92 // Aztec: Llama Cutscene
.half 194 // Galleon: First Time Cutscene
.half 257 // Fungi: First Time Cutscene
.half 282 // Caves: First Time Cutscene
.half 299 // Caves: Giant Kosha Cutscene
.half 349 // Castle: First Time Cutscene
.half 355 // Bananaporter FTT
.half 356 // Japes: Baboon Blast Cranky CS
.half 358 // Crown Pad FTT
.half 359 // T&S FTT (1)
.half 360 // Mini Monkey FTT
.half 361 // Hunky Chunky FTT
.half 362 // Orangstand Sprint FTT
.half 363 // Strong Kong FTT
.half 364 // Rainbow Coin FTT
.half 365 // Rambi FTT
.half 366 // Enguarde FTT
.half 372 // Snide's FTT
.half 376 // Wrinkly FTT
.half 377 // Camera/Shockwave
.half 378 // Training Grounds: Treehouse Squawks Cutscene
.half 382 // B. Locker FTT
.half 383 // Training Grounds: Barrels Spawned
.half 386 // Training Grounds: Dive Barrel Completed
.half 387 // Training Grounds: Vine Barrel Completed
.half 388 // Training Grounds: Orange Barrel Completed
.half 389 // Training Grounds: Barrel Barrel Completed
.half 390 // Isles: Escape Cutscene
.half 391 // Training Grounds: All Training Barrels Complete CS
.half 0 // End loop

SpeedrunModeTemporaryFlags:
.half 104 // Japes: Army Dillo Long Intro
.half 103 // Aztec: Dogadon Long Intro
.half 106 // Factory: Mad Jack Long Intro
.half 107 // Galleon: Puftoss Long Intro
.half 105 // Fungi: Dogadon Long Intro
.half 109 // Caves: Army Dillo Long Intro
.half 108 // Castle: Kut Out Long Intro
.half 101 // Caves: Beetle FT Long Intro
.half 102 // Aztec: Beetle FT Long Intro
.half 0 // End loop

.align
GunBitfields:
.word 0x00000000 // ?? // TODO: Find a way to save these bytes
.word 0x00000000 // ??
.word 0x807FC952 // DK
.word 0x807FC9B0 // Diddy
.word 0x807FCA0E // Lanky
.word 0x807FCA6C // Tiny
.word 0x807FCACA // Chunky

HandStatesNoGun:
.byte 0 // ?? // TODO: Find a way to save these bytes
.byte 0 // ??
.byte 1 // DK
.byte 0 // Diddy
.byte 1 // Lanky
.byte 1 // Tiny
.byte 1 // Chunky

HandStatesGun:
.byte 0 // ?? // TODO: Find a way to save these bytes
.byte 0 // ??
.byte 2 // DK
.byte 3 // Diddy
.byte 2 // Lanky
.byte 2 // Tiny
.byte 2 // Chunky