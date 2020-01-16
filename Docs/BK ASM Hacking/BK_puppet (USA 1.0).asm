//Boot map
.org 0x8023DBAB
.byte 0x91

// HOOKS
;PAUSE MODE JUMP LOCATION: 0x802E47F4
;.org 0x802E47F4
;JAL PauseMode
;NOP

;NORMAL MODE JUMP LOCATION: 0x80334FFC
.org 0x80334FFC
JAL NormalModeCode
NOP

.org 0x80303F90
JAL noteCheckFunc

.org 0x80303FF4
JAL noteCheckFunc

;GET OBJECT IN OBJECT SPAWN ARRAY
.org 0x802C2C40
JAL puppetSpawnArrayAdd

//.org
//JAL ObjFrameBehavior
//NOP

//ENUMERATIONS
.include "Docs/BK ASM Hacking/BK_Enum.S"
//EXISTING FUNCTIONS
.include "Docs/BK ASM Hacking/BK_NTSC.S"

[cleanObjArray_bool]: 0x8036E570
[freeObj]: 0x80328028
[collisionPtr]: 0x803820B8
[collisionFunc]: 0x80303D78
[get_objType2_actorPtr]: 0x80329958
;----------------------------------------------------------------
; Code Run from Pause Mode
;----------------------------------------------------------------
.org 0x80400100

;----------------------------------------------------------------
; Code Run from Normal Mode
;
;----------------------------------------------------------------
NormalModeCode: ;DO NOT CHANGE THIS NAME
ADDIU sp -0x30
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW a3 0x14(sp)
SW at 0x10(sp)


MOV a0 zero
NormalModeCode_Loop:
//step through array until 0
LA a1 objCommandArray
SLL a2 a0 3
ADDU a2 a2 a1
LW a3 0(a2)

LI at 0xFFFFFFFF
BNE a3 at NormalModeCode_Slot_Check //slot not spawning
NOP
    

    //spawn ghost
    SW a0 0x28(sp)
    SW a2 0x2C(sp)
    
    MOV a2 zero
    LI a1 @voidout_minPos
    //LI a1 @XPos

    JAL @SpawnActor
    LI a0 0x400
  
    LI a0 0x3FFC
    SW a0 0x78(v0)
    
    LW a2 0x2C(sp)
    LW a0 0x28(sp)
    SW zero 0(a2) ;clear command
    SW v0 4(a2) ;return address
    
    //set Obj ID
    SW a0 0x80(v0)
    B NormalModeCode_Loop_End
    NOP
    
NormalModeCode_Slot_Check:
LW a3 4(a2) //get actor address
BEQ zero a3 NormalModeCode_Loop_End
NOP
    
    LI a1 @ObjectArrayPointer
    LW a1 0(a1) //actor array address
    BEQ zero a1 NormalModeCode_Dead_Actor
    LW at 0(a1)
    BEQ zero at NormalModeCode_Dead_Actor
    ADDIU a1 0x08
    MOV s0 zero
NormalModeCode_Actor_Loop:
        //look for actor in actor array
        MOV s1 s0
        SLL s1 s1 2
        SUBU s1 s1 s0
        SLL s1 s1 7
        ADD s1 s1 a1
        BGT s1 a3 NormalModeCode_Dead_Actor
        NOP
        BNE s1 a3 NormalModeCode_Actor_Loop_End
        NOP
            LW s1 0x80(a3)
            BNE a0 s1 NormalModeCode_Dead_Actor
            NOP
            SW a0 0x28(sp)
            LW s1 0x12C(a3)
            LA a0 puppetID_struct
            BNE s1 a0 NormalModeCode_Dead_Actor
            LW a0 0x28(sp)
            LB s1 0x47(a3)
            ANDI s1 0x08
            BNE zero s1 NormalModeCode_Dead_Actor
            NOP
            B NormalModeCode_Loop_End
            NOP

NormalModeCode_Actor_Loop_End:
        ADDIU s0 0x01
        BNE s0 at NormalModeCode_Actor_Loop
        NOP
            
NormalModeCode_Dead_Actor:       
    //else write zero to address
    SW zero 0x4(a2)
    NOP

NormalModeCode_Loop_End:
ADDIU a0 a0 1
LA a1 maxPlayers
LW a1 0(a1)
BNE a0 a1 NormalModeCode_Loop ;check if a0 = max ID
NOP


NormalModeCode_Housekeeping:	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW a1 0x14(sp)
LW at 0x10(sp)
ADDIU sp 0x30
JR
NOP



;----------------------------------------------------------------
; Globalizes puppet object
;
;----------------------------------------------------------------
puppetSpawnArrayAdd:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)
    
JAL @AddObjIDStructToObjectSpawnArray
NOP
LA a0 puppetID_struct
LI a2 0x103
LW a1 0x1C(sp)
JAL @AddObjIDStructToObjectSpawnArray
NOP
    
puppetSpawnArrayAdd_HouseKeeping:	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP


;----------------------------------------------------------------
; Note check
;
;----------------------------------------------------------------
noteCheckFunc:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)
SW s1 0x10(sp)
SW s2 0x08(sp)
SW s3 0x04(sp)

//run normal collision code
JAL @collisionFunc
NOP


//note despawn
LI s1 @collisionPtr
LI s2 0
LI s3 0

noteCheckFunc_allCollLoop:
    LW a0 0(s1)
    BEQ a0 zero noteCheckFunc_housekeeping
    MOV a2 a0 //duplicate voxObjPtr

    //check is simpObj or actorObj
    LW a0 0(a0) 
    LUI a1 0x8000
    AND a1 a0 a1
    BEQ a1 zero noteCheckFunc_simpObj
    NOP

    //ACTOR OBJ
    //check actor collsion
    JAL @get_objType2_actorPtr
    MOV a2 a0

    LW a0 0x10(v0)
    ANDI a0 a0 0x0001
    BEQ a0 zero noteCheckFunc_printVal
    nop

    LB a0 0xE8(v0)
    ANDI a0 1
    BEQ a0 zero noteCheckFunc_endLoopCheck
    nop

    noteCheckFunc_printVal:
    LH a2 0x3E(a2)
    SRL a2 a2 2
    ANDI a2 a2 0x00000FFF

    LA a1 ourActorCollider
    ADD a1 a1 s2
    ADDIU s2 0x04
    B noteCheckFunc_endLoopCheck
    SW a2 0(a1)




    //VOXEL OBJ
    noteCheckFunc_simpObj:
    LA a1 ourVoxelCollider
    ADD a1 a1 s3
    ADDIU s3 0x04
    SW a2 0(a1)
    
    noteCheckFunc_endLoopCheck:
    ADDIU s1 s1 0x04
    B noteCheckFunc_allCollLoop
    NOP


noteCheckFunc_housekeeping:
LA a1 ourColliderCount
SW s2 0(a1)

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
LW s1 0x10(sp)
LW s2 0x08(sp)
LW s3 0x04(sp)
ADDIU sp 0x28
JR
NOP


;----------------------------------------------------------------
; frame by frame behavior of puppet
;
;----------------------------------------------------------------
ObjFrameBehavior:
ADDIU sp -0x30
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW a3 0x14(sp)
SW at 0x10(sp)




Lw a2 0x80(a0) 
SLL a2 a2 3
LA a1 objCommandArray
ADDU a1 a2 a1

LW a2 0(a1) //check if despawn
LI at 0xFFFFFFFE
BNE a2 at ObjFrameBehavior_NoDespawn //slot not spawning
NOP
    SW zero 0(a1)
    SW zero 4(a1)
    //despawn Obj
    LB a2 0x47(a0)
    ORI a2 0x08
    SB a2 0x47(a0) 

    B ObjFrameBehavior_Housekeeping
NOP

ObjFrameBehavior_NoDespawn:
SW a0 4(a1) //save pointer to Array

ObjFrameBehavior_Housekeeping:		
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW a1 0x14(sp)
LW at 0x10(sp)
ADDIU sp 0x30
JR
NOP

;----------------------------------------------------------------
; Menu Variables
; BitFlags
;----------------------------------------------------------------



.align
defaultSpawnLocation:
.word 0
.word 0
.word 0


.align
puppetAnimationTable:
.word 0
.word 0
.word 0x6F
.word 0x40b00000

.align
puppetID_struct:
.half 0x0000 ;unknown set same a jiggy
.half 0x0400 ;actorSpawnID
.half 0x034e ;banjo
.half 0x0001 ;start animation index
.word puppetAnimationTable ;obj animation list
.word ObjFrameBehavior ;normal frame behavior 
.word 0x00000000
.word 0x80325888 ;despawn function?
.word 0x00000000 
.word 0x00000000
.word 0x00000000

.org 0x80401000

.align
maxPlayers:
.word 16

objCommandArray:
.word 0 //command
.word 0 //ptr
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0

.org 0x804010FC
ourColliderCount:
.word 0
.org 0x80401100
ourVoxelCollider:
.word 0
.org 0x80401180
ourActorCollider:
.word 0
