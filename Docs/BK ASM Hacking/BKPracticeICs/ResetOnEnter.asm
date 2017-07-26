.align

;-------------------------------
; Pause Mode Code
;-------------------------------

;-------------------------------
; Normal Mode Code
;-------------------------------

ResetOnEnter_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 ResetOnEnterState
BEQ a0 zero NormalModeCode_ResetOnEnter
LB a2 @MapLoadState
	BEQ a2 zero NormalModeCode_ResetOnEnter
	NOP
		LB a0 @Map
		JAL @GetLevelAssociatedWithMap
		MOV a1 a0
		JAL @GetMainMapFromLevelIndex
		MOV a0 v0
		BNE a1 v0 NormalModeCode_ResetOnEnter
			NOP
			JAL @GetMainExitFromLevelIndex
			NOP
			LB a1 @Exit
			BNE a1 v0 NormalModeCode_ResetOnEnter
			NOP
				LI at 0x06 ;Entering Lair
				BEQ a0 at NormalModeCode_ResetOnEnter
				NOP
					;@ClearAllGameProgress clears everything below AND note scores, item counts, and moves
					JAL @ClearGameProgressFlags
					NOP
					JAL @LockAllMoves
					NOP
					JAL @ClearInGameLevelTimer
					NOP
					JAL @ZeroJiggyCollectedBitfield
					NOP
					JAL @ClearEmptyHoneyCombsCollectedBitfield
					NOP
					JAL @ClearCollectedMumboTokenFlags
					NOP
					JAL @ClearSomeProgressThing
					NOP
					LI at 0x05
					LA a0 @ItemBase
					SW at 0x54(a0)
					SW zero 0x4C(a0)
				
				LB a0 @Map
				JAL @GetLevelAssociatedWithMap
				NOP
				MOV a0 v0
				LI a1 0x0B ;Entering SM
				BEQ a0 a1 NormalModeCode_ResetOnEnter
				NOP
				
					LI at 0x06
					BLT a0 at NormalModeCode_ResetOnEnter_NoAdjust
					NOP
						ADDIU a0 a0 -1
					NormalModeCode_ResetOnEnter_NoAdjust:
					ADDIU a0 a0 -1
					
					SW a0 0x10(sp)
					
					LB a2 ResetOnEnterState ;get base address based on category
					ADDIU a2 a2 -1
					SLL a2 a2 2
					LW a1 ResetPointers(a2)

					LW at 0x10(sp)
					
					;SET MOVES
					;a0 = free, a1 = baseadress, a2 = working reg, at = level
					MOV a2 at
					SLL a2 a2 2
					ADDU a2 a2 a1
					LW a0 0(a2)
					
					JAL @SetMovesUnlockedBitfield
					NOP
					JAL @SetHasUsedMovesBitfield
					NOP
					
					LW at 0x10(sp)
					
					;SET GAME PROGRESS FLAGS
					MOV a2 at
					SLL a2 a2 5
					ADDU a2 a2 a1
					ADDIU a2 a2 0x24

					ADDIU at a2 0x20
					LA a1 @GameProgressBitfield

					SetGameProgressBitfieldLoop: 
						LW a0 0(a2)
						SW a0 0(a1)
						ADDIU a2 0x04
						ADDIU a1 0x04
						BNE at a2 SetGameProgressBitfieldLoop
						NOP
					
					LB a0 ResetOnEnterState
					LI a1 0x01
					BNE a0 a1 NormalModeCode_ResetOnEnter
						LW a2 0x10(sp)
						LA a0 Reset_100HoneyCombs
						SLL a2 a2 2
						ADDU a2 a2 a0
						LW a0 0(a2)
						LA a1 @EmptyHoneycombBitfield
						SW a0 0(a1)
					
						
NormalModeCode_ResetOnEnter:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP



;--------------------------------
; Variables
;--------------------------------
ResetPointers:
.word Reset_100
.word Reset_Any
.word Reset_NoRBA

Reset_100:
;MM, TTC, CC, BGS, FP, GV, CCW, RBB, MMM
.word 0x000BFDBF ;MM ;MOVES
.word 0x000BFDFF ;TTC
.word 0x000BFFFF ;CC
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF

;+0x24
.word 0x0008C000;MM ; GAME PROGRESS
.word 0x00010200
.word 0x00000020
.word 0x00000000
.word 0x00008000
.word 0x80000020
.word 0x00000008
.word 0x00000000
.word 0x384DC001;TTC
.word 0x00070E04
.word 0x000000B0
.word 0x05000000
.word 0x00008003
.word 0x80000120
.word 0x0000D088
.word 0x01000000
.word 0x786FC085;CC
.word 0x01070E04
.word 0x002000B0
.word 0x05000000
.word 0x00008003
.word 0x80010520
.word 0x0200D088
.word 0x01000004
.word 0xF8FFC0C5;BGS 
.word 0x031F3E0C
.word 0x002000B0
.word 0x3D020000
.word 0x0000800F
.word 0x80010521
.word 0x0200D088
.word 0x01000004
.word 0xF8FFE7EF;FP
.word 0x0F7FFE7C
.word 0x002600B0
.word 0x3DA60200
.word 0x18868AFF
.word 0xA2018F29
.word 0xC206D098
.word 0x0100A007
.word 0xF8FFC7CD;GV
.word 0x033F7E3C
.word 0x002000B0
.word 0x3D260000
.word 0x1800888F
.word 0x82010729
.word 0xC202D098
.word 0x01000004
.word 0xF8FFFFFF;CCW
.word 0x3FFFFFFF
.word 0x006618B0
.word 0x3DA6F203
.word 0x1C868EFF
.word 0xA21BDF29
.word 0xF60ED098
.word 0x0100A007
.word 0xF8FFFFEF;RBB
.word 0x3FFFFE7D
.word 0x002600B0
.word 0x3DA63200
.word 0x1C868EFF
.word 0xA201CF29
.word 0xF60ED098
.word 0x0100A007
.word 0xF8FFC7CD;MMM
.word 0x037FFE7C
.word 0x002400B0
.word 0x3DA60200
.word 0x1880888F
.word 0xA2010F29
.word 0xC206D098
.word 0x01000007


Reset_Any:
.word 0x000BFDFF ;moves
.word 0x000BFDFF
.word 0x000BFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF

.word 0x0000C000 ;MM ; GAME PROGRESS
.word 0x00010200
.word 0x00000020
.word 0x00000000
.word 0x00008000
.word 0x80000020
.word 0x00000008
.word 0x00000000
.word 0x3845C000 ;TTC
.word 0x00070E04
.word 0x000000B0
.word 0x05000000
.word 0x00008003
.word 0x80000120
.word 0x0000588B
.word 0x01000000
.word 0x7867C084 ;CC
.word 0x01070E04
.word 0x002000B0
.word 0x05000000
.word 0x00008003
.word 0x80010520
.word 0x0200588B
.word 0x01000000
.word 0xF877F6A4;BGS
.word 0x3D478F7E
.word 0x006618B0
.word 0x0580C203
.word 0x50B8927F
.word 0xA005FD21
.word 0x222C589B
.word 0x01002000
.word 0xF877C084;FP
.word 0x01070E1C
.word 0x002000B0
.word 0x05000000
.word 0x0000800F
.word 0x80010521
.word 0x0208588B
.word 0x01000000
.word 0xF877F6A4;GV
.word 0x3D478F7E
.word 0x006618B0
.word 0x0580C203
.word 0x40B8927F
.word 0xA005F521
.word 0x222C589B
.word 0x01002000
.word 0xF877F6A4;CCW
.word 0x3D478F7E
.word 0x006618B0
.word 0x0580C203
.word 0x4080827F
.word 0xA001C521
.word 0x222C589B
.word 0x01002000
.word 0xF877F6A4;RBB
.word 0x3D478F7E
.word 0x006618B0
.word 0x0580C203
.word 0x40B8927F
.word 0xA005E521
.word 0x222C589B
.word 0x01002000
.word 0xF877D084;MMM
.word 0x01478E3C
.word 0x002400B0
.word 0x05800200
.word 0x0000800F
.word 0xA0014521
.word 0x020C588B
.word 0x01000000



Reset_NoRBA:
.word 0x000BFDBF ;moves
.word 0x000BFDFF
.word 0x000BFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF
.word 0x000FFFFF

.word 0x0000C000;MM ;GAME PROGRESS
.word 0x00010200
.word 0x00000020
.word 0x00000000
.word 0x00008000
.word 0x80000020
.word 0x00000008
.word 0x00000000
.word 0x3841C001;TTC
.word 0x00070E04
.word 0x000000B0
.word 0x05000000
.word 0x00008003
.word 0x80000120
.word 0x02002089
.word 0x01000000
.word 0x7867C085;CC
.word 0x01070E04
.word 0x002000B0
.word 0x05000000
.word 0x00008003
.word 0x80010520
.word 0x02002089
.word 0x01000000
.word 0xF8F7C0C5;BGS
.word 0x030F1E0C
.word 0x002000B0
.word 0x3D000000
.word 0x0000800F
.word 0x80010521
.word 0x02002089
.word 0x01000000
.word 0xF8F7C0CD;FP
.word 0x030F1E1C
.word 0x002000B0
.word 0x3D000000
.word 0x0000808F
.word 0x82010721
.word 0xC20A2089
.word 0x01000000
.word 0xF8F7F7ED;GV
.word 0x0F6FDE7C
.word 0x002600B0
.word 0x3DA40200
.word 0x408682FF
.word 0xA201C721
.word 0xC20E2099
.word 0x01002000
.word 0xF8F7F7ED;CCW
.word 0x3FEFDFFF
.word 0x006618B0
.word 0x3DA4F203
.word 0x408682FF
.word 0xA209DF21
.word 0xE60E2099
.word 0x01002000
.word 0xF8F7F7ED;RBB
.word 0x3FEFDE7D
.word 0x002600B0
.word 0x3DA43200
.word 0x408682FF
.word 0xA201CF21
.word 0xE60E2099
.word 0x01002000
.word 0xF8F7D0CD;MMM
.word 0x036FDE7C
.word 0x002400B0
.word 0x3DA40200
.word 0x0000808F
.word 0xA2014721
.word 0xC20E2089
.word 0x01000000

Reset_100HoneyCombs:
.word 0x0000FC00 ;moves
.word 0x0300FC00
.word 0x0F00FC00
.word 0x3F00FC00
.word 0xFF0CFF00
.word 0xFF00FC00
.word 0xFFCFFF00
.word 0xFF0FFF00
.word 0xFF0CFC00