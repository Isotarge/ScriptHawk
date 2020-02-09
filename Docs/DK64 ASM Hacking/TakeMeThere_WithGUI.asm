;************************************
; Take Me There by GloriousLiar - 2/8/20
;************************************
.org	0x807FCAA1		;set initial level_text_offset
.byte	1
.org	0x807FCA9F		;set initial map offset
.byte	1
.org	0x80744718		;ptr to string
.word	0

.org 	0x805FC164 // retroben's hook but up a few functions
J 		Start2

.org 	0x805fe354 // write over jump to SecuritySomething
J		Start

.org 	0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this
.include "DK64Library.s"

Start:
JAL		0x80714060; SecurityFunction
NOP
ADDI	a0, v0, 0x0; put result in a0

JAL		0x807132dc	;v0 = global display list
NOP
ADDI	a0, v0, 0x0

;Check LButton
LI		t0, @L_Button
LA		t1, @ControllerInput
LHU		t1, 0x00(t1)
AND		t0, t0, t1
BEQZ	t0, Return
NOP

LA		t0, @KrushaInstrument
LW		t0, 0x00(t0)			;dereference ptr at krusha instrument
;		a0 = global_display_list
LI		a1, 0x280				;x
LI		a2, 0x1e0				;y
LI		a3, 0x3e800000			;scale = 0.25
ADDIU	sp, sp, -0x14
SW		t0, 0x10(sp)
JAL		0x806abb98				;printText
NOP
ADDIU	sp, sp, 0x14

Return:
JAL		0x805fe358
NOP

//start second hook
Start2:

// Run the code we replaced
JAL     0x805FC2B0
NOP

LA		t0, @KrushaInstrument
LW		t1, 0x00(t0)
BEQZ	t1, SetInitialPtr				;ptr check
NOP

;Check newly pressed
LA		t1, @NewlyPressed
LHU		t1, 0x00(t1)
BEQZ	t1, Return2
NOP

;Check LButton
LI		t2, @L_Button
LA		t3, @ControllerInput
LH		t3, 0x00(t3)
AND		t2, t2, t3
BEQZ	t2, Return2
NOP
;L+DDown
LI		t2, @D_Down
AND		t2, t2, t3
BEQZ	t2, SetDisplay
NOP
;Force zip
LA		t0,	@TinyIslesTSB
LH		t0, 0x0(t0)
LA		t1, MapCodes
ADDU	t0, t1, t0
LB		t0, 0x0(t0)
LI		t1, 0x0
JAL		ForceZipper
NOP
J		Return2
NOP

SetDisplay:
;L+DRight
LI		t2, @D_Right
AND		t2, t2, t3
BEQZ	t2, Return2
NOP

;Get Level Text Index
LA      t0, @TinyHelmTSB                 	;t0 = *TinyHelmTSB
LHU     t1, 0x00(t0)                        ;t0 = *t0 (LevelTEXT offset)

SetMap:
;Get Map Index
LA      t0, @TinyIslesTSB                 	;t0 = *TinyIslesTSB
LHU    	t0, 0x00(t0)                        ;t0 = *t0
ADDI	t2, t0, 0x1                         ;t2 = t0 + 1(map offset)

;Wrap around if past Helm
LA		t0, MaxMapIndex
LB		t0, 0(t0)
BEQ		t2, t0, MapReset
NOP

Begin:
LA		at, @KrushaInstrument
LA		a0, LevelText
ADD		a0, a0, t1							;a0 = @LevelText + level_text_offset
LoopToNullChar:
	LB		t0, 0x00(a0)
	BEQZ	t0, SetOffset
	NOP
	ADDI	a0, a0, 0x1
	B		LoopToNullChar
	NOP

SetOffset:
ADDI	a0, a0, 0x1							;move past null char
LA		t1, LevelText
SUB		t1, a0, t1							;put new offset in t1
SW		a0, 0x00(at)
LA      t0, @TinyHelmTSB                 	;t0 = *TinyHelmTSB
SH		t1, 0x00(t0)
LA      t0, @TinyIslesTSB                 	;t0 = *TinyHelmTSB
SH		t2, 0x00(t0)

Return2:
J       0x805FC15C // retroben's hook but up a few functions
NOP

SetInitialPtr:
;t0 = krushaintru
LA		t1, LevelText	;index = leveltext address
ADDI	t1, t1, 0x1		;index++
SW		t1, 0x00(t0)
J		Return2
NOP

;Helper function map reset
MapReset:
LA		t2, MinMapIndex
LB		t2, 0(t2)
LA		t1, MinLevelTextIndex
LB		t1, 0(t1)
J		Begin
NOP

.align
HelloWorldText:
.asciiz "Hello, world!"


;************************************
; ADDITIONAL VARS
;************************************
.align
LevelText:
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
MapCodes:
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
MinLevelTextIndex:
.byte 0

.align
MaxLevelTextIndex:
.byte 0x39

.align
MinMapIndex:
.byte 1
 
.align
MaxMapIndex:
.byte 0xA
