// Hook
.org 0x807140BC

jal 0x807FF500
nop
b 0x80714110
nop

// Kong Object stuff
[KongObjectPointer]: 0x807FBB4C
[RenderingParamsPointer]: 0x04

[ScaleZ]: 0x3C
[PaperScale]: 0x3C75C28F

.org 0x807FF500

// Defererence Kong Object pointer
LW      t0, @KongObjectPointer

// Dereference Rendering Parameters
LW      t0, @RenderingParamsPointer(t0)

LI      t1, @PaperScale
SW      t1, @ScaleZ(t0)

JR      ra
NOP
