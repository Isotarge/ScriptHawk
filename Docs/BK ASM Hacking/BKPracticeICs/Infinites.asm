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
Infinites_DefStruct:
Infinites_State:
.byte 0
Infinites_MaxState:
.byte 2

.align
Infinites_MenuOptionString:
.word OnOffOptionString
Infinites_PauseModePtr: 
.word 0
Infinites_NormalModePtr: 
.word Infinites_NormalMode
Infinites_Label: 
.asciiz "INFINITES: \0\0\0\0"

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
Infinites_PauseMode:
;YOUR PAUSE MODE CODE HERE


;-------------------------------
; Normal Mode Code
;-------------------------------
.align
Infinites_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LI a1 @ItemBase
LI a0 100
SW a0 0x34(a1) ;Eggs

LI a0 50
SW a0 0x3C(a1) ;Reds
LI a0 10
SW a0 0x40(a1) ;Golds
    
LW a0 0x54(a1) ;HealthContainers
SW a0 0x50(a1) ;Health
    
LI a0 9
SW a0 0x58(a1) ;Lives
LI a0 0xE10
SW a0 0x5C(a1) ;Air
LI a0 99
SW a0 0x70(a1) ;MumboTokens_OnHand
SW a0 0x94(a1) ;MumboTokens
SW a0 0x9C(a1) ;JokerCards

;TODO: Set all world jiggies to 10?
;TODO: Set all world notes to 10?


Infinites_Normal_HouseKeeping:
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP