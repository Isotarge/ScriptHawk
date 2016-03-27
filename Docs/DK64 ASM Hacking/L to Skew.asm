[ReturnAddress]: 0x800074A0

[ControllerInput]: 0x80014DC4
[KongObjectPointer]: 0x807FBB4C

[Z_Rot]: 0xE8
[L_Button]: 0x0020

.org 0x807FF500
LH      t2, @ControllerInput
ADDIU   t3, r0, @L_Button
BNE     t2, t3, Return

LW      t0, @KongObjectPointer
LI      t3, 0x3C00 // Skew amount
SH      t3, @Z_Rot(t0)

Return:
LBU     t9, 6(sp) // These 4 lines appear to be replaced by Subdrag's hook, they don't contribute to our code but they might prevent some crashes/weirdness so I'll keep them
ANDI    t0, t9, 0x00C0
SRA     t1, t0, 0x04
ANDI    t2, t1, 0x00FF
J       @ReturnAddress
NOP

// Gameshark version:
// 81007494 3C08
// 81007496 807F
// 81007498 3508
// 8100749A F500
// 8100749C 0100
// 8100749E 0008
// 810074A0 0000
// 810074A2 0000
// 817FF500 3C01
// 817FF502 8001
// 817FF504 842A
// 817FF506 4DC4
// 817FF508 240B
// 817FF50A 0020
// 817FF50C 154B
// 817FF50E 0004
// 817FF510 3C01
// 817FF512 8080
// 817FF514 8C28
// 817FF516 BB4C
// 817FF518 240B
// 817FF51A 3C00
// 817FF51C A50B
// 817FF51E 00E8
// 817FF520 93B9
// 817FF522 0006
// 817FF524 3328
// 817FF526 00C0
// 817FF528 0008
// 817FF52A 4903
// 817FF52C 312A
// 817FF52E 00FF
// 817FF530 0800
// 817FF532 1D28
// 817FF534 0000
// 817FF536 0000