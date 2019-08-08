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
BNE a3 at NormalModeCode_Loop_End //slot not spawning
NOP
    //spawn ghost
    SW a0 0x28(sp)
    SW a2 0x2C(sp)
    
    MOV a2 zero
    LI a1 @voidout_minPos
    JAL @SpawnActor
    LI a0 0x400
    
    LW a2 0x2C(sp)
    LW a0 0x28(sp)
    SW zero 0(a2) ;clear command
    SW v0 4(a2) ;return address
    
    //set Obj ID
    SW a0 0x80(v0)

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
puppetID_struct:
.half 0x0000 ;unknown set same a jiggy
.half 0x0400 ;actorSpawnID
.half 0x034e ;banjo
.half 0x0001 
.word 0x80366010 ;spawn function
.word ObjFrameBehavior ;normal frame behavior 
.word 0x00000000
.word 0x802C6E84 ;despawn function?
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