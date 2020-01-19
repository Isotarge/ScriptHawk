;************************************
; Written by GloriousLiar
; 10/2/17
; Template code by Isotarge & MittenzHugg
;************************************
 
;************************************
; CONSTANTS & ADDRESSES
;************************************
[ControllerInput]: 0x80014DC4
[NewlyPressed]: 0x807ECD48
[ZipperBitfield]: 0x807FBB62
 
[L_Button]: 0x0020
[ButtonPressed]: 0x0020
 
[DestinationMap]: 0x807444E4
;(bitfield xxxx321i)
[TinyInstrument]: 0x807FCA6E
 
.org 0x8060B0DC // retroben's hook
J       Start

;************************************
; TakeMeThere FUNCTION
;************************************
.org 0x8000DE88 // In the Expansion Pak pic, TODO: Better place to put this
Start:

;Check if Button is Newly Pressed
;Zipperlock-fix
LH		t0, @NewlyPressed
LI		t1, @ButtonPressed
BNE		t0, t1, Return

;Check for L Input
LH      t0, @ControllerInput
LI      t1, @L_Button
BNE     t0, t1, Return
 
;Set Map
LA      t2, @TinyInstrument                 ;t2 = *TinyInstrument
LB      t0, 0x00(t2)                        ;t0 = *t2
SRA     t1, t0, 0x4                         ;t1 = t0 >> 4 (GET ORIGINAL MAP CODE
ANDI	t1, t1, 0xF							;make sure sign bit is in, and clear other 1s
ADDI	t1, t1, 0x1                         ;t1++ (NEW MAP CODE)
	;***TEST RESET MAP CODE***
	LA		at, TakeMeThere_MaxState
	LB      at, 0x00(at)
	BEQ     t1, at, ResetMapCode
ReturnFromMapReset:
LA		at, @DestinationMap
LA		t2, TakeMeThere_WarpLocations
ADDU	t2, t1, t2
LB		t2, 0x00(t2)
SW      t2, 0x00(at)           				;*DestinationMap = t2 (SET MAP TO NEW MAP FROM OFFSET)
ANDI    t0, t0, 0xF                         ;t0 = t0 & 0xf (GET ORIGINAL TINY MOVES)
SLL     t1, t1, 0x4                         ;t1 = t1 << 4 (NEW MAP CODE ON LEFT)
OR      t0, t0, t1                          ;t0 = t0 | t1 (COMBINE NEW MAP CODE | TINY MOVES)

LA		at, @TinyInstrument
SB      t0, 0x00(at)       					;*TinyInstrument = t0 (TINY MOVES = RESULT)
 
;Force Zipper
LA      at, @ZipperBitfield
LB      t0, 0x00(at)
ORI     t1, t0, 0x01
SB      t1, 0x00(at)
 
;Clean-up
J       Return
NOP
 
;End
Return:
J       0x8060B0E4
NOP
 
;***TEST RESET MAP CODE***
ResetMapCode:
LA		t1, TakeMeThere_MinState
LB		t1, 0x00(t1)
J      	ReturnFromMapReset
NOP
 
;************************************
; ADDITIONAL VARS
;************************************
.align
TakeMeThere_WarpLocations:
.byte 0x00;dummy
.byte 0x07;Japes
.byte 0x26;Aztec
.byte 0x1A;Factory
.byte 0x1E;Galleon
.byte 0x30;Fungi
.byte 0x48;Caves
.byte 0x57;Castle
.byte 0x11;Helm
 
.align
TakeMeThere_MinState:
.byte 1
 
.align
TakeMeThere_MaxState:
.byte 0x9
