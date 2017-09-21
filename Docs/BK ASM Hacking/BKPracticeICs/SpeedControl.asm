;--------------------------------------------------
; Function Definition Structure
;--------------------------------------------------
; This struct contains all the info needed for the 
; practice menu to successfully run the function
; in the practice menu
;
; Add X_DefStruct to the function list in PracticeMenu.asm
;--------------------------------------------------
.align
SpeedCtrl_DefStruct:
SpeedCtrl_State: ;STATE AT STARTUP
.byte 0
SpeedCtrl_MaxState: ;TOTAL # OF STATES
.byte 2

.align
SpeedCtrl_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word OnOffOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

SpeedCtrl_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word SpeedCtrl_PauseMode ;set to 0 if no code is to be run upon exiting the pause menu

SpeedCtrl_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word SpeedCtrl_NormalMode ;set to 0 if no code is to be run during Normal menu

SpeedCtrl_Label: ;LABEL IN MENU
.asciiz "SPEED CTRL: \0\0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
SpeedCtrl_PauseMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a1 SpeedCtrl_State
BNE zero a1 SpeedCtrl_PauseMode_HouseKeeping
LI a0 1
    mtc1 a0 f12
    cvt.s.w f12 f12
    JAL @SetGameSpeedCoefficient
    LI a0 2
    SB a0 SpeedCtrl_Speed
    
SpeedCtrl_PauseMode_HouseKeeping:
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP

;-------------------------------
; Normal Mode Code
;-------------------------------
SpeedCtrl_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)


LB a0 SpeedCtrl_Speed
LI at 2
BEQ a0 at SpeedCtrl_Normal_SpeedChange
NOP
    LA a2 SpeedCtrl_Speed_Strings
    SLL a0 a0 3
    ADDU a2 a2 a0
    LI a1 0xD1 // Y Pos
    JAL @Print_CharFont_Background
    LI a0 0x08
    //print speed to screen




//check buttons
SpeedCtrl_Normal_SpeedChange:
LW a0 @P1NewlyPressedButtons
    LUI a1 0x0200
    AND a1 a0 a1
    
    //Case D-pad left
    BEQ zero a1 SpeedCtrl_Normal_NotDown
    NOP
        LB a0 SpeedCtrl_Speed
        BEQ a0 zero SpeedCtrl_Normal_HouseKeeping
        NOP
            //decrement
            SUBI a0 a0 1
            SB a0 SpeedCtrl_Speed
            B SpeedCtrl_Normal_Apply
            NOP
SpeedCtrl_Normal_NotDown:
    LUI a1 0x0100
    AND a1 a0 a1
    //Case D-pad right
    BEQ zero a1 SpeedCtrl_Normal_HouseKeeping 
    NOP
        LB a0 SpeedCtrl_Speed
        LI at 4
        BEQ a0 at SpeedCtrl_Normal_HouseKeeping
        NOP
            //increment
            ADDIU a0 a0 1
            SB a0 SpeedCtrl_Speed

SpeedCtrl_Normal_Apply:
    //clamp value
    LB a0 SpeedCtrl_Speed
    LI a1 1
    SLLV a1 a1 a0
    mtc1 a1 f12
    cvt.s.w f12 f12
    LI a0 4
    mtc1 a0 f0
    cvt.s.w f0 f0
    div.s f12 f12 f0
    JAL @SetGameSpeedCoefficient
    NOP

SpeedCtrl_Normal_HouseKeeping:
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP

;-------------------------------
; Variables
;-------------------------------
SpeedCtrl_Speed:
.byte 2 ;0=.25x, 1 = .5x, 2 = 1x, 3 = 2x, 4 = 4x

.align
SpeedCtrl_Speed_Strings:
.asciiz "0.25X\0\0"
.asciiz "0.5X\0\0\0"
.asciiz "\0\0\0\0\0\0\0"
.asciiz "2X\0\0\0\0\0"
.asciiz "4X\0\0\0\0\0"