[myBKModel]: 0x035B
[myBKIdle]: 0x01D0
[myBKIdle2]: 0x01D5
[myBKMoving]: 0x0093

// HOOKS
;BanjoModelScale
.org 0x80334BD0
JAL updateBanjoWrapper1

.org 0x80291D14
JAL updateBanjoWrapper2


;animationCatcher
.org 0x8028745C
J animCatch
NOP




;model replace
.org 0x802986B0
LI v0 @myBKModel
.org 0x802986B8
LI v0 @myBKModel
LI v0 @myBKModel


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

JAL @updateBanjoModel
NOP

JAL modelScaleFunc

NOP
LW a0 0x0C(sp)
LW at 0x10(sp)
LW ra 0x14(sp)
ADDIU sp 0x18
JR
NOP

;----------------------------------------------------------------
;Scale Function
;----------------------------------------------------------------
updateBanjoWrapper2:
ADDIU sp -0x18
SW ra 0x14(sp)
SW at 0x10(sp)
SW a0 0x0C(sp)

JAL modelScaleFunc
NOP

LW a0 0x0C(sp)

JAL @setPlayerModel
NOP



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

;banjo
LI at 0x01
BEQL v0 at modelScaleFunc_houseKeeping
LUI a0 0x3f34 //0.199219

;termite
//LI at 0x02
//BEQL v0 at modelScaleFunc_houseKeeping
//LUI a0 0x3F80

;pumpkin
//LI at 0x03
//BEQL v0 at modelScaleFunc_houseKeeping
//LUI a0 0x3F80

;walrus
//LI at 0x04
//BEQL v0 at modelScaleFunc_houseKeeping
//LUI a0 0x3F80

;croc
//LI at 0x05
//BEQL v0 at modelScaleFunc_houseKeeping
//LUI a0 0x3F80

;bee
//LI at 0x06
//BEQL v0 at modelScaleFunc_houseKeeping
//LUI a0 0x3F80

;default
LUI a0 0x3F80

modelScaleFunc_houseKeeping:
LI at @playerModelScale
SW a0 0(at)

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
SLL a1 a1 1
LH a1 a1(a0);get ROM Index difference
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
animation_replace:
.half 0x0000
.half 0x0000
.half @myBKMoving
.half @myBKMoving

.org 0x80501018
.half @myBKMoving


.org 0x805010DE
.half @myBKIdle

.org 0x8050112A
.half @myBKIdle2
