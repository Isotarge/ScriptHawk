;************************************
; Template
;************************************

.org 0x805FC164 // retroben's hook but up a few functions
J Start

.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this
Start:
// Run the code we replaced
JAL     0x805FC2B0
NOP

.include "DK64Library.s"

;Check newly pressed
LA		ra,	ReturnFromNewlyPressedCheck
LA		at, CheckNewlyPressed
JR		at
NOP
	.align
	ReturnFromNewlyPressedCheck:
	BEQZ	t1, Return
	NOP

;Check L+DDown
LI		t0, @L_Button
LI		t1, @D_Down
OR		t0, t0, t1
LA		ra, ReturnFromButtonCheck
LA		at, CheckInput
JR		at
NOP
	.align
	ReturnFromButtonCheck:
	BEQZ	t1, Return
	NOP
	
;Force Zipper
LI		t0,	0x22
LI		t1, 0x00
LA		ra, Return
J		ForceZipper
NOP

Return:
J       0x805FC15C // retroben's hook but up a few functions
NOP
