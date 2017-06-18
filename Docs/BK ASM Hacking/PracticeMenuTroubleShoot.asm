//Banjo-Kazooie Speedrunning Cheat Menu
//Enter Main Menu by pressing start, then press D-left to switch to practice menu
//  Press D-Right to return to main menu
//
//
// TO DO: Append Each menu item's current state to end of sting
//        Create functions for setting enable bits/states for each
//        Create normal mode code section

// HOOKS

;PAUSE MODE JUMP LOCATION: 0x802E47F4
.org 0x802E47F4
JAL 0x80400000

//EXISTING FUNCTIONS
.include "Docs/BK ASM Hacking/BK_NTSC.S"

.org 0x80400000
PauseMode:
PUSH ra

JAL @PauseMenu
NOP 

HouseKeeping:
POP ra
JR
NOP





