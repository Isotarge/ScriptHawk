[ReturnAddress]: 0x8024EE90

[ReadStart]: 0x8037BF20
[ReadEnd]: 0x8037C70C
[WriteStart]: 0x80410000
[WriteEnd]: 0x804107EC

.org 0x80400000
PUSH v0 // Read from
PUSH t6 // Controller input
PUSH t7 // Holding Register
PUSH t8 // Write to
PUSH t9 // Write until

Save:
LI      v0, @ReadStart
LI      t8, @WriteStart
LI      t9, @WriteEnd

CheckController:
LUI     t6, 0x8028
LH      t6, 0x1250(t6)	// Load controller input (0x80281250)
ADDIU   t7, r0, 0x0020  // L button
BEQ     t7, t6, TransferWord
NOP
ADDIU   t7, r0, 0x0010  // R Button
BNE     t7, t6, Return
NOP

Load:
LI      v0, @WriteStart
LI      t8, @ReadStart
LI      t9, @ReadEnd

TransferWord:
LW      t7, 0x0000(v0)	// Read word
SW      t7, 0x0000(t8)	// Write word
ADDIU   v0, v0, 0x0004	// r += 4
BNE     t9, t8, TransferWord
ADDIU   t8, t8, 0x0004	// w += 4

Return:
POP t9
POP t8
POP t7
POP t6
POP v0
J       @ReturnAddress
NOP
