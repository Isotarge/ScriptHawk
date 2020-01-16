//new_ss.asm

[last_size]: 0x9CA70

.org 0x80400100

NormalModeCode: ;DO NOT CHANGE THIS NAME
ADDIU sp -0x90
SW ra 0x88(sp)
SW a0 0x84(sp)
SW a1 0x80(sp)
SW a2 0x7C(sp)
SW a3 0x78(sp)
SW at 0x74(sp)
SW v0 0x70(sp)
SW v1 0x6C(sp)
SW s0 0x68(sp)
SW s1 0x64(sp)
SW s2 0x60(sp)
SW s3 0x5C(sp)
SW s4 0x58(sp)
SW s5 0x54(sp)
SW s6 0x50(sp)
SW s7 0x4C(sp)
SW t0 0x48(sp)
SW t1 0x44(sp)
SW t2 0x40(sp)
SW t3 0x3C(sp)
SW t4 0x38(sp)
SW t5 0x34(sp)
SW t6 0x30(sp)
SW t7 0x2C(sp)
SW t8 0x28(sp)
SW t9 0x24(sp)
SW k0 0x20(sp)
SW k1 0x1C(sp)
SW gp 0x18(sp)
SW fp 0x14(sp)


JAL @osDisableInt
NOP
SW v0 0x8C(sp)


LB a0 save_state_set
BEQ a0 zero NormalModeCode_save
NOP

//if D_Up load state
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

    LW sp stack_ptr_save

    B NormalModeCode_Housekeeping
    NOP

//if D_down save state
NormalModeCode_save:
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
    SW sp stack_ptr_save

NormalModeCode_Housekeeping:	

LW a0 0x8C(sp)
JAL @osRestoreInt
NOP

LW ra 0x88(sp)
LW a0 0x84(sp)
LW a1 0x80(sp)
LW a2 0x7C(sp)
LW a3 0x78(sp)
LW at 0x74(sp)
LW v0 0x70(sp)
LW v1 0x6C(sp)
LW s0 0x68(sp)
LW s1 0x64(sp)
LW s2 0x60(sp)
LW s3 0x5C(sp)
LW s4 0x58(sp)
LW s5 0x54(sp)
LW s6 0x50(sp)
LW s7 0x4C(sp)
LW t0 0x48(sp)
LW t1 0x44(sp)
LW t2 0x40(sp)
LW t3 0x3C(sp)
LW t4 0x38(sp)
LW t5 0x34(sp)
LW t6 0x30(sp)
LW t7 0x2C(sp)
LW t8 0x28(sp)
LW t9 0x24(sp)
LW k0 0x20(sp)
LW k1 0x1C(sp)
LW gp 0x18(sp)
LW fp 0x14(sp)
ADDIU sp 0x90
JR
NOP

.org 0x80410000
stack_ptr_save:
.word 0

save_state_set:
.byte 0

.org 0x80500000
save_data_space: