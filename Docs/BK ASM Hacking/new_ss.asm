//new_ss.asm

[last_size]: 0x9CA70
[test_addr]: 0x8037BF20
[test_size]: 0x7Ec

.org 0x80400100

NormalModeCode: ;DO NOT CHANGE THIS NAME
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 save_state_set
BEQ a0 zero NormalModeCode_save
NOP

//if D_Up load state
    JAL @osDisableInt
    NOP
    SW v0 0x10(sp)

    LW a1 @P1NewlyPressedButtons
    LUI a2 0x0800
    AND a1 a1 a2 
    BEQ a1 zero NormalModeCode_save
    NOP

    LI a0 @Heap_addr
    LA a1 save_data_space
    LI a2 @Heap_size
    JAL @memcpy
    NOP

    LI a0 @Lib_Data_addr
    LI a2 @Lid_Data_size
    JAL @memcpy
    NOP

    LI a0 @Game_Eng_Data_addr
    LI a2 @last_size
    JAL @memcpy
    NOP

    
    
    LW a0 0x10(sp)
    JAL @osRestoreInt
    NOP

    B NormalModeCode_Housekeeping
    NOP

//if D_down save state
NormalModeCode_save:
    JAL @osDisableInt
    NOP
    SW v0 0x10(sp)

    LW a1 @P1NewlyPressedButtons
    LUI a2 0x0400
    AND a1 a1 a2 
    BEQ a1 zero NormalModeCode_Housekeeping
    NOP

    LI a1 @Heap_addr
    LA a0 save_data_space
    LI a2 @Heap_size
    JAL @memcpy
    NOP
    
    
    LI a1 @Lib_Data_addr
    LI a2 @Lid_Data_size
    JAL @memcpy
    NOP

    LI a1 @Game_Eng_Data_addr
    LI a2 @last_size
    JAL @memcpy
    NOP
    
    LI a0 1
    SB a0 save_state_set

    LW a0 0x10(sp)
    JAL @osRestoreInt
    NOP

NormalModeCode_Housekeeping:	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP

save_state_set:
.byte 0

.org 0x80500000
save_data_space: