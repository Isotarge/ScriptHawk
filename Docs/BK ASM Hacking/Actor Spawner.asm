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

LH a0 SpawnActivationFlag
BEQI a0 0 SkipSpawn
LH a0 SpawnActorID
LA a1 SpawnXLocation
JAL @SpawnActor //SpawnActor(u16 id, float[] position)
NOP

// Kill the spawn flag
LI a0 0
SH a0 SpawnActivationFlag

SkipSpawn:
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
.halfword 4
SpawnXLocation:
.word 0
SpawnYLocation:
.word 0
SpawnZLocation:
.word 0