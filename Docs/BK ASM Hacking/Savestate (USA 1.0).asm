//Boot map
.org 0x8023DBAB
.byte 0x91

//intro cutscene skip
//.org 0x8031C640
//LI V0 0x01
//JR ra
//NOP

//lair cutscene skip
//.org 0x8031C688
//LI V0 0x01
//JR ra
//NOP

// HOOKS
;NORMAL MODE JUMP LOCATION: 0x80334FFC
.org 0x80334FFC
JAL NormalModeCode
NOP

//ENUMERATIONS
.include "Docs/BK ASM Hacking/BK_Enum.S"
//EXISTING FUNCTIONS
.include "Docs/BK ASM Hacking/BK_NTSC.S"

//EXISTING VARIABLES
[P1DPadUp]:0x8028115C
[P1DPadDown]:0x80281160
[P1DPadLeft]:0x80281164
[P1DPadRight]:0x80281168
[P1Start]:0x8028116C
[PauseMenuData]:0x8036C4E0
[PauseMenuState]:0x80383010

.include "Docs/BK ASM Hacking/new_ss.asm"