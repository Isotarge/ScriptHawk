.align
Infinites_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 InfinitesState
BEQ a0 zero NormalModeCode_InfinitesNormal
NOP
	LI a1 @ItemBase
	LI a0 100
	SW a0 0x34(a1) ;Eggs
	;SW a0 0x98(a1) ;Jiggies
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

NormalModeCode_InfinitesNormal:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP