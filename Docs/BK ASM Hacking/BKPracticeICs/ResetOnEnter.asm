;--------------------------------------------------
; Function Definition Structure
;--------------------------------------------------
; This struct contains all the info needed for the 
; practice menu to successfully run the function
; in the practice menu
;
; Add X_DefStruct to the function list in PracticeMenu.asm
; And adjust option [NumberOfOptions] & [PageTopMax]
;--------------------------------------------------
.align
ResetOnEnter_DefStruct:
ResetOnEnter_State:
.byte 0
ResetOnEnter_MaxState:
.byte 5

.align
ResetOnEnter_MenuOptionString:
.word ResetOneEnter_OptionString
ResetOnEnter_PauseModePtr: ;set to 0 if no code is to be run upon exiting the pause menu
.word 0
ResetOnEnter_NormalModePtr: ;set to 0 if no code is to be run during Normal menu
.word ResetOnEnter_NormalMode
ResetOnEnter_Label: 
.asciiz "RESET ON ENTER:"

//Reset_Struct_Offsets_Definition
[Reset_Struct_ProgFlagPtr]:0x00
[Reset_Struct_ItemsPtr]:0x04
[Reset_Struct_JiggyPtr]:0x08
[Reset_Struct_HoneycombPtr]:0x0C
[Reset_Struct_MovesPtr]:0x10
[Reset_Struct_TokenPtr]:0x14
[Reset_Struct_ModelPtr]:0x18

//Reset_Struct_Size_Definitions
[Reset_Struct_ProgFlag_Size]:0x20
[Reset_Struct_Items_Size]:0x01/////////
[Reset_Struct_Jiggy_Size]: 0x10
[Reset_Struct_Honeycomb_Size]:0x04
[Reset_Struct_Moves_Size]:0x04
[Reset_Struct_Token_Size]: 0x10
[Reset_Struct_Model_Size]:0x01

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
ResetOnEnter_PauseMode:
;YOUR PAUSE MODE CODE HERE



ResetOnEnter_NormalMode:
ADDIU sp -0x30
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

;If hitting loadzone
LB a0 @MapLoadState
BEQ a0 zero Reset_Normal_HouseKeeping
NOP
    ;if map on list
    LI at 0x0A
    Reset_Normal_FindMap:
        SUBI at at 0x01
        LA a0 @Map
        LB a0 0(a0)
        LA a1 Reset_Map_Exits
        SLL a2 at 1
        ADDU a2 a1 a2
        LB a1 0(a2)
        BEQ a0 a1 Reset_Normal_ValidMap
        NOP
    BNE at zero Reset_Normal_FindMap
    NOP
    B Reset_Normal_HouseKeeping ;Not Map in list
    NOP
    
    
    
Reset_Normal_ValidMap: ;Map is on list
    SW at 0x28(sp) ;save index on stack
    ;check that exit matches
    LB a1 0x01(a2)
    LA a0 @Exit
    LB a0 0(a0)
    BNE a0 a1 Reset_Normal_HouseKeeping
    NOP
        ;exit matchs => RESET SHIT
        ;get pointer struct for category
        LB a0 ResetOnEnter_State
        SUBI a0 a0 0x01
        SLL a0 a0 2
        LA a1 Reset_PtrsStruct_Ptrs
        ADDU a0 a0 a1
        LW a0 0(a0)
        SW a0 0x2C(sp) ;save PtrstructPtr to stack
       
        //Progress Flag Reset
        LW a1 @Reset_Struct_ProgFlagPtr(a0) ;Progress Flag ptr
        BNE zero a1 Reset_Normal_ValidProgressFlags
        NOP
            JAL @ClearGameProgressFlags
            NOP
            B Reset_Normal_JiggyReset
            NOP
        
        Reset_Normal_ValidProgressFlags:
        LI at @Reset_Struct_ProgFlag_Size
        LW a0 0x28(sp)
        SLL a0 a0 5
        ADDU a1 a1 a0
        Reset_Normal_ProgFlag_Loop:
            SUBI at 0x01
            ADDU a0 a1 at
            LB a0 0(a0)
            LA a2 @GameProgressBitfield
            ADDU a2 a2 at
            SB a0 0(a2)
            BNE at zero Reset_Normal_ProgFlag_Loop
            NOP
     
        //Jiggies Reset
        Reset_Normal_JiggyReset:
        LW a0 0x2C(sp)
        LW a1 @Reset_Struct_JiggyPtr(a0)
        BNE zero a1 Reset_Normal_ValidJiggy
        NOP
            JAL @ZeroJiggyCollectedBitfield
            NOP
            B Reset_Normal_HoneycombReset
            NOP
        Reset_Normal_ValidJiggy:
        LI at @Reset_Struct_Jiggy_Size
        LW a0 0x28(sp)
        SLL a0 a0 4
        ADDU a1 a1 a0
        Reset_Normal_Jiggy_Loop:
            SUBI at 0x01
            ADDU a0 a1 at
            LB a0 0(a0)
            LA a2 @JiggyBitfield
            ADDU a2 a2 at
            SB a0 0(a2)
            BNE at zero Reset_Normal_Jiggy_Loop
            NOP
             
        //Honeycombs Reset
        Reset_Normal_HoneycombReset:
        LW a0 0x2C(sp)
        LW a1 @Reset_Struct_HoneycombPtr(a0)
        BNE zero a1 Reset_Normal_ValidHoneycomb
        NOP
            JAL @ClearEmptyHoneyCombsCollectedBitfield
            NOP
            B Reset_Normal_ItemsReset
            NOP
        Reset_Normal_ValidHoneycomb:
        LI at @Reset_Struct_Honeycomb_Size
        LW a0 0x28(sp)
        SLL a0 a0 2
        ADDU a1 a1 a0
        Reset_Normal_Honeycomb_Loop:
            SUBI at 0x01
            ADDU a0 a1 at
            LB a0 0(a0)
            LA a2 @EmptyHoneycombBitfield
            ADDU a2 a2 at
            SB a0 0(a2)
            BNE at zero Reset_Normal_Honeycomb_Loop
            NOP
               
        //Items Reset
        Reset_Normal_ItemsReset:
        LW a0 0x2C(sp)
        LW a1 @Reset_Struct_ItemsPtr(a0)
        BNE zero a1 Reset_Normal_ValidItems
        NOP
            LA a2 @ItemBase
            LW a0 0x54(a2)
            SW a0 0x50(a2)
            B Reset_Normal_MovesReset
            NOP
        Reset_Normal_ValidItems:
        LI at @Reset_Struct_Items_Size
        LW a0 0x28(sp)
        SLL a0 a0 3
        ADDU a1 a1 a0
        LA a2 @ItemBase
        LB a0 0x00(a1);eggs
        SW a0 0x34(a2)
        LB a0 0x01(a1);red feathers
        SW a0 0x3C(a2)
        LB a0 0x02(a1);gold feathers
        SW a0 0x40(a2)
        LB a0 0x04(a1);health containers
        SW a0 0x54(a2)
        LB a0 0x03(a1);health
        SW a0 0x50(a2)
        LB a0 0x05(a1);lives
        SW a0 0x58(a2)
        LB a0 0x06(a1);MT
        SW a0 0x70(a2)
        LB a0 0x07(a1);Jiggies
        SW a0 0x98(a2)
        
        
        
        //Moves Reset
        Reset_Normal_MovesReset:
        LW a0 0x2C(sp)
        LW a1 @Reset_Struct_MovesPtr(a0)
        BNE zero a1 Reset_Normal_ValidMoves
        NOP
            ;give all moves if not specified
            LUI a0 0x000F
            ADDIU a0 a0 0xFFFF
            JAL @SetMovesUnlockedBitfield
            NOP
            JAL @SetHasUsedMovesBitfield
            NOP
            B Reset_Normal_TokensReset
            NOP
        Reset_Normal_ValidMoves:
        LW a0 0x28(sp) ;Get moves bitfield for loadzone
        SLL a0 a0 2
        ADDU a1 a1 a0
        LW a0 0x00(a1)
        JAL @SetMovesUnlockedBitfield
        NOP
        JAL @SetHasUsedMovesBitfield
        NOP
               
        //Mumbo Tokens Reset
        Reset_Normal_TokensReset:
        LW a0 0x2C(sp)
        LW a1 @Reset_Struct_TokenPtr(a0)
        BNE zero a1 Reset_Normal_ValidTokens
        NOP
            
            B Reset_Normal_NotesReset
            NOP
        Reset_Normal_ValidTokens:
        LI at @Reset_Struct_Token_Size
        LW a0 0x28(sp)
        SLL a0 a0 4
        ADDU a1 a1 a0
        Reset_Normal_Token_Loop:
            SUBI at 0x01
            ADDU a0 a1 at
            LB a0 0(a0)
            LA a2 @MumboTokensBitfield
            ADDU a2 a2 at
            SB a0 0(a2)
            BNE at zero Reset_Normal_Token_Loop
            NOP
            
        //Note Scores Reset
        Reset_Normal_NotesReset:
        JAL @SetAllLevelNotescoresTo100
        NOP      
        
        // Model Reset
        Reset_Normal_ModelReset:
        LW a0 0x2C(sp)
        LW a1 @Reset_Struct_ModelPtr(a0)
        BNE zero a1 Reset_Normal_ValidModel
        NOP
            JAL @SetMumboTransformation ;set model as banjo
            LI a0 0x01
            B Reset_Normal_HouseKeeping
            NOP
        Reset_Normal_ValidModel:
        ;get transform index
        LW a0 0x28(sp)
        ADDU a1 a1 a0
        LB a0 0x00(a1)
        JAL @SetMumboTransformation ;set model
        NOP
        B Reset_Normal_HouseKeeping
        NOP

Reset_Normal_HouseKeeping:

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x30
JR
NOP



;--------------------------------
; Variables
;--------------------------------
.align
ResetOneEnter_OptionString:
.asciiz " OFF\0\0\0"
.asciiz " 100\0\0\0"
.asciiz " 100 NO"
.asciiz " ANY\0\0\0"
.asciiz " ANY NO"
//.asciiz " SANDCASTLE\0\0\0\0" ;Not active till have flags

Reset_Map_Exits: ;<map, exit>
.byte 0x01, 0x12 ;SM
.byte 0x02, 0x05 ;MM
.byte 0x07, 0x04 ;TTC
.byte 0x0B, 0x05 ;CC
.byte 0x0D, 0x02 ;BGS
.byte 0x27, 0x01 ;FP
.byte 0x12, 0x08 ;GV
.byte 0x1B, 0x14 ;MMM
.byte 0x31, 0x10 ;RBB
.byte 0x40, 0x07 ;CCW

.align
Reset_PtrsStruct_Ptrs:
.word Reset_100_PtrStruct
.word Reset_100NoRBA_PtrStruct
.word Reset_Any_PtrStruct
.word Reset_AnyNoRBA_PtrStruct


//PTRSTRUCTS
Reset_100_PtrStruct:
.word Reset_100_ProgressFlags
.word Reset_100_Items
.word Reset_100_JiggyFlags
.word Reset_100_HoneycombFlags
.word Reset_100_MovesFlags
.word Reset_100_TokenFlags
.word Reset_100_Model

Reset_100NoRBA_PtrStruct:
.word Reset_100NoRBA_ProgressFlags
.word 0 ;Reset_100NoRBA_Items
.word 0 ;.word Reset_100NoRBA_JiggyFlags
.word Reset_100NoRBA_HoneycombFlags
.word Reset_100NoRBA_MovesFlags
.word 0 ;.word Reset_100NoRBA_TokenFlags
.word 0

Reset_Any_PtrStruct:
.word Reset_Any_ProgressFlags
.word 0 ;.word Reset_Any_Items
.word 0 ;.word Reset_Any_JiggyFlags
.word 0 
.word Reset_Any_MovesFlags
.word 0 ;.word Reset_Any_TokenFlags
.word Reset_Any_Model

Reset_AnyNoRBA_PtrStruct:
.word Reset_AnyNoRBA_ProgressFlags
.word 0 ;.word Reset_AnyNoRBA_Items
.word 0 ;.word Reset_AnyNoRBA_JiggyFlags
.word 0 
.word Reset_AnyNoRBA_MovesFlags
.word 0 ;.word Reset_AnyNoRBA_TokenFlags
.word 0

///////////////////////////////
//MODELS
Reset_100_Model:
.byte 0x01 ;SM
.byte 0x01 ;MM
.byte 0x01 ;TTC
.byte 0x01 ;CC
.byte 0x06 ;BGS
.byte 0x01 ;FP
.byte 0x01 ;GV
.byte 0x01 ;MMM
.byte 0x01 ;RBB
.byte 0x01 ;CCW

Reset_Any_Model:
.byte 0x01 ;SM
.byte 0x01 ;MM
.byte 0x01 ;TTC
.byte 0x01 ;CC
.byte 0x06 ;BGS
.byte 0x01 ;FP
.byte 0x06 ;GV
.byte 0x01 ;MMM
.byte 0x06 ;RBB
.byte 0x01 ;CCW

///////////////////////////////
//MOVES FLAGS
Reset_100_MovesFlags:
.word 0x00000000 ;SM
.word 0x000BFDBF ;MM 
.word 0x000BFDFF ;TTC
.word 0x000BFFFF ;CC
.word 0x000FFFFF ;BGS
.word 0x000FFFFF ;FP
.word 0x000FFFFF ;GV
.word 0x000FFFFF ;MMM
.word 0x000FFFFF ;RBB
.word 0x000FFFFF ;CCW

Reset_100NoRBA_MovesFlags:
.word 0x00000000 ;SM
.word 0x000BFDBF ;MM 
.word 0x000BFDFF ;TTC
.word 0x000BFFFF ;CC
.word 0x000FFFFF ;BGS
.word 0x000FFFFF ;FP
.word 0x000FFFFF ;GV
.word 0x000FFFFF ;MMM
.word 0x000FFFFF ;RBB
.word 0x000FFFFF ;CCW

Reset_Any_MovesFlags:
.word 0x00000000 ;SM
.word 0x000BFDFF ;MM 
.word 0x000BFDFF ;TTC
.word 0x000BFFFF ;CC
.word 0x000FFFFF ;BGS
.word 0x000FFFFF ;FP
.word 0x000FFFFF ;GV
.word 0x000FFFFF ;MMM
.word 0x000FFFFF ;RBB
.word 0x000FFFFF ;CCW

Reset_AnyNoRBA_MovesFlags:
.word 0x00000000 ;SM
.word 0x000BFDBF ;MM 
.word 0x000BFDFF ;TTC
.word 0x000BFFFF ;CC
.word 0x000FFFFF ;BGS
.word 0x000FFFFF ;FP
.word 0x000FFFFF ;GV
.word 0x000FFFFF ;MMM
.word 0x000FFFFF ;RBB
.word 0x000FFFFF ;CCW

///////////////////////////////
//ITEMS
Reset_100_Items:
//    eggs,   rf,   gf,    h,   hc,    l,MT_oh, J_oh
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00 ;SM
.byte 0x00, 0x00, 0x00, 0x06, 0x06, 0x03, 0x00, 0x00 ;MM
.byte 0x30, 0x00, 0x00, 0x06, 0x06, 0x04, 0x04, 0x04 ;TTC
.byte 0x2C, 0x19, 0x00, 0x06, 0x06, 0x04, 0x0B, 0x0F ;CC
.byte 0x14, 0x08, 0x04, 0x01, 0x08, 0x04, 0x06, 0x24 ;BGS
.byte 0x27, 0x18, 0x0A, 0x07, 0x07, 0x05, 0x0D, 0x19 ;FP
.byte 0x25, 0x1E, 0x0A, 0x06, 0x07, 0x05, 0x06, 0x1A ;GV
.byte 0x16, 0x16, 0x08, 0x06, 0x07, 0x05, 0x11, 0x1A ;MMM
.byte 0x11, 0x18, 0x06, 0x08, 0x08, 0x03, 0x0B, 0x19 ;RBB
.byte 0x13, 0x1E, 0x07, 0x07, 0x08, 0x03, 0x14, 0x14 ;CCW

Reset_100noRBA_Items:
Reset_Any_Items:
Reset_AnynoRBA_Items:

///////////////////////////////
//HONEYCOMB FLAGS
Reset_100_HoneycombFlags:
.word 0x00000000 ;SM
.word 0x0000F900 ;MM
.word 0x0600F900 ;TTC
.word 0x1E00F900 ;CC
.word 0x7EFFFF00 ;BGS
.word 0x7E00F900 ;FP
.word 0x7E06F900 ;GV
.word 0x7E1EF900 ;MMM
.word 0x7E1EFF00 ;RBB
.word 0x7E9FFF00 ;CCW

Reset_100NoRBA_HoneycombFlags:
.word 0x00000000 ;SM
.word 0x0000F900 ;MM
.word 0x0600F900 ;TTC
.word 0x1E00F900 ;CC
.word 0x7E00F900 ;BGS
.word 0xFF09FF00 ;FP
.word 0xFF00F900 ;GV
.word 0xFF09F900 ;MMM
.word 0xFF1EFF00 ;RBB
.word 0xFF9FFF00 ;CCW

///////////////////////////////
//JIGGY FLAGS
Reset_100_JiggyFlags:
.word 0x00000000, 0x00000000, 0x00000000, 0x00000000 ;SM
.word 0x00000000, 0x00080000, 0x00000000, 0x00000000 ;MM
.word 0xff060000, 0x00001800, 0x00000000, 0x00000000 ;TTC
.word 0xffff1e00, 0x00005800, 0x00000000, 0x00000000 ;CC
.word 0xffffff7e, 0x00ffffff, 0xffffffff, 0x1e000000 ;BGS
.word 0xffffff7e, 0x00005800, 0x00000000, 0x00000000 ;FP
.word 0xffffff7e, 0x00ff5e00, 0x00000000, 0x00000000 ;GV
.word 0xffffff7e, 0x00ff5ee1, 0x7e000000, 0x00000000 ;MMM
.word 0xffffff7e, 0x00ff7ee1, 0x7e0000f9, 0x1e000000 ;RBB
.word 0xffffff7e, 0x00ff7ee1, 0x7e00ffff, 0x1e000000 ;CCW

Reset_100NoRBA_JiggyFlags:
Reset_Any_JiggyFlags:
Reset_AnyNoRBA_JiggyFlags:

///////////////////////////////
//MUMBO TOKEN FLAGS
Reset_100_TokenFlags:
.word 0x00000000, 0x00000000, 0x00000000, 0x00000000 ;SM
.word 0x00000000, 0x00000000, 0x00000000, 0x00000000 ;MM
.word 0x3a000000, 0x00000000, 0x00000000, 0x00000000 ;TTC
.word 0xfb520000, 0x00000000, 0x00000800, 0x00000000 ;CC
.word 0xfb530281, 0xf9fd77ff, 0x5b9be955, 0x8b210000 ;BGS
.word 0xfb530200, 0x00000000, 0x00000800, 0x00000000 ;FP
.word 0xfb530281, 0xf9000000, 0x00000800, 0x00000000 ;GV
.word 0xfb530281, 0xf9fd0600, 0x00002804, 0x00000000 ;MMM
.word 0xfb530281, 0xf9fd77ff, 0x0200a804, 0x00000000 ;RBB
.word 0xfb530281, 0xf9fd77ff, 0x5b9ba804, 0x00000000 ;CCW

Reset_100NoRBA_TokenFlags:
Reset_Any_TokenFlags:
Reset_AnyNoRBA_TokenFlags:

///////////////////////////////////
//PROGRESS FLAGS
Reset_100_ProgressFlags:
.word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ;SM //TODO GET
.word 0x0008c000, 0x00010200, 0x00000020, 0x00000000, 0x00008000, 0x80000020, 0x00000008, 0x00000000 ;MM
.word 0x3869c001, 0x00070e04, 0x000000b0, 0x05000000, 0x00008003, 0x80000120, 0x0200408c, 0x01000000 ;TTC
.word 0x786fc085, 0x01070e04, 0x002000b0, 0x05000000, 0x00008003, 0x80010520, 0x0200408c, 0x01000004 ;CC
.word 0xf87fffb7, 0x3de7cfff, 0x406618b0, 0x05a4f203, 0x5cfe967f, 0xa01ffd21, 0x360c409c, 0xf9012007 ;BGS
.word 0xf87fc085, 0x01070e1c, 0x002000b0, 0x05000000, 0x0000800f, 0x80010521, 0x1208408c, 0x01000004 ;FP
.word 0xf87fdf85, 0x01274e3c, 0x002000b0, 0x05240000, 0x0400840f, 0x80014521, 0x1208409c, 0x01000004 ;GV
.word 0xf87fdf85, 0x0167ce7c, 0x002400b0, 0x05a40200, 0x0400840f, 0xa0014d21, 0x120c409c, 0x01000007 ;MMM
.word 0xf87fffa7, 0x3de7ce7d, 0x002600b0, 0x05a43200, 0x4486867f, 0xa001cd21, 0x360c409c, 0x01002007 ;RBB
.word 0xf87fffb7, 0x3de7cfff, 0x006618b0, 0x05a4f203, 0x4486867f, 0xa01bdd21, 0x360c409c, 0x01002007 ;CCW

Reset_100NoRBA_ProgressFlags:
.word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ;SM //TODO GET
.word 0x0008C000, 0x00010200, 0x00000020, 0x00000000, 0x00008000, 0x80000020, 0x00000008, 0x00000000 ;MM
.word 0x384DC001, 0x00070E04, 0x000000B0, 0x05000000, 0x00008003, 0x80000120, 0x0000D088, 0x01000000 ;TTC
.word 0x786FC085, 0x01070E04, 0x002000B0, 0x05000000, 0x00008003, 0x80010520, 0x0200D088, 0x01000004 ;CC
.word 0xF8FFC0C5, 0x031F3E0C, 0x002000B0, 0x3D020000, 0x0000800F, 0x80010521, 0x0200D088, 0x01000004 ;BGS
.word 0xF8FFE7EF, 0x0F7FFE7C, 0x002600B0, 0x3DA60200, 0x18868AFF, 0xA2018F29, 0xC206D098, 0x0100A007 ;FP
.word 0xF8FFC7CD, 0x033F7E3C, 0x002000B0, 0x3D260000, 0x1800888F, 0x82010729, 0xC202D098, 0x01000004 ;GV
.word 0xF8FFC7CD, 0x037FFE7C, 0x002400B0, 0x3DA60200, 0x1880888F, 0xA2010F29, 0xC206D098, 0x01000007 ;MMM
.word 0xF8FFFFEF, 0x3FFFFE7D, 0x002600B0, 0x3DA63200, 0x1C868EFF, 0xA201CF29, 0xF60ED098, 0x0100A007 ;RBB
.word 0xF8FFFFFF, 0x3FFFFFFF, 0x006618B0, 0x3DA6F203, 0x1C868EFF, 0xA21BDF29, 0xF60ED098, 0x0100A007 ;CCW

Reset_Any_ProgressFlags:
.word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ;SM
.word 0x0000C000, 0x00010200, 0x00000020, 0x00000000, 0x00008000, 0x80000020, 0x00000008, 0x00000000 ;MM
.word 0x3845C000, 0x00070E04, 0x000000B0, 0x05000000, 0x00008003, 0x80000120, 0x0000588B, 0x01000000 ;TTC
.word 0x7867C084, 0x01070E04, 0x002000B0, 0x05000000, 0x00008003, 0x80010520, 0x0200588B, 0x01000000 ;CC
.word 0xF877F6A4, 0x3D478F7E, 0x006618B0, 0x0580C203, 0x50B8927F, 0xA005FD21, 0x222C589B, 0x01002000 ;BGS
.word 0xF877C084, 0x01070E1C, 0x002000B0, 0x05000000, 0x0000800F, 0x80010521, 0x0208588B, 0x01000000 ;FP
.word 0xF877F6A4, 0x3D478F7E, 0x006618B0, 0x0580C203, 0x40B8927F, 0xA005F521, 0x222C589B, 0x01002000 ;GV
.word 0xF877D084, 0x01478E3C, 0x002400B0, 0x05800200, 0x0000800F, 0xA0014521, 0x020C588B, 0x01000000 ;MMM
.word 0xF877F6A4, 0x3D478F7E, 0x006618B0, 0x0580C203, 0x40B8927F, 0xA005E521, 0x222C589B, 0x01002000 ;RBB
.word 0xF877F6A4, 0x3D478F7E, 0x006618B0, 0x0580C203, 0x4080827F, 0xA001C521, 0x222C589B, 0x01002000 ;CCW

Reset_AnyNoRBA_ProgressFlags:
.word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 ;SM
.word 0x0000C000, 0x00010200, 0x00000020, 0x00000000, 0x00008000, 0x80000020, 0x00000008, 0x00000000 ;MM
.word 0x3841C001, 0x00070E04, 0x000000B0, 0x05000000, 0x00008003, 0x80000120, 0x02002089, 0x01000000 ;TTC
.word 0x7867C085, 0x01070E04, 0x002000B0, 0x05000000, 0x00008003, 0x80010520, 0x02002089, 0x01000000 ;CC
.word 0xF8F7C0C5, 0x030F1E0C, 0x002000B0, 0x3D000000, 0x0000800F, 0x80010521, 0x02002089, 0x01000000 ;BGS
.word 0xF8F7C0CD, 0x030F1E1C, 0x002000B0, 0x3D000000, 0x0000808F, 0x82010721, 0xC20A2089, 0x01000000 ;FP
.word 0xF8F7F7ED, 0x0F6FDE7C, 0x002600B0, 0x3DA40200, 0x408682FF, 0xA201C721, 0xC20E2099, 0x01002000;GV
.word 0xF8F7D0CD, 0x036FDE7C, 0x002400B0, 0x3DA40200, 0x0000808F, 0xA2014721, 0xC20E2089, 0x01000000;MMM
.word 0xF8F7F7ED, 0x3FEFDE7D, 0x002600B0, 0x3DA43200, 0x408682FF, 0xA201CF21, 0xE60E2099, 0x01002000 ;RBB
.word 0xF8F7F7ED, 0x3FEFDFFF, 0x006618B0, 0x3DA4F203, 0x408682FF, 0xA209DF21, 0xE60E2099, 0x01002000;CCW


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




