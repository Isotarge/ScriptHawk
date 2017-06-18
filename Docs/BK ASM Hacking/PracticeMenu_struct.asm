//Banjo-Kazooie Speedrunning Cheat Menu
//Enter Main Menu by pressing start, then press D-left to switch to practice menu
//  Press D-Right to return to main menu
//
//
// TO DO: Update Progress flags on reset
//        Save State Code
//        Map ghosts
//

//Variables
[NumberOfOptions]: 0x07
[PageTopMax]: 0x03
;----------------------------------------------------------------
; Code Run from Pause Mode
;----------------------------------------------------------------

.org 0x80400000
.include "Docs/BK ASM Hacking/PracticeMenu_GUI.asm"

;----------------------------------------------------------------
; Upon Exiting Practice Menu
;
;----------------------------------------------------------------
.align
ExitingMenuCode: ;DO NOT CHANGE THIS NAME

	//your exiting menu code here
	LB s3 MoveSet
	BEQZ s3 KeepCurrentMoveSet
	LI a1 0x01
		//NONE
		MOV a0 zero
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a1 0x02

		//SM Set
		LI a0 0x00009DB9
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a1 0x03

		//FFM
		LI a0 0x000BFDBF
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a1 0x04

		//FFM + EGGS
		BEQ s3 a1 DoNotKeepCurrentMoveSet
		LI a0 0x000BFDFF

		//ALL
		LI a0 0x000FFFFF

	DoNotKeepCurrentMoveSet:
		JAL @SetMovesUnlockedBitfield
		NOP
		JAL @SetHasUsedMovesBitfield
		NOP

	KeepCurrentMoveSet:
	SB zero MoveSet

	LB s3 GhostState
	BNE s3 zero KeepCurrentGhostActive
	LW a1 GhostObjectPointer
		BEQ a1 zero KeepCurrentGhostActive
		NOP
			LB a2 0x47(a1)
			ORI a2 a2 0x08
			SB a2 0x47(a1)
			SW zero GhostCurrentFrame

	KeepCurrentGhostActive:
	JR	;IMPORTANT
	NOP :IMPORTANT

;----------------------------------------------------------------
; Code Run from Normal Mode
;
;----------------------------------------------------------------
NormalModeCode: ;DO NOT CHANGE THIS NAME
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

//cheatMenuNotSetUp
LB a0 PracMenuSetup
BEQ a0 zero NormalModeCode_MenuSetup
NOP
	JAL BetaPauseMenu
	NOP
	MOV a0 zero
NormalModeCode_MenuSetup:

//Take Me There
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


//Transform Me
LB a0 TransformMeState
BEQ a0 zero NormalModeCode_TransformMeEnd

	LUI a1 0x07
	BNE a0 a1 TransformMe_notWishyWashy
	LUI a1 0x01
	JAL @SetCheatFlag
	LUI a0 0x9D 
	LUI a0 0x01
	
	TransformMe_notWishyWashy:
	LB a0 TransformMeState
	JAL @TransformMe
	NOP
	SB zero TransformMeState

NormalModeCode_TransformMeEnd:



//Press-L to Levitate
LB a0 L2LevitateState
BEQ a0 zero NormalModeCode_LToLevitateNormal
NOP
	JAL @GetButtonPressTimer
	LI a0 0x02 ;L button Index
	BEQ v0 zero NormalModeCode_LToLevitateNormal
	LUI a0 0x4220
		MTC1 zero f12
		JAl @SetYVelocity ;Vel increases while airborn, if Vel > pos change then banjo still falls
		LUI a0 0x41a0
		MTC1 a0 f12
		JAl @AddToYPos
		NOP
NormalModeCode_LToLevitateNormal:


//Ingame-Timer
;If Ingame-Timer/AutoSplitter
	;JAL Ingame-Timer
	NOP



//Infinites
LB a0 InfinitesState
BEQ a0 zero NormalModeCode_InfinitesNormal
NOP
	LI a1 @ItemBase
	LI a0 100
	SW a0 0x34(a1) ;Eggs
	SW a0 0x98(a1) ;Jiggies
	LI a0 50
	SW a0 0x3C(a1) ;Reds
	LI a0 50
	SW a0 0x40(a1) ;Golds
	LI a0 5
	SW a0 0x50(a1) ;Health
	LI a0 9
	SW a0 0x58(a1) ;Lives
	LI a0 0xE10
	SW a0 0x5C(a1) ;Air
	LI a0 99
	SW a0 0x70(a1) ;MumboTokens_OnHand
	SW a0 0x94(a1) ;MumboTokens
	SW a0 0x9C(a1) ;JokerCards

NormalModeCode_InfinitesNormal:


//ResetUponEnter
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

//Map Ghost
LB a0 GhostState
BEQ a0 zero NormalModeCode_MapGhosts
LB a0 @MapLoadState
	BEQ a0 zero NormalModeCode_MapGhosts_NotInLZ
	NOP
		LB a1 PreviousLoadzoneState
	    BEQ a1 a0 NormalModeCode_MapGhosts_InLZ_NoTransition //just left Entered
		NOP
			SB a0 PreviousLoadzoneState
			LW a0 GhostRecordPointer
			LW a1 GhostCurrentFrame
			BEQ a0 zero Ghost_InLZ_Transition_End
			NOP	
				SW a1 0x04(a0)
				SW zero GhostCurrentFrame
				ADDIU a1 0x01
				SLL a1 a1 0x02
				SLL a2 a1 0x01
				ADDU a1 a1 a2
				ADDU a1 a1 a0
				ADDIU a1 a1 0x10
				SW a1 0x08(a0)
				SW a0 0x0C(a1)
				SW a1 GhostCurrentTailPointer
				
				LW a0 GhostCurrentPlaybackPointer
				BEQ a0 zero Ghost_InLZ_Transition_End
				NOP
					LW a1 0x08(a0) ;Remove old ghost from list
					LW a2 0x0C(a0)
					SW a2 0x0C(a1)
					
					//Defragment data
					LW at GhostCurrentTailPointer
					
					Ghost_Defragment_Loop:
					LW a2 0x00(a1)
					SW a2 0x00(a0)
					ADDIU a1 a1 0x04
					ADDIU a0 a0 0x04
					BLT a1 at Ghost_Defragment_Loop
					NOP
					
					SW a1 GhostCurrentTailPointer
					
				
			Ghost_InLZ_Transition_End:
			SW zero GhostRecordPointer
			SW zero GhostCurrentPlaybackPointer
			SW zero GhostCurrentFrame
			
			B NormalModeCode_MapGhosts
			NOP
		
		NormalModeCode_MapGhosts_InLZ_NoTransition:
		SB a0 PreviousLoadzoneState
		LW a1 GhostCurrentFrame
		ADDIU a1 a1 0x01
		SW a1 GhostCurrentFrame
		
		LW a0 GhostCurrentFrame
		LI a1 0x10
		BGE a0 a1 Ghost_Despawned
		NOP
			LW a1 GhostObjectPointer
			BEQ a1 zero NormalModeCode_MapGhosts
			NOP
				LB a2 0x47(a1)
				ORI a2 a2 0x08
				SB a2 0x47(a1)
				SW zero GhostCurrentFrame
				B NormalModeCode_MapGhosts
				NOP
			
		Ghost_Despawned:
			SW zero GhostObjectPointer
			B NormalModeCode_MapGhosts
			NOP
		
	NormalModeCode_MapGhosts_NotInLZ:
		LB a1 PreviousLoadzoneState
	    BEQ a0 a1 NormalModeCode_MapGhosts_NotInLZ_NoTransition //just left loadzone
		NOP
			SB a0 PreviousLoadzoneState
			//set Address of currentGhost
			
			//check if current map has ghost
			LA a0 GhostArray
			GhostFindGhostPlayback:
			LW a1 GhostCurrentTailPointer
			BEQ a0 a1 GhostPlaybackSet
			NOP
			
			LB a1 @Map
			LH a2 0(a0)
			BNEL a1 a2 GhostFindGhostPlayback
			LW a0 0x08(a0)
			
			LB a1 @Exit
			LH a2 2(a0)
			BNEL a1 a2 GhostFindGhostPlayback
			LW a0 0x08(a0)
			
			SW a0 GhostCurrentPlaybackPointer
			
			;set record Position
			//if ghost exists for map/exit
			
				;set ghost playback		
	
				MOV a2 zero ;spawn ghost
				ADDIU a1 a0 0x10
				JAL @SpawnActor 
				LI a0 0xCA
			
				SW v0 GhostObjectPointer
				LW v0 @ObjectArrayPointer
				SW v0 GhostPrevObjectArray
			
				//set ghost opacity
			
			
				//set ghost scale
				
			GhostPlaybackSet:
			LW a0 GhostCurrentTailPointer
			SW a0 GhostRecordPointer
			LB a1 @Map 
			SH a1 0(a0)
			LB a1 @Exit 
			SH a1 0x02(a0)
			
			SW zero GhostCurrentFrame
			//currentFrame = 0
			
			ADDIU a0 a0 0x10
			JAL @CopyXYZPosition
			NOP
			
			B NormalModeCode_MapGhosts
			NOP
			
		NormalModeCode_MapGhosts_NotInLZ_NoTransition: 
			
			SB a0 PreviousLoadzoneState
			
			LW a0 GhostCurrentFrame
			ADDIU a0 a0 0x01
			SW a0 GhostCurrentFrame
			
			;If playback ghost found
			LW a0 GhostCurrentPlaybackPointer
			BEQ a0 zero GhostPlaybackNotSet
			NOP
			
				;IF GHOST NEEDS TO BE DESPAWNED
				LW a0 GhostCurrentFrame
				LW a1 GhostCurrentPlaybackPointer
				LW a1 0x04(a1)
				BLE a0 a1 RecordNotBehindGhost
				NOP
				
					SW zero GhostCurrentPlaybackPointer
					SW zero GhostRecordPointer
				
					LW a1 GhostObjectPointer ;Set Despawn Bit
					BEQ a1 zero NormalModeCode_MapGhosts
						NOP
						LB a2 0x47(a1)
						ORI a2 a2 0x08
						SB a2 0x47(a1)
						SW zero GhostObjectPointer
						B GhostStopRecording
						NOP
				//ELSE
				RecordNotBehindGhost:
					
				LW a0 GhostCurrentFrame
				LI a1 0x02
				BGE a0 a1 Ghost_Collision_Off
				NOP
					LW v0 GhostObjectPointer
					BEQ v0 zero  NormalModeCode_MapGhosts
					NOP
						LW a1 0(v0) ;turn off ghost collision
						SB zero 0x2F(a1)
						LW a0 0(v0)
						JAL @GetBehaviorStruct_ObjectStructOffset
						NOP
						SW v0 GhostObjectPointer
						LW v0 @ObjectArrayPointer
						SW v0 GhostPrevObjectArray
	
				Ghost_Collision_Off:
					LW a0 @ObjectArrayPointer
					LW a1 GhostPrevObjectArray ;if object array changed
					BEQ a0 a1 Ghost_No_ObjectArrayMove
					NOP
						SW a0 GhostPrevObjectArray
						SUBU a0 a0 a1
						LW a1 GhostObjectPointer
						ADDU a0 a0 a1
						SW a0 GhostObjectPointer
				
					Ghost_No_ObjectArrayMove:
					LW v0 GhostObjectPointer
					BEQ v0 zero  NormalModeCode_MapGhosts
					NOP
						LW a0 0(v0)
						JAL @GetBehaviorStruct_ObjectStructOffset
						NOP
						SW v0 GhostObjectPointer
						
				;UPDATE GHOST POSITION
				LW a0 GhostCurrentFrame
				LW a1 GhostCurrentPlaybackPointer
				ADDIU a1 a1 0x10
				SLL a0 a0 0x02
				SLL a2 a0 0x01
				ADDU a0 a0 a2
				ADDU a1 a1 a0
				LW a2 GhostObjectPointer
				ADDIU a0 a2 0x04
				JAL @CopyXYZData
				NOP
			
			GhostPlaybackNotSet:
			;RECORD FRAME
			LW a1 GhostRecordPointer
			BEQ a1 zero GhostStopRecording
			NOP
				LW a0 GhostCurrentFrame
				ADDIU a1 a1 0x10
				SLL a0 a0 0x02
				SLL a2 a0 0x01
				ADDU a0 a0 a2
				ADDU a0 a1 a0
				JAL @CopyXYZPosition
				NOP
				
			GhostStopRecording:

NormalModeCode_MapGhosts:
		
	
NormalModeCode_Housekeeping:	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP

;----------------------------------------------------------------
; Menu Variables
; BitFlags
;----------------------------------------------------------------
MenuOptionStates: ;DO NOT CHANGE THIS NAME
InfinitesState:
.byte 0
ResetOnEnterState:
.byte 0
TakeMeThereState:
.byte 0
MoveSet:
.byte 0
L2LevitateState:
.byte 0
TransformMeState:
.byte 0
GhostState:
.byte 0

.align
MenuItemStr: ;DO NOT CHANGE THIS NAME
.asciiz "PRACTICE MENU 1: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 2: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 3: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "PRACTICE MENU 4: \0\0\0\0\0\0\0\0\0\0\0\0\0\0"

.align
MenuLabelStrings: ;DO NOT CHANGE THIS NAME
.asciiz "INFINITES: \0\0\0\0"
.asciiz "RESET ON ENTER:"
//.asciiz "LOOP: \0\0\0\0\0\0\0\0\0"
.asciiz "TAKE ME THERE: "
.asciiz "MOVE SET: \0\0\0\0\0"
.asciiz "L 2 LEVITATE: \0"
.asciiz "TRANSFORM ME: \0"
.asciiz "GHOST BETA: \0\0\0"
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"


MenuOptionMaxStates: ;DO NOT CHANGE THIS NAME
InfinitesMaxState:
.byte 2
ResetOnEnterMaxState:
.byte 4
TakeMeThereMaxState:
.byte 14
MoveSetMaxState:
.byte 6
L2LevitateMaxState:
.byte 2
TransformMeMaxState:
.byte 8
GhostMaxState:
.byte 2

.align
MenuOptionStringSet: ;DO NOT CHANGE THIS NAME
InfinitesStringSet:
.word OnOffOptionString
ResetOnEnterStringSet:
.word ResetOptionString
TakeMeThereStringSet:
.word TakeMeThereOptionString
MoveSetStringSet:
.word MoveSetOptionString
L2LevitateStringSet:
.word OnOffOptionString
TransformMeStringSet:
.word TransformMeOptionString
GhostStringSet:
.word OnOffOptionString



PreviousLoadzoneState:
.byte 0
.byte 0
.byte 0
.byte 0

GhostObjectPointer:
.word 0
GhostCurrentFrame:
.word 0
GhostPrevObjectArray:
.word 0
GhostObjectArrayIndex:
.word 0
GhostCurrentPlaybackPointer:
.word 0
GhostRecordPointer:
.word 0
GhostCurrentTailPointer:
.word GhostArray

/*Option strings*/
.align
OnOffOptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "ON\0\0\0\0\0"

MoveSetOptionString: ;6
.asciiz "OFF\0\0\0\0"
.asciiz "NONE\0\0\0"
.asciiz "SM\0\0\0\0\0"
.asciiz "FFM\0\0\0\0" ;FFM no Eggs
.asciiz "FFM EGG" ;FFM Eggs
.asciiz "ALL\0\0\0\0"

TakeMeThereOptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "SM\0\0\0\0\0"
.asciiz "MM\0\0\0\0\0"
.asciiz "TTC\0\0\0\0"
.asciiz "CC\0\0\0\0\0"
.asciiz "BGS\0\0\0\0"
.asciiz "FP\0\0\0\0\0"
.asciiz "GV\0\0\0\0\0"
.asciiz "MMM\0\0\0\0"
.asciiz "RBB\0\0\0\0"
.asciiz "CCW\0\0\0\0"
.asciiz "FF\0\0\0\0\0"
.asciiz "DOG\0\0\0\0"
.asciiz "GRUNTY\0"

TransformMeOptionString:
.asciiz "OFF\0\0\0\0"
.asciiz "BANJO\0\0"
.asciiz "TERMITE"
.asciiz "PUMPKN\0"
.asciiz "WALRUS\0"
.asciiz "CROC\0\0\0"
.asciiz "BEE\0\0\0\0"
.asciiz "WASHY\0\0"

ResetOptionString:
.asciiz " OFF\0\0\0"
.asciiz " 100\0\0\0"
.asciiz " ANY\0\0\0"
.asciiz " NO RBA"


/

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

temp1:
.word 0
temp2:
.word 0

GhostArray:
//ghost struct:
//	half Map
//	half Exit
//	word TotalFrames
//	word NextGhostStruct
//  word PrevGhostStruct
//  frame[0]:
//  	float XPos
//		float YPos
//		float ZPos
//  frame[1]:
//  	float XPos
//		float YPos
//		float ZPos
//	etc...