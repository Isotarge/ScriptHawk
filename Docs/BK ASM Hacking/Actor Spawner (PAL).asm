// Hook
.org 0x8024EAE0
JAL 0x80400000

[Return]: 0x8024E070
[SpawnActor]: 0x80328594 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

.include "Actor Spawner.asm"