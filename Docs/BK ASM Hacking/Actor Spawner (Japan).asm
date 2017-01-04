// Hook
.org 0x8024DBE0
JAL 0x80400000

[Return]: 0x8024D170
[SpawnActor]: 0x803285C4 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (float $a2 rotation)
[SpawnAndCarryActor]: 0x803285C4 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr) ;TODO: Find this function

.include "Actor Spawner.asm"