[SpawnActor]: 0x8032813C 
[Return]: 0x8024EE90

[XPos]: 0x8037C5A0
[YPos]: 0x8037C5A4
[ZPos]: 0x8037C5A8

.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH a2
PUSH a3
PUSH v0

LH a0 SpawnActivationFlag
BEQI a0 0 SkipSpawn
NOP

	LH a0 SpawnActorID
	LA a1 SpawnLocationArray
	JAL @SpawnActor //SpawnActor(u16 id, float[] position)
	NOP

	// Skip setting the flags if the spawn didn't succeed
	BEQI v0 0 SkipFlags
	NOP

	// Set the "spawn_item_id" to 0x03 as per the C source released by runehero
	LI a0 3
	SW a0 0xBC(v0)

	// Set the "flag2" to 0x01 as per the C source released by runehero
	LI a0 1
	SB a0 0xEB(v0)

	SkipFlags:

	// Output the pointer to global memory so ScriptHawk can see it
	LA a0 SpawnedActorPointer
	SW v0 0(a0)

	// Kill the spawn flag
	LI a0 0
	SH a0 SpawnActivationFlag

SkipSpawn:

POP v0
POP a3
POP a2
POP a1
POP a0
POP ra
J @Return
NOP

MagicHeader:
.word 0xABCDEF12
SpawnActivationFlag:
.halfword 0
SpawnActorID:
.halfword 4 // Bull
SpawnLocationArray:
.word 0
.word 0
.word 0
SpawnedActorPointer:
.word 0