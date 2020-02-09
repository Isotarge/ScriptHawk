;************************************
; Take Me There v2
; GloriousLiar
; 2/9/20
;************************************
.org 	0x805FC164 // retroben's hook but up a few functions
J 		Start2

.org 	0x805fe354 // write over jump to SecuritySomething
JAL		Start

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

MenuMode:
LA		at, @KrushaInstrument
LB		at, 0x0(at)
LI		t0, 0x1
BEQ		at, t0, TakeMeThere
NOP
LI		t0, 0x2
BEQ		at, t0, PositionViewer
NOP
B		Return				;null check
NOP

TakeMeThere:
LI		t9, 0x1					;num of menu text items
;		a0 						;global_display_list
LI		a1, 0xA0				;x = 132
LI		a2, 0x74				;y = 116
LI		a3, 0x3f000000			;scale = 0.5
LA		t0, LevelText
ADDI	t0, t0, 0x1
PrintLoop:
	LI		a1, 0xA0				;x = 132
	LA		t1, @TinyHelmTSB
	LH		t1, 0x0(t1)				;t1 = 
	LA		t2, LevelText
	ADD		t1, t1, t2				;t1 = level_text_offset + @LevelText
	SUB		t3, t0, t2				;t3 = offset from @LevelText
	ADD		t2, t2, t3				;t2 = @LevelText + t3
	BNE		t1, t2, Print			;if t1==t2
	NOP
		LI		a1, 0x100			;x = 0x64 + 0x10
	Print:	
	ADDIU	sp, sp, -0x34	
	SW		t0, 0x10(sp)
	SW		t9, 0x14(sp)
	SW		a1, 0x18(sp)
	SW		a2, 0x22(sp)
	SW		a3, 0x26(sp)
	JAL		0x806abb98				;printText
	NOP
	LW		t0, 0x10(sp)
	LW		t9, 0x14(sp)
	LW		a1, 0x18(sp)
	LW		a2, 0x22(sp)
	LW		a3, 0x26(sp)
	ADDIU	sp, sp, 0x34
	ADDI	a0, v0, 0x0				;update global display list
	FindZero:
		LB		t1, 0x0(t0)
		BEQZ	t1, SetNextParams
		NOP
		ADDIU	t0, 0x1
		B		FindZero
		NOP
	SetNextParams:
	ADDIU	t0, t0, 0x1				;move past nullchar on level text						
	ADDIU	a2, a2, 0x30			;y+=48
	LB		t1, MaxMapIndex
	ADDI	t9, t9, 0x1				;t9++
	BNE		t1, t9, PrintLoop		;if t9 != 0xA, loop
	NOP
	
J 		Return
NOP
	
PositionViewer:
LI		t9, 0x1					;num of menu text items
;		a0 						;global_display_list
LI		a1, 0xA0				;x = 132
LI		a2, 0x74				;y = 116
LI		a3, 0x3f000000			;scale = 0.5
LA		t0, HelloWorldText
PrintLoopPV:
	LI		a1, 0xA0				;x = 132
	ADDIU	sp, sp, -0x34	
	SW		t0, 0x10(sp)
	SW		t9, 0x14(sp)
	SW		a1, 0x18(sp)
	SW		a2, 0x22(sp)
	SW		a3, 0x26(sp)
	JAL		0x806abb98				;printText
	NOP
	LW		t0, 0x10(sp)
	LW		t9, 0x14(sp)
	LW		a1, 0x18(sp)
	LW		a2, 0x22(sp)
	LW		a3, 0x26(sp)
	ADDIU	sp, sp, 0x34
	ADDI	a0, v0, 0x0				;update global display list
	FindZeroPV:
		LB		t1, 0x0(t0)
		BEQZ	t1, SetNextParamsPV
		NOP
		ADDIU	t0, 0x1
		B		FindZeroPV
		NOP
	SetNextParamsPV:
	ADDIU	t0, t0, 0x1				;move past nullchar on level text						
	ADDIU	a2, a2, 0x30			;y+=48
	LB		t1, MaxHelloWorldIndex
	ADDI	t9, t9, 0x1				;t9++
	BNE		t1, t9, PrintLoopPV		;if t9 != 0xA, loop
	NOP	
	
Return:
JAL		0x805fe358
NOP

//start second hook
Start2:

// Run the code we replaced
JAL     0x805FC2B0
NOP

;load min map code and min text offset, if 0
LA		t0, @TinyHelmTSB
LH		t1, 0x00(t0)
BEQZ	t1, SetInitialParams
NOP

;Check newly pressed
LA		t1, @NewlyPressed
LHU		t1, 0x00(t1)
BEQZ	t1, Return2
NOP

;Check LButton
LI		t2, @L_Button
LA		t3, @ControllerInput
LHU		t3, 0x00(t3)
AND		t2, t2, t3
BEQZ	t2, Return2
NOP
;L+DUp
LI		t2, @D_Left
AND		t2, t2, t3
BNEZ	t2, ChangeMenuMode
NOP
;L+DDown
LI		t2, @D_Up
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

ChangeMenuMode:
LA		at, @KrushaInstrument
LB		t0, 0x0(at)
ADDI	t0, t0, 0x1
SB		t0, 0x0(at)				;set menu code
LA		t1, MaxMenuState
LB		t1, 0x0(t1)
BNE		t0, t1, Return2
NOP
LA		t1, MinMenuState
LB		t1, 0x0(t1)
SB		t1, 0x0(at)				;set menu code to min state
J 		Return2
NOP

SetDisplay:
;L+DDown
LI		t2, @D_Down
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
;;;;;;;LA		at, @KrushaInstrument
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
;;;;;;;SW		a0, 0x00(at)
LA      t0, @TinyHelmTSB                 	;t0 = *TinyHelmTSB
SH		t1, 0x00(t0)
LA      t0, @TinyIslesTSB                 	;t0 = *TinyHelmTSB
SH		t2, 0x00(t0)

Return2:
J       0x805FC15C // retroben's hook but up a few functions
NOP

SetInitialParams:
;t0 = krushaintru
LA		t2, @KrushaInstrument	;KrushaInstrument = menu mode {1=takemethere,2=positionviewer}
LI		t1, 0x01
SB		t1, 0x807FCA9F
SB		t1, 0x807FCAA1
SB		t1, 0x0(t2)
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
.asciiz "MENU 2"
.asciiz "TEXT 1"
.asciiz "TEXT 2"

.align
MaxHelloWorldIndex:
.byte 0x4


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

.align
MaxMenuState:
.byte 0x3

.align
MinMenuState:
.byte 0x1
