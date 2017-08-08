.align
;-------------------------------
; Pause Mode Code
;-------------------------------
Ghost_PauseMode:

ADDIU sp -0x20
SW ra 0x1C(sp)
SW a0 0x18(sp)
SW a1 0x14(sp)
SW s3 0x10(sp)


LB s3 GhostState
BNE s3 zero KeepCurrentGhostActive
LW a1 GhostObjectPointer
    BEQ a1 zero KeepCurrentGhostActive
    NOP
        LB a0 0x47(a1)
        ORI a0 a0 0x08
        SB a0 0x47(a1)
        SW zero GhostCurrentFrame

KeepCurrentGhostActive:

LW ra 0x1C(sp)
LW a0 0x18(sp)
LW a1 0x14(sp)
LW s3 0x10(sp)
ADDIU sp 0x20

JR	;IMPORTANT
NOP ;IMPORTANT


;-------------------------------
; Normal Mode Code
;-------------------------------

Ghost_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

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