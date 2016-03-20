[ReturnAddress]: 0x800074A0

// Kong Object stuff
[KongObjectPointer]: 0x807FBB4C
[RenderingParamsPointer]: 0x04

[ScaleZ]: 0x3C
[PaperScale]: 0x3C75C28F

.org 0x807FF500

// Defererence Kong Object pointer
LW      t0, @KongObjectPointer

// Dereference Rendering Paramaters
LW      t0, @RenderingParamsPointer(t0)

LI      t1, @PaperScale
SW      t1, @ScaleZ(t0)

J       @ReturnAddress
NOP
