[Lag_OSDXOffset]: 0xC0
[Lag_Drop_YOffset]: 0xC7
[Lag_FPS_YOffset]: 0xD1
[Lag_WindowSize]: 16


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
Lag_DefStruct:
Lag_State: ;STATE AT STARTUP
.byte 0
Lag_MaxState: ;TOTAL # OF STATES
.byte 2

.align
Lag_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word OnOffOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

Lag_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word Lag_PauseMode ;set to 0 if no code is to be run upon exiting the pause menu

Lag_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word Lag_NormalMode ;set to 0 if no code is to be run during Normal menu

Lag_Label: ;LABEL IN MENU
.asciiz "LAG MONITOR: \0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
Lag_PauseMode:
ADDIU sp -0x20
SW ra 0x1C(sp)
SW a0 0x18(sp)

SW zero Lag_Count

LW ra 0x1C(sp)
LW a0 0x18(sp)
ADDIU sp 0x20
JR
NOP

;-------------------------------
; Normal Mode Code
;-------------------------------
Lag_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)


JAL @GetGameTimeScaleFactor
NOP

//DROPPED FRAMES COUNT
LW a1 Lag_Count
SUBIU a0 v0 0x02
ADDU a1 a1 a0
SW a1 Lag_Count
LA a0 Lag_OutputString
SB zero 0(a0)
LA a1 Lag_CountStr
JAL @CopyString
NOP
LA a0 Lag_OutputString
LW a1 Lag_Count
JAL @IToA_10
NOP
LI a1 @Lag_Drop_YOffset
LA a2 Lag_OutputString
JAL @Print_CharFont_Background
LI a0 @Lag_OSDXOffset


//SHIFT FPS WINDOW
LI at @Lag_WindowSize
SUBI at at 1
Lag_WindowShift:
    LA a1 Lag_FPSWindow
    SLL a2 at 2
    ADDU a1 a1 a2 
    LW a2 -4(a1)
    SW a2 0(a1)
    SUBI at at 1
BNE at zero Lag_WindowShift
NOP

LI a0  60
JAL @GetGameTimeScaleFactor
NOP
DIV a0 v0
mflo a0

LA a1 Lag_FPSWindow
SW a0 0(a1)




LA a0 Lag_OutputString2
SB zero 0(a0)
LA a1 Lag_FPSStr
JAL @CopyString
NOP


//AVERAGE FPS WINDOW
LI at @Lag_WindowSize
MOV a0 zero
Lag_WindowAvg:
    SUBI at at 1
    LA a1 Lag_FPSWindow
    SLL a2 at 2
    ADDU a1 a1 a2 
    LW a2 0(a1)
    ADDU a0 a0 a2
BNE at zero Lag_WindowAvg
//convert to float
mtc1 a0 f0
cvt.d.w f0 f0
LI a0 @Lag_WindowSize
mtc1 a0 f0
cvt.d.w f2 f0
div.d f0 f0 f2
cvt.s.d f0 f0
mfc1 a1 f0


LA a0 Lag_OutputString2
JAL @FToA
LI a2 0x04
LI a1 @Lag_FPS_YOffset
LA a2 Lag_OutputString2
JAL @Print_CharFont_Background
LI a0 @Lag_OSDXOffset


Lag_Normal_HouseKeeping:
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
.align

Lag_Count: 
.word 0

Lag_FPSWindow:
.word 30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30

.align
Lag_CountStr:
.asciiz "DROP: \0\0\0\0\0\0\0\0\0"
Lag_FPSStr:
.asciiz "FPS: \0\0\0\0\0\0\0\0\0"
Lag_OutputString:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
Lag_OutputString2:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
