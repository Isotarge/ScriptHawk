;--------------------------------------------------
; Function Definition Structure
;--------------------------------------------------
; This struct contains all the info needed for the 
; practice menu to successfully run the function
; in the practice menu
;
; Add X_DefStruct to the function list in PracticeMenu.asm
;--------------------------------------------------
.align
Loop_DefStruct:
Loop_State: ;STATE AT STARTUP
.byte 0
Loop_MaxState: ;TOTAL # OF STATES
.byte 2

.align
Loop_MenuOptionString: ;POINTER TO STRINGS CORRESPONDING TO EACH STATE
.word OnOffOptionString ;set must be 7 character (8 including trailing 0), Must be all caps

Loop_PauseModePtr: ;POINTER TO CODE TO RUN UPON EXITING THE PAUSE MENU
.word Loop_PauseMode ;set to 0 if no code is to be run upon exiting the pause menu

Loop_NormalModePtr: ;POINTER TO CODE TO RUN DURING NORMAL GAME PLAY
.word Loop_NormalMode ;set to 0 if no code is to be run during Normal menu

Loop_Label: ;LABEL IN MENU
.asciiz "LOOP: \0\0\0\0\0\0\0\0\0" ;must be 15 character (16 including trailing 0), Must be all caps

.align
;-------------------------------
; Pause Mode Code
;-------------------------------
Loop_PauseMode:
ADDIU sp -0x20
SW ra 0x1C(sp)
SW a0 0x18(sp)


LB a0 Loop_State
BNE a0 zero Loop_Pause_HouseKeeping
NOP
    SB zero Loop_Internal_State

Loop_Pause_HouseKeeping:
LW ra 0x1C(sp)
LW a0 0x18(sp)
ADDIU sp 0x20
JR
NOP


;-------------------------------
; Normal Mode Code
;-------------------------------
Loop_NormalMode:
ADDIU sp -0x30
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)

LB a0 Loop_Internal_State
BNE a0 zero Loop_Normal_Not_0
NOP

//STATE0: Start/Off
    ;If D-Pad up
    LW a1 @P1NewlyPressedButtons
    LUI a2 0x0800
    AND a1 a1 a2 
    BEQ a1 zero Loop_Normal_HouseKeeping 
    NOP
        ;Set Start
        LB a1 @Map
        SB a1 Loop_Start_Map
        LB a1 @Exit
        SB a1 Loop_Start_Exit
        
        LI a1 @ItemBase
        LI at 27
        Loop_Normal_0_SaveItems:
            SUBI at at 1
            SLL a0 at 2
            ADDIU a2 a0 0x0C
            ADDU a2 a2 a1
            LW a2 0(a2)
            SW a2 0x28(sp)
            LA a2 Loop_Start_Items
            ADDU a0 a0 a2
            LW a2 0x28(sp)
            SW a2 0(a0)
            BNE at zero Loop_Normal_0_SaveItems
            NOP

        
        JAL @GetMovesUnlockedBitfield
        NOP
        SW v0 Loop_Start_Moves

        LA a2 Loop_Start_ProgressFlags
        ADDIU at a2 0x20
        LA a1 @GameProgressBitfield
        Loop_Normal_0_SaveGameProgressBitfieldLoop: 
            LW a0 0(a1)
            SW a0 0(a2)
            ADDIU a2 0x04
            ADDIU a1 0x04
            BNE at a2 Loop_Normal_0_SaveGameProgressBitfieldLoop
            NOP    
        
        ;Increment state
        LI a0 0x01
        SB a0 Loop_Internal_State
        B Loop_Normal_HouseKeeping
        NOP
        
Loop_Normal_Not_0:
LI at 0x01
BNE a0 at Loop_Normal_Not_1
NOP

//STATE1: Start Set
    ;If D-Pad up
    LW a1 @P1NewlyPressedButtons
    LUI a2 0x0800
    AND a1 a1 a2 
    BEQ a1 zero Loop_Normal_HouseKeeping 
    NOP
        ;Increment state
        LI a0 0x02
        SB a0 Loop_Internal_State
        B Loop_Normal_HouseKeeping
        NOP

Loop_Normal_Not_1:
LI at 0x02
BNE a0 at Loop_Normal_Not_2
NOP

//STATE2: Waiting for end loadzone
    ;If Hitting Loadzone
    LB a1 @MapLoadState
    BEQ a1 zero Loop_Normal_HouseKeeping
    NOP
        ;Save as end point
        LB a1 @Map
        SB a1 Loop_End_Map
        LB a2 @Exit
        SB a2 Loop_End_Exit
        
        ;Increment State
        LI a0 0x03
        SB a0 Loop_Internal_State
        B Loop_Normal_HouseKeeping
        NOP

Loop_Normal_Not_2:

//STATE3: Loop Set
    ;If Hitting Loadzone
    LB a1 @MapLoadState
    BEQ a1 zero Loop_Normal_3_Not_LZ
    NOP
        ;If Map == End_Map
        LB a0 @Map
        LB a1 Loop_End_Map
        BNE a0 a1 Loop_Normal_3_Not_LZ
        NOP
        LB a0 @Exit ;If Exit = End_Exit
            LB a1 Loop_End_Exit
            BNE a0 a1 Loop_Normal_3_Not_LZ
            NOP
            LI a1 @ItemBase
            
            LI at 27
            Loop_Normal_3_LoadItems:
                SUBI at at 1
                SLL a0 at 2
                LA a2 Loop_Start_Items
                ADDU a2 a0 a2
                LW a2 0(a2)
                SW a2 0x28(sp)
                
                ADDIU a2 a0 0x0C
                ADDU a0 a2 a1
                LW a2 0x28(sp)
                SW a2 0(a0)
    
                BNE at zero Loop_Normal_3_LoadItems
                NOP

            JAL @ZeroJiggyCollectedBitfield
            NOP
            JAL @ClearEmptyHoneyCombsCollectedBitfield
            NOP
            JAL @ClearCollectedMumboTokenFlags
            NOP
            
            LW a0 Loop_Start_Moves
            JAL @SetMovesUnlockedBitfield
            NOP
            JAL @SetHasUsedMovesBitfield
            NOP

            LA a2 Loop_Start_ProgressFlags
            ADDIU at a2 0x20
            LA a1 @GameProgressBitfield
            Loop_Normal_3_LoadGameProgressBitfieldLoop: 
                LW a0 0(a2)
                SW a0 0(a1)
                ADDIU a2 0x04
                ADDIU a1 0x04
                BNE at a2 Loop_Normal_3_LoadGameProgressBitfieldLoop
                NOP   
            
            LB a0 Loop_Start_Map
            LB a1 Loop_Start_Exit
            JAL @TakeMeThere_LevelReset
            LI a2 0x01                
    
    Loop_Normal_3_Not_LZ:
    ;If D-Up
    LW a1 @P1NewlyPressedButtons
    LUI a2 0x0800
    AND a1 a1 a2 
    BEQ a1 zero Loop_Normal_HouseKeeping 
    NOP
        SB zero Loop_Internal_State
        B Loop_Normal_HouseKeeping
        NOP
        
Loop_Normal_HouseKeeping:

    LB a0 Loop_Internal_State
    SLL a0 a0 4
    LA a2 Loop_MidSetStr
    ADDU a2 a2 a0
    LI a0 0xE0
    JAL @Print_CharFont
    LI a1 0x06

LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x30
JR
NOP

;-------------------------------
; Variables
;-------------------------------
Loop_Start_Map:
.byte 0
Loop_Start_Exit:
.byte 0

.align
Loop_Start_Moves:
.word 0
Loop_Start_Items:
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0
Loop_Start_ProgressFlags:
.word 0,0,0,0,0,0,0,0

Loop_Internal_State:
.byte 0

Loop_End_Map:
.byte 0
Loop_End_Exit:
.byte 0

.align
Loop_MidSetStr:
.asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
.asciiz "START SET\0\0\0\0\0\0"
.asciiz "WAITING...\0\0\0\0\0"
.asciiz "LOOP SET\0\0\0\0\0\0\0"