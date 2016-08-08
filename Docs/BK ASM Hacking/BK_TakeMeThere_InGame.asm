/*#Level Warp:
  #To use press D-down to enter prewarp state: you will notice you have 14 eggs and only the eggs move
  #Your number of eggs corresponds to where you want to warp:
  # 01 SM
  # 02 MM
  # 03 TTC
  # 04 CC
  # 05 BGS
  # 06 FP
  # 07 GV
  # 08 MMM
  # 09 RBB
  # 10 CCW/FFM
  # 11 DoG
  # 12 Grunty
  # 13 Cancel
  # After having the correct warp location selected, press D-down again to perform the warp
  #Note: If you accidentally poop out too many eggs, the number will wrap around after you poop your last egg
  #
  #Enjoy Love, Mittenz ;-]
  */

[ControllerInputs]: 0x80281250
[WarpTrigger]: 0x8037E8F4
[PreviousRoom]: 0x8037E8F5
[CurrentEggs]: 0x80385F64
[MovePointer]: 0x8037C3A0

[ReturnAddress]: 0x8024EE90 

.ORG 0x80400000 ;CODE
 ;.halfword 0xA602
 ;.halfword 0x0002

 
 PUSH t6;push registers
 PUSH t7
 PUSH t8
 ;PUSH t9
 
  LW t6, WarpState
  BEQI t6, 0x00, NotInWarpMenu
  BEQI t6, 0x01, FalseToTrue
  BEQI t6, 0x03, TrueToFalse
     ;in warp menu state
     LW  t8 @CurrentEggs
     BEQI t8 0x0000 BelowWarpCount
     BLTI t8 0x000E InRangeOfWarpCount
	 AboveWarpCount:
        ;if warp room count > Max
        LI t8 0x0001
        SW t8 @CurrentEggs ;warp room count = 1
     BelowWarpCount:
        ;if warp room count == 0
        LI t8 0x000D
        SW t8 @CurrentEggs ;warp room count = Max
     InRangeOfWarpCount:
	
     LH t6 @ControllerInputs 
     LI t7 0x0400 
     BNE t6 t7 Housekeeping
	    ;on D-down press
		;Need to find better way to implement this switch
		LW  t8 @CurrentEggs
        BEQI t8, 0x01, SM
        BEQI t8, 0x02, MM
        BEQI t8, 0x03, TTC
        BEQI t8, 0x04, CC
        BEQI t8, 0x05, BGS
        BEQI t8, 0x06, FZP
        BEQI t8, 0x07, GV
        BEQI t8, 0x08, MMM
        BEQI t8, 0x09, RBB
        BEQI t8, 0x0A, CCW
        BEQI t8, 0x0B, DoG
        BEQI t8, 0x0C, Grunty
		   ;In Cancel state
		   LW t6 EggSave
           SW t6 @CurrentEggs //restore original egg count
           LW t6 MoveSave
           SW t6 @MovePointer //restore original move register
		   B Housekeeping
		   NOP
       
		Grunty:
           B RoomIsSet
		   LI t6 0x93
        DoG:
           B RoomIsSet
		   LI t6 0x8E
        CCW:
           B RoomIsSet
		   LI t6 0x79
        RBB:
           B RoomIsSet
		   LI t6 0x77
        MMM:
           B RoomIsSet
		   LI t6 0x75
        GV:
           B RoomIsSet
		   LI t6 0x6E
        FZP:
           B RoomIsSet
		   LI t6 0x6F
        BGS:
           B RoomIsSet
		   LI t6 0x72
        CC:
           B RoomIsSet
		   LI t6 0x70
        TTC:
           B RoomIsSet
		   LI t6 0x6D
        MM:
           B RoomIsSet
		   LI t6 0x69
        SM:
           LI t6 0x01
		RoomIsSet:
		SB  t6 @PreviousRoom
        LW t6 EggSave
        SW t6 @CurrentEggs ;restore original egg count
        LW t6 MoveSave
        SW t6 @MovePointer ;restore original move register
        LI t6 0x01
        SB t6 @WarpTrigger ;trigger OoB loadzone
		LI t6 0x03
        SW t6 WarpState ;clear warp menu state flag 
		
        B Housekeeping
		NOP
    
 FalseToTrue:
     LH t6 @ControllerInputs  
     BEQI t6 0x0400 Housekeeping
        LI t6 0x02
	    SW t6 WarpState //set warp menu state flag 
	    B Housekeeping
		NOP

 TrueToFalse:
     LH t6 @ControllerInputs  
     BEQI t6 0x0400 Housekeeping
        LI t6 0x00
	    SW t6 WarpState //set warp menu state flag 
	    B Housekeeping
		NOP

  NotInWarpMenu: //not in warp menu state
  ;LI t6 0x0010
  ;SW t6, @CurrentEggs ;warp room count = Max

     LH t6 @ControllerInputs 
     LI t7 0x0400 
     BNE t6 t7 Housekeeping
        //On D-down press
		LI t6 0x01
        SW t6 WarpState //set warp menu state flag 
        LW t6 @CurrentEggs 
        SW t6 EggSave //store current egg value
        LI t6 0x0D
        SW t6 @CurrentEggs //load max room pointer number in egg location
        LW t6 @MovePointer
        SW t6 MoveSave //store current move register
        LI t6 0x0040
        SW t6 @MovePointer //give access to only eggs move
		
  



  Housekeeping:
  ;POP t9 ;housekeeping = pop pushed registers
  POP t8
  POP t7
  POP t6
  
  J @ReturnAddress ;return
  NOP

WarpState:
.word 0x00
EggSave:
.word 0
MoveSave:
.word 0
TestSave:
.half 0