.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH v0

LB a0 SpawnActivationFlag
BEQZ a0 SkipSpawn
NOP
	LH a0 SpawnActorID
	LA a1 SpawnLocationArray

	LB t0 SpawnCarryFlag
	BNEZ t0 SpawnCarry
	NOP
		Spawn:
		JAL @SpawnActor //SpawnActor(u16 id, float[] position)
		NOP
		B FinishedSpawn
		NOP

		SpawnCarry:
		JAL @SpawnAndCarryActor
		NOP

	FinishedSpawn:
	// Output the pointer to global memory so ScriptHawk can see it
	SW v0 SpawnedActorPointer

	// Kill the spawn flag
	SB r0 SpawnActivationFlag

SkipSpawn:
POP v0
POP a1
POP a0
POP ra
J @Return
NOP

MagicHeader:
.word 0xABCDEF12
SpawnActivationFlag:
.byte 0
SpawnCarryFlag:
.byte 0
SpawnActorID:
.halfword 4 // Bull
SpawnLocationArray:
.word 0
.word 0
.word 0
SpawnedActorPointer:
.word 0