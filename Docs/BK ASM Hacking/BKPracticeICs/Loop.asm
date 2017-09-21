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

SB zero Loop_Start_Set
SB zero Loop_Start_Map
SB zero Loop_Start_Exit
LI a0 1
SB a0 Loop_End_Set
SB zero Loop_End_Map
SB zero Loop_End_Exit


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

LB a0 Loop_Start_Set
BEQ a0 zero Loop_Normal_InLoad
NOP
    LI a0 0xE0
    LA a2 Loop_MidSetStr
    JAL @Print_CharFont
    LI a1 0x06
    B Loop_Normal_NotLoad
    NOP


//Hitting loadzone
Loop_Normal_InLoad:
LB a0 @MapLoadState
BEQ a0 zero Loop_Normal_NotLoad
NOP
    //IF LOADZONE = End Loadzone
    LB a0 @Map
    LB a1 Loop_End_Map
    BNE a0 a1 Loop_Normal_HouseKeeping
    NOP
        LB a0 @Exit
        LB a1 Loop_End_Exit
        BNE a0 a1 Loop_Normal_HouseKeeping
        NOP 
            
            LI a1 @ItemBase
            LI at 27
            Loop_Normal_LoadItems:
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
    
                BNE at zero Loop_Normal_LoadItems
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
            Loop_Normal_LoadGameProgressBitfieldLoop: 
                LW a0 0(a2)
                SW a0 0(a1)
                ADDIU a2 0x04
                ADDIU a1 0x04
                BNE at a2 Loop_Normal_LoadGameProgressBitfieldLoop
                NOP   
            
            LB a0 Loop_Start_Map
            LB a1 Loop_Start_Exit
            JAL @TakeMeThere_LevelReset
            LI a2 1
            
            B Loop_Normal_HouseKeeping
    NOP
    
    
Loop_Normal_NotLoad:
    LW a0 @P1NewlyPressedButtons
    LUI a1 0x0800
    AND a0 a0 a1 
    BEQ a0 zero Loop_Normal_HouseKeeping
    NOP
        LB a0 Loop_End_Set
        BNE a0 zero Loop_Normal_SetStart
        NOP
            //Set End Point
            SB zero Loop_Start_Set
            LB a0 @Map
            SB a0 Loop_End_Map
            LB a0 @Exit
            SB a0 Loop_End_Exit
            LI a0 1
            SB a0 Loop_End_Set
            B Loop_Normal_HouseKeeping
            NOP
        
        //Set Start Point
       Loop_Normal_SetStart:
        SB zero Loop_End_Set
        LB a0 @Map
        SB a0 Loop_Start_Map
        LB a0 @Exit
        SB a0 Loop_Start_Exit
        
        LI a1 @ItemBase
        LI at 27
        Loop_Normal_SaveItems:
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
            BNE at zero Loop_Normal_SaveItems
            NOP

        
        JAL @GetMovesUnlockedBitfield
        NOP
        SW v0 Loop_Start_Moves

        LA a2 Loop_Start_ProgressFlags
        ADDIU at a2 0x20
        LA a1 @GameProgressBitfield
        Loop_Normal_SaveGameProgressBitfieldLoop: 
            LW a0 0(a1)
            SW a0 0(a2)
            ADDIU a2 0x04
            ADDIU a1 0x04
            BNE at a2 Loop_Normal_SaveGameProgressBitfieldLoop
            NOP        

        LI a0 1
        SB a0 Loop_Start_Set



Loop_Normal_HouseKeeping:

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
Loop_Start_Set:
.byte 0
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



Loop_End_Set:
.byte 1
Loop_End_Map:
.byte 0
Loop_End_Exit:
.byte 0

.align
Loop_MidSetStr:
.asciiz "START SET"