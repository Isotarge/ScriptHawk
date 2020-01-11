// Only works on USA 1.0
// Poke 0x400000 to 0x01 to simulate a lag frame on the next time it updates
// It will be reset to 0 next frame

.org 0x802E43F8
jal LagSimStart

.org 0x80400000
ForceLagByte:
.byte 0

.org 0x80400010
LagSimStart:
push ra

lb a0 ForceLagByte
beqz a0 End
nop

li a0 0x10
jal 0x8033DD04
nop

sb r0 ForceLagByte

End:
pop ra
jr ra
nop