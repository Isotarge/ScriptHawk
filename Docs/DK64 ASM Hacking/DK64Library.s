;************************************
; DK64 Library
;************************************

;************************************
; ENUMS
;************************************
;Buttons [0x80014DC4]
[L_Button]: 0x0020
[D_Up]: 0x0800		;check this
[D_Down]: 0x0400
[D_Left]: 0x0200
[D_Right]: 0x0100

;relative to KongObjectPointer
[CurrentCharacter]: 0x36F

;relative to ActionObjectPointer
[ActionObjectOffset]: 0x29C


;************************************
; ADDRESSES
;************************************
[DestinationMap]: 0x807444E4
[DestinationEntrance]: 0x807444E8

[SecurityText]: 0x8075E5DC
[SecurityByte]: 0x807552E0
[ControllerInput]: 0x80014DC4

[ZipperBitfield]: 0x807FBB62

[NewlyPressed]: 0x807ECD48
[ButtonHeld]: 0x807ECD58

[TinyHelmTSB]: 0x807FCAA0		;Tiny Helm T&S Bananas
[TinyIslesTSB]: 0x807FCA9E		;Tiny Isles T&S Bananas
[KrushaInstrument]:0x80744718
[KrushaJapesTSB]:0x807FCB30
[KrushaAztecTSB]:0x807FCB32
[KrushaFactoryTSB]:0x807FCB34
[KrushaGalleonTSB]:0x807FCB36
[KrushaForestTSB]:0x807FCB38
[KrushaCavesTSB]:0x807FCB3A
[KrushaCastleTSB]:0x807FCB3C
[KrushaIslesTSB]:0x807FCB3E
[KrushaHelmTSB]:0x807FCB40

[HUDPointer]: 0x80754280
[KongObjectPointer]: 0x807FBB4C
[ActionObjectPointer]: 0x807FC924
[InCutscene]: 0x807444EC

[DKModel]:0x8075C41A
[DiddyModel]:0x8075C42A
[TinyModel]:0x8075C44A
[LankyModel]:0x8075C43A
[ChunkyModel]:0x8075C45A
[KrushaModel]:0x8075C46A
[RambiModel]:0x8075C47A
[EnguardeModel]:0x8075C48A

;************************************
; CUSTOM CODE
;************************************
LA		at, EndOfFile
JR		at
;************************************
; SetSecurityByte
; ra -> (int*) return_address
; return -> void
;************************************
SetSecurityByte:
LI      t0, 1
SB      t0, @SecurityByte
JR		ra

;************************************
; ForceZipper
; t0 -> (byte) destination_map
; t1 -> (byte) destination_entrance
; ra -> (int*) return_address
; return -> void
;************************************
ForceZipper:
LA		at, @DestinationMap
SW      t0, 0x00(at)

LA		at, @DestinationEntrance
SW		t1, 0x00(at)

LA      t3, @ZipperBitfield
LB      at, 0x00(t3)
ORI     t2, at, 0x01
SB      t2, 0x00(t3)
JR		ra
NOP

;************************************
; CheckInput
; t0 -> (short) desired_input
; ra -> (int*) return_address
; return -> (boolean) t1 -> input_matched
;************************************
;
;TODO: put registers on the stack
;
CheckInput:
LH      t1, @ControllerInput
BEQ		t1, t0, ReturnFromCheckInput
NOP
LI		t1, 0x0
ReturnFromCheckInput:
JR		ra

;************************************
; CheckNewlyPressed
; ra -> (int*) return_address
; return -> (boolean) t1 -> newly_pressed
;************************************
CheckNewlyPressed:
LI		t1, @NewlyPressed
LW		t1, 0x0(t1)
JR		ra

;************************************
; PrintToSecurityByte
; 
; ra -> (int*) return_address
; return ->
;************************************
;TODO

;************************************
; Change Model
; t0 -> (byte) kong
; t1 -> (byte) model
; t2 -> (byte) behavior
; ra -> (int*) return_address
; return -> void
;************************************
ChangeModel:
LA		at, @KongObjectPointer
LW		at, 0x00(at)
ADDI	at, at, 0x36F				;offset to actor_type
SH		t0, 0x00(at)

;KongModel = DKModel + (KongIndex -2)*0x10
LA		at, @DKModel		
ADDI	t0, t0, -0x2
LI		t3, 0x10
MULT	t0, t3
MFLO	t0
ADD		t0, at, t0
SH		t1, 0x00(t0)				;t0 holds KongModel

;KongBehavior = KongModel - 0x8
ADDI	t0, t0, -0x8
SH		t2, 0x00(t0)				;t0 holds KongBehavior

JR		ra
NOP

;************************************
; Force Action
; t0 -> (byte) action
; ra -> (int*) return_address
; return -> void
;************************************
ForceAction:
LA		at, @ActionObjectPointer
LW		at, 0x00(at)
ADDI	at, at, 0x29c				;offset action object by 0x29c
SH		t0, 0x00(at)
JR		ra
NOP

;************************************
; PrintMyText
; t0 -> (str*) str_ptr
; a0 -> (float**) global_display_list
; a1 -> (int) x
; a2 -> (int) y
; a3 -> (float) scale
; return -> (float**) v0 -> updated_global_display_list
; 		 -> (str*) t0    -> next_menu_string
;************************************
PrintMyText:
ADDIU	sp, sp, -0x30	
SW		t0, 0x10(sp)
SW		t9, 0x14(sp)
SW		a1, 0x18(sp)
SW		a2, 0x1C(sp)
SW		a3, 0x20(sp)
SW		ra, 0x24(sp)
JAL		0x806abb98				;printText
NOP
LW		t0, 0x10(sp)
LW		t9, 0x14(sp)
LW		a1, 0x18(sp)
LW		a2, 0x1C(sp)
LW		a3, 0x20(sp)
LW		ra, 0x24(sp)
ADDIU	sp, sp, 0x30

FindZeroLoop:
LB		t1, 0x0(t0)
BEQZ	t1, ZeroFound
NOP
ADDIU	t0, 0x1
B		FindZeroLoop
NOP

ZeroFound:
ADDIU	t0, t0, 0x1				;move past null char
JR		ra
NOP

EndOfFile:
NOP
