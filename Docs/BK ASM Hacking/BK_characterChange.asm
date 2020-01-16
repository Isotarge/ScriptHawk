// MODEL AND SCALE
;BanjoModelScale
.org 0x80298708
JAL updateBanjoWrapper1

.org 0x80291D0C
JAL updateBanjoWrapper1


// ANIMATION CATCH
;animationCatcher
.org 0x8028745C
J animCatch
NOP


/*
;disable model flip
.org 0x802920F8
NOP
*/

//ENUMERATIONS
.include "Docs/BK ASM Hacking/BK_Enum.S"
//EXISTING FUNCTIONS
.include "Docs/BK ASM Hacking/BK_NTSC.S"

[getMumboTransformation]: 0x8029A8F4
[getMumboTransformationModel]: 0x802985F0
[playerModelScale]:0x8037C0EC
[updateBanjoModel]:0x80298700
[setPlayerModel]:0x80291FC4
;----------------------------------------------------------------
; Code Run from Pause Mode
;----------------------------------------------------------------
.org 0x80500000

;----------------------------------------------------------------
;Scale Function
;----------------------------------------------------------------
updateBanjoWrapper1:
ADDIU sp -0x18
SW ra 0x14(sp)
SW at 0x10(sp)
SW a0 0x0C(sp)

JAL modelScaleFunc
NOP
BNEZ v0 updateBanjoWrapper1_housekeeping
LW a0 0x0C(sp)
JAL @getMumboTransformationModel
NOP

updateBanjoWrapper1_housekeeping:
LW a0 0x0C(sp)
LW at 0x10(sp)
LW ra 0x14(sp)
ADDIU sp 0x18
JR
NOP


;----------------------------------------------------------------
;Scale Function
;----------------------------------------------------------------
modelScaleFunc:
ADDIU sp -0x18
SW ra 0x14(sp)
SW at 0x10(sp)
SW a0 0x0C(sp)

JAL @getMumboTransformation
NOP

//SCALE
LA a0 size_replace
SLL v0 v0 2
ADDU a0 v0 a0
LW a0 0(a0)
BEQZL a0 modelScaleFunc_houseKeeping
LUI a0 0x3F80 //1.0f


modelScaleFunc_houseKeeping:
LI at @playerModelScale
SW a0 0(at)


modelScaleFunc_houseKeeping:
LI at @playerModelScale
SW a0 0(at)


//MODEL INDEX
LA a0 model_replace
ADDU a0 v0 a0
LW v0 0(a0)

LW a0 0x0C(sp)
LW at 0x10(sp)
LW ra 0x14(sp)
ADDIU sp 0x18
JR
NOP


;----------------------------------------------------------------
;Animation Catcher
;----------------------------------------------------------------
animCatch:
ADDIU sp -0x18
SW ra 0x14(sp)
SW a1 0x10(sp)
SW a0 0x0C(sp)

LA a0 animation_replace
SLL a1 a1 2
LW a1 a1(a0);get ROM Index difference
BNE a1 zero animCatch_HouseKeeping
NOP
LW a1 0x10(sp)


animCatch_HouseKeeping:
LW a0 0x0C(sp)
LW ra 0x14(sp)
ADDIU sp 0x18
SW a1 0x1C(a0)
JR
NOP


;----------------------------------------------------------------
; Menu Variables
; BitFlags
;----------------------------------------------------------------
.org 0x80501000
model_replace:
.word 0x00;
.word 0x3CA;


.org 0x80501020
size_replace:
.word 0x00;


.org 0x80501040
animation_replace:
.word 0x0000