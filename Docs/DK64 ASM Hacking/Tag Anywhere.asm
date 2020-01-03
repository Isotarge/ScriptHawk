// Donkey Kong 64 - Tag Anywhere (V1) (U)
// Made with love by Isotarge
// With help from Tom Ballaam, 2dos, Mittenz, retroben, Kaze Emanuar, SubDrag, runehero123, Skill

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
// Use ScriptHawk's loadASMPatch() to assemble this file into vanilla DK64 US running RDRAM
// Copy the 4 patched bytes at the hook location into notepad or a hex editor, 0x60B0DC in RDRAM
// Find the original hook location using surrounding bytes in the decompressed version of 0113F0_ZLib.bin
// Overwrite the hook with the patched version
// Recompress the patched 0113F0_ZLib.bin with gedecompress
// If the recompressed 0113F0_ZLib.bin is smaller or the same size as the original (fits between 113F0 and C29D4 in ROM), overwrite it in ROM
// If it's bigger, you're out of luck for now (will be possible when tools & knowledge improve), try and decrease the entropy of the patch so it's smaller when recompressed
// Open BizHawk's hex editor and navigate to the main code in RDRAM at 0xED30 (chews up the missing Expansion Pak message)
// Copy all the patched bytes upto the 0x00000000 (NOP) after the return
// Overwrite the same bytes in ROM (it's uncompressed, near the start)
// Navigate to 0x3154 in ROM and replace with 0x00000000, this disables the security(or is it error?) checks on compressed files
// Save the patched ROM
// Fix the patched ROM's CRCs with n64crc

[ControllerInput]: 0x807ECD66
[KongObjectPointer]: 0x807FBB4C
[MysteryObjectPointer]: 0x807FC924

[MysteryWriteOffset]: 0x29C
[CurrentCharacter]: 0x36F
[L_Button]: 0x0020

.org 0x8060B0DC // retroben's hook
J Start

.org 0x8000ED30 // In the Expansion Pak error message text, TODO: Better place to put this
Start:

// Check if L is newly pressed
LH      t2, @ControllerInput
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return

// Update Player Actor with new character value
LW      t2, @KongObjectPointer
LB      t3, @CurrentCharacter(t2)
ADDIU   t3, t3, 1
SLTI    t0, t3, 7
BNEZ    t0, WriteCharacter
NOP
LI      t3, 2

WriteCharacter:
SB      t3, @CurrentCharacter(t2)

// Update Mystery Object (cause a tag)
LW      t2, @MysteryObjectPointer
LI      t3, 0x003B
SH      t3, @MysteryWriteOffset(t2)

Return:
J 0x8060B0E4
NOP