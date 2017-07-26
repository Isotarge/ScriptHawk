.align
TakeMeThere_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 TakeMeThereState
BEQ a0 zero NormalModeCode_TakeMeThereEnd
	;convert from option number  to level index

	LI at 0x01
	;Reorder levels
	BEQL a0 at TakeMeThereWorkLoad
	LI a0 0x0B
		LI at 0x08
		BEQL a0 at TakeMeThereWorkLoad
		LI a0 0x0A
			LI at 0x0A
			BEQL a0 at TakeMeThereWorkLoad
			LI a0 0x08
				LI at 0x0D
				BEQL a0 at TakeMeThereWorkLoad
				LI a0 0x0C
					LI at 0x06
					SUB at a0 at
					BLEZL at TakeMeThereWorkLoad
					SUBI a0 a0 1
						LI a1 0x01
						LI at 0x0B
						BEQL a0 at TakeMeThereNotLevel
						LI v0 0x8E
							LI a1 0x0A
							LI at 0x0C
							BEQL a0 at TakeMeThereNotLevel
							LI v0 0x93
	TakeMeThereWorkLoad:
	JAL @GetMainExitFromLevelIndex
	NOP
	JAL @GetMainMapFromLevelIndex
	MOV a1 v0
	TakeMeThereNotLevel:
	LI a2 1
	JAL @TakeMeThere_LevelReset
	MOV a0 v0
	SB zero TakeMeThereState

NormalModeCode_TakeMeThereEnd:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP