// Hook
.org 0x80334FFC
JAL 0x80400000

/*HOOK USED WAS 0x80334FFC
|    hook was a JAL to a null_function in the same function that updates the playersPositionVel, etc
|    NOTE: Since player only updates when game is in normalUpdateMode: 2 (not paused),
|          the hook will not catch when game it paused
*/

//ENUMERATIONS
.include "Docs/BK ASM Hacking/BK_Enum.S"
//FUNCTIONS & VARIABLES
.include "Docs/BK ASM Hacking/BK_NTSC.S"
.include "Docs/BK ASM Hacking/Position Display.asm"
