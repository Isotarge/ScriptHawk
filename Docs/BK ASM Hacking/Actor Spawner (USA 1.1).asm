// Hook
.org 0x8024DBE0
JAL 0x80400000

[Return]: 0x8024D170
[SpawnActor]: 0x80327334 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

.include "Actor Spawner.asm"