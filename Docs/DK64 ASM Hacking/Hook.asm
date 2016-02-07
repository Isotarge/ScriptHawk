// DK64 US ASM hook
// Found by SubDrag 2006
// http://www.therwp.com/forums/showpost.php?s=66557cdf2d91b0a5e82fea91bd14a5af&p=128750&postcount=6

// Executes every frame (including lag frames) after controller data is set

// Put the hook at 0x80007494 on the system bus
// Put your code at 0x807FF500 on the system bus
[JumpAddress]: 0x807FF500

// JR to to 0x800074A0 when finished
// Assemble with Lips
// https://github.com/notwa/lips

// Assembled: 3C08807F3508F5000100000800000000

// .org 0x80007494
LUI     t0, @JumpAddress
ORI     t0, t0, @JumpAddress
JR      t0
NOP
