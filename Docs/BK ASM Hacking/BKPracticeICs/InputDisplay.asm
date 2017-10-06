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
InputDisplay_DefStruct:
InputDisplay_State:
.byte 0
InputDisplay_MaxState:
.byte 2

.align
InputDisplay_MenuOptionString:
.word OnOffOptionString
InputDisplay_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
InputDisplay_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word InputDisplay_NormalMode
InputDisplay_Label: 
.asciiz "INPUTS: \0\0\0\0\0\0\0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
InputDisplay_PauseMode:
;YOUR PAUSE MODE CODE HERE

;-------------------------------
; Normal Mode Code
;-------------------------------
InputDisplay_NormalMode:
ADDIU sp -0x30
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)


//StickX StickY AB LR Z C:UDLR
LA a0 TEMPValueStr
SW zero 0(a0)

//A
LA a2 @RawP1Buttons
LH a0 0x00(a2)
ANDI a1 a0 0x8000
BEQ a1 zero InputDisplay_NoA
LI a1 0x20
    LI a1 0x41
InputDisplay_NoA:

LA a0 TEMPValueStr
JAL @AppendChar   

LA a2 @RawP1Buttons
LH a0 0x00(a2)
//B
ANDI a1 a0 0x4000
BEQ a1 zero InputDisplay_NoB
LI a1 0x20
    LI a1 0x42
InputDisplay_NoB:

LA a0 TEMPValueStr
JAL @AppendChar   
NOP


LA a0 TEMPValueStr
JAL @AppendChar   
LI a1 0x20

LA a2 @RawP1Buttons
LH a0 0x00(a2)
ANDI a1 a0 0x0020
BEQ a1 zero InputDisplay_NoL
LI a1 0x20
    LI a1 0x4C
InputDisplay_NoL:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP

LA a2 @RawP1Buttons
LH a0 0x00(a2)
ANDI a1 a0 0x2000
BEQ a1 zero InputDisplay_NoZ
LI a1 0x20
    LI a1 0x5A
InputDisplay_NoZ:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP

LA a2 @RawP1Buttons
LH a0 0x00(a2)
ANDI a1 a0 0x0010
BEQ a1 zero InputDisplay_NoR
LI a1 0x20
    LI a1 0x52
InputDisplay_NoR:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP

//C
LA a2 @RawP1Buttons
LH a0 0x00(a2)
ANDI a1 a0 0x000F
BNE a1 zero InputDisplay_CPressed
LI a1 0x20
LI at 0x07
InputDisplay_PlaceSpaces:
    LA a0 TEMPValueStr
    JAL @AppendChar 
    SUBI at 1
BNE zero at InputDisplay_PlaceSpaces
NOP
B NormalModeCode_Normal_Print


InputDisplay_CPressed:
LA a0 TEMPValueStr
JAL @AppendChar   
LI a1 0x20
LA a0 TEMPValueStr
JAL @AppendChar   
LI a1 0x43
LA a0 TEMPValueStr
JAL @AppendChar   
LI a1 0x3A


LA a2 @RawP1Buttons
LH a0 0x00(a2)
//B
ANDI a1 a0 0x0002
BEQ a1 zero InputDisplay_NoCL
LI a1 0x20
    LI a1 0x4C
InputDisplay_NoCL:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP
LA a2 @RawP1Buttons
LH a0 0x00(a2)
//B
ANDI a1 a0 0x0008
BEQ a1 zero InputDisplay_NoCU
LI a1 0x20
    LI a1 0x55
InputDisplay_NoCU:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP
LA a2 @RawP1Buttons
LH a0 0x00(a2)
//B
ANDI a1 a0 0x0004
BEQ a1 zero InputDisplay_NoCD
LI a1 0x20
    LI a1 0x44
InputDisplay_NoCD:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP
LA a2 @RawP1Buttons
LH a0 0x00(a2)
//B
ANDI a1 a0 0x0001
BEQ a1 zero InputDisplay_NoCR
LI a1 0x20
    LI a1 0x52
InputDisplay_NoCR:
LA a0 TEMPValueStr
JAL @AppendChar   
NOP


NormalModeCode_Normal_Print:

LI a1 0xD0 // Y Pos
LA a2 TEMPValueStr
JAL @Print_CharFont_Background
LI a0 0x43 //X Pos


//Analog
SB zero AnalogValueStr

LA a0 AnalogValueStr
LA a2 @RawP1Buttons
LB a1 0x02(a2)
JAL @IToA_10
NOP

LA a0 AnalogValueStr
JAL @AppendChar 
LI a1 0x2C

LA a2 @RawP1Buttons
LB a1 0x03(a2)
LA a0 AnalogValueStr
JAL @IToA_10
NOP

LA a2 @RawP1Buttons
LB a1 0x03(a2)
SRA a1 a1 0x02
LI  a0 0xA6
SUB a1 a0 a1

LA a2 @RawP1Buttons
LB a0 0x02(a2)
SRA a0 a0 0x02
ADDIU a0 a0 0x20

LA a2 TEMP2ValueStr
JAL @Print_CharFont_Background
NOP


LA a2 AnalogValueStr
LI a1 0xD0
JAL @Print_CharFont_Background
LI a0 0x04


NormalModeCode_InputDisplayNormal:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x30
JR
NOP

.align
TEMPValueStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
TEMP2ValueStr:
.asciiz ".\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
AnalogValueStr:
.asciiz ".\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"