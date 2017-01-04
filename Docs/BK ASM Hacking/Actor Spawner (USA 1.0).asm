// Hook
.org 0x8024EE90
JAL 0x80400000

[Return]: 0x8024E420
[SpawnActor]: 0x8032813C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (float $a2 rotation)
[SpawnAndCarryActor]: 0x8028DE0C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr)

.include "Actor Spawner.asm"