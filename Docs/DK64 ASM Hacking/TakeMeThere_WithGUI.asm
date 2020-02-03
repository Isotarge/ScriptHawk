;************************************
; Written by GloriousLiar
; v1 - 10/2/17
; v2 - 1/26/20
; v3 - 2/3/20
; Template code by Isotarge & MittenzHugg
; Credit to retroben and SubDrag for the hooks
;************************************
 
;************************************
; CONSTANTS & ADDRESSES
;************************************ 
[DestinationMap]: 0x807444E4
[DestinationEntrance]: 0x807444E8

[SecurityText]: 0x8075E5DC
[SecurityByte]: 0x807552E0
[ControllerInput]: 0x80014DC4

[ZipperBitfield]: 0x807FBB62

[L_Button]: 0x0020
[D_Up]: 0x0800		;check this
[D_Down]: 0x0400
[D_Left]: 0x0200
[D_Right]: 0x0100

[NewlyPressed]: 0x807ECD48
[ButtonHeld]: 0x807ECD58

[TinyHelmTSB]: 0x807FCAA0		;used to store level text offset
[TinyIslesTSB]: 0x807FCA9E		;used to store map index

.org 0x805FC164 // retroben's hook but up a few functions
J Start

.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this
Start:
// Run the code we replaced
JAL     0x805FC2B0
NOP

;Check for L+DDown, Force zip to destination map
LH      t0, @ControllerInput
LI      t1, @L_Button
LI		t2, @D_Down
OR		t1, t1, t2
AND		t0, t0, t1
BEQZ    t0, t1, LCheck
NOP
J		ForceZipper
NOP

LCheck:
;Check for L Input
LH      t0, @ControllerInput
LI      t1, @L_Button
AND		t0, t0, t1
BEQZ    t0, Return

;Check for DRight or DLeft
LH      t0, @ControllerInput
LI      t1, @D_Left
LI		t2, @D_Right
OR		t1, t1, t2
AND		t0, t0, t1
BEQZ    t0, Return

;Set security byte
LI      t3, 1
SB      t3, @SecurityByte

;Check if Button is Newly Pressed
LH		t0, @NewlyPressed
BEQZ	t0, Return

;Get list traversal direction
LH      t0, @ControllerInput
LI      t1, @D_Left
AND		t0, t0, t1
BEQ		t0, t1, SetIteratorLeft
NOP
J		SetIteratorRight
NOP

SetIteratorLeft:
LI		t1, -0x1
LI		t5, -0x1	;copy
J		IteratorDirectionSet
NOP

SetIteratorRight:
LI		t1, 0x1
LI		t5, 0x1		;copy
J		IteratorDirectionSet
NOP

IteratorDirectionSet:
;Get Level Text Index
LA      t2, @TinyHelmTSB                 	;t2 = *TinyHelmTSB
LHU     t0, 0x00(t2)                        ;t0 = *t2(level_text iterator index)
ADDI	t0, t0, 0x1                         ;t0 = t0 + 1(account for dummy \0)
LI		t2, -0x1
BEQ		t1, t2, FindPreviousLevelText
NOP
J		ReturnWithOffset
NOP

FindPreviousLevelText:
LA		t7, Level_Text
ADDU	t7, t7, t0							;store in t7 level_text + offset(from helm bananas)
ADDI	t7, t7, -0x1
LB		t8, 0x0(t7)							;read previous character
BEQZ	t8, NullCharFound					;null char has been found, branch
NOP
IteratorLoop:
	;t7 = t7-1
	;t8 = read byte (t7)
	;branch if zero -> t8, nullcharfound
	;else branch to iteratorloop

NullCharFound:
;check if min state, wrap
LA		t9,	Level_Text
SUBU	t1, t7, t9							;t1 = iterator index - level_text base (offset)
BEQZ	t1, WrapLevelText					;wrap around if offset = 0
NOP
J		ReturnWithOffset
NOP

WrapLevelText:
LA		t1, Level_Text_MaxState
LB		t1, 0x0(t1)
J		ReturnWithOffset
NOP

ReturnWithOffset:
;Get Map Index
LA      t2, @TinyIslesTSB                 	;t2 = *TinyIslesTSB
LB     	t0, 0x00(t2)                        ;t0 = *t2
ADDU	t4, t0, t5                          ;t4 = t0 + t5(map offset, iterator direction)
;Wrap around if past Helm
LA		t5, TakeMeThere_MaxState
LB		t5, 0(t5)
BEQ		t4, t5, MapMinReset
NOP
;Wrap around if at Isles
LA		t5, TakeMeThere_MinState
LB		t5, 0(t5)
BEQ		t4, t5, MapMaxReset

Begin:
;Index the start of the level's text
LA		t2, Level_Text						;t2 = *Level_Text
ADDU	t2, t2, t1							;t2 = t2 + t1 (Level_Text + level text offset)

;Loop through the level text
;t3 = Security Text address + index of text
;t5 = byte read from Level_Text + map_offset
PrintText:
LI      t3, @SecurityText					;t3 = *SecurityText
LoopThroughLevelText:
	LB		t5, 0x0(t2) 						;t5 = byte from t2 (level text at index)
	BNEZ	t5, Place_Character 				;break when you hit the null char
	NOP

;cleanup, save level_text offset to TinyHelmTSB
LA		at, @TinyHelmTSB
LA		t0, Level_Text						;t0 = base address
SUB		t2, t2, t0							;t2 = current address - base address (offset)
SH      t2, 0x00(at)       					;*TinyHelmTSB = t2 (tiny bananas = level text offset)
NOP
LA		at, @TinyIslesTSB					
SB		t4, 0(at)							;*TinyIslesTSB = t4
NOP

J 		Return

;Helper function for LoopThroughLevelText
Place_Character:
SB      t5, 0(t3)							;store level text's byte at t3+index
ADDI	t3, t3, 0x1							;increment t3 (security text index)
ADDI	t2, t2, 0x1							;increment t2 (level text index)
B		LoopThroughLevelText				;keep looping
NOP

;Helper function map reset
MapMinReset:
LA		t4, TakeMeThere_MinState
LB		t4, 0(t4)
LA		t1, Level_Text_MinState
LB		t1, 0(t1)
J		Begin
NOP

;Helper function map reset
MapMaxReset:
LA		t4, TakeMeThere_MaxState
LB		t4, 0(t4)
LA		t1, Level_Text_MaxState
LB		t1, 0(t1)
J		Begin
NOP

ForceZipper:
;set map
LA		at, @DestinationMap
LA		t2, TakeMeThere_WarpLocations
LA		t4, @TinyIslesTSB
LB		t4, 0x0(t4)
ADDU	t2, t4, t2							;TakeMeThere_WarpLocations + t4(offset)
LB		t2, 0x00(t2)
SW      t2, 0x00(at)
;set exit
LA		at, @DestinationEntrance
LI		t2, 0x00
SW		t2, 0x00(at)
;check newly pressed
LH		t0, @NewlyPressed
BEQZ	t0, Return
NOP
;force zipper
LA      at, @ZipperBitfield
LB      t0, 0x00(at)
ORI     t1, t0, 0x01
SB      t1, 0x00(at)
J 		Return
NOP

Return:
J       0x805FC15C // retroben's hook but up a few functions
NOP

;************************************
; ADDITIONAL VARS
;************************************
.align
Level_Text:
.byte 0x0;dummy
.asciiz "ISLES"
.asciiz "JAPES"
.asciiz "AZTEC"
.asciiz "FACTORY"
.asciiz "GALLEON"
.asciiz "FOREST"
.asciiz "CAVES"
.asciiz "CASTLE"
.asciiz "HELM"

.align
TakeMeThere_WarpLocations:
.byte 0x00;dummy
.byte 0x22;Isles
.byte 0x07;Japes
.byte 0x26;Aztec
.byte 0x1A;Factory
.byte 0x1E;Galleon
.byte 0x30;Fungi
.byte 0x48;Caves
.byte 0x57;Castle
.byte 0x11;Helm

.align
Level_Text_MinState:
.byte 1

.align
Level_Text_MaxState
.byte 0x3D ;maybe not correct- point to start of "HELM"

.align
TakeMeThere_MinState:
.byte 1
 
.align
TakeMeThere_MaxState:
.byte 0xA
