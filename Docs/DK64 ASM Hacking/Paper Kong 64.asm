[ReturnAddress]: 0x800074A0

// Kong Object stuff
[KongObjectPointer]: 0x8080BB4C
[RenderingParamsPointer]: 0x04

[ScaleZ]: 0x3C
[PaperScale]: 0x3C75C28F

//.org 0x807FF500

// Defererence Kong Object pointer
LUI     t0, @KongObjectPointer
LW      t0, @KongObjectPointer(t0)

// Dereference Rendering Paramaters
LW      t0, @RenderingParamsPointer(t0)

LUI     t1, @PaperScale
ORI     t1, t1, @PaperScale
SW      t1, @ScaleZ(t0)

LUI     t3, @ReturnAddress
ORI     t3, t3, @ReturnAddress
JR      t3