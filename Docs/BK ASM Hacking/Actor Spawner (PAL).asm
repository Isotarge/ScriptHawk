// Hook
.org 0x8024EAE0
JAL 0x80400000

[Return]: 0x8024E070
[SpawnActor]: 0x80328594 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

.org 0x80400000
PUSH ra
PUSH a0
PUSH a1
PUSH v0

LH a0 SpawnActivationFlag
BEQZ a0 SkipSpawn
NOP
	LH a0 SpawnActorID
	LA a1 SpawnLocationArray
	JAL @SpawnActor //SpawnActor(u16 id, float[] position)
	NOP

	// Output the pointer to global memory so ScriptHawk can see it
	SW v0 SpawnedActorPointer

	// Kill the spawn flag
	SH r0 SpawnActivationFlag

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
.halfword 0
SpawnActorID:
.halfword 4 // Bull
SpawnLocationArray:
.word 0
.word 0
.word 0
SpawnedActorPointer:
.word 0