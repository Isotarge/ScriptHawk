[ReturnAddress]: 0x800074A0

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

LBU     t9, 6(sp) // These 4 lines appear to be replaced by Subdrag's hook, they don't contribute to our code but they might prevent some crashes/weirdness so I'll keep them
ANDI    t0, t9, 0x00C0
SRA     t1, t0, 0x04
ANDI    t2, t1, 0x00FF
J       @ReturnAddress
NOP
