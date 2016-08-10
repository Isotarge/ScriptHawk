/*#Level Warp:
  #To use press D-down to enter prewarp state: you will notice you have 13 eggs
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
  # After having the correct warp location selected, press D-down again to perform the warp. You will regain moves and eggs upon warping/exiting warp select state
  #Note: If you accidentally poop out too many eggs, the number will wrap around after you poop your last egg
  #Hint: IF YOUR EGGS ARE UPDATING SLOWLY, pausing and unpausing instantly updates them
  */

[ControllerInputs]: 0x80281250
[WarpTrigger]: 0x8037E8F4
[PreviousRoom]: 0x8037E8F5
[PreviousDoor]: 0x8037E8F6
[CurrentEggs]: 0x80385F64
[MovePointer]: 0x8037C3A0

[SaveData]: 0x80400500
;400500: save state
;400504: Eggs
;400508: Moves

[ReturnAddress]: 0x8024E420

.ORG 0x80400000 ;CODE

PUSH R10;
PUSH R9; controller pointer
PUSH R8; SaveData pointer
PUSH R7; Egg Pointer
PUSH R6
PUSH R5

LUI R7, 0x8038
LUI R8, 0x8040
LUI R9, 0x8028

;go to appropriate state
LW R5, 0x0500(R8) 
BEQ R5, zero, State1
ADDIU R6, zero, 0x0001
BEQ R5, R6, State2
ADDIU R6, zero, 0x0002
BEQ R5, R6, State3
NOP

State4:;Exiting Menu
   LH R5, 0x1250(R9)
   ANDI R5, R5, 0x0400
   BNE R5, zero, HouseKeeping
      NOP
	  SW zero, 0x0500(R8) ;advance state
	  BEQ zero, zero, HouseKeeping
	  NOP

State1:;Not in menu
   LH R5, 0x1250(R9)
   ANDI R5, R5, 0x0400
   BEQ R5, zero, HouseKeeping
      LW R5, 0x5F64(R7)
	  SW R5, 0x0504(R8) ;save eggs

	  ADDIU R5, zero, 0x000D
	  SW R5, 0x5F64(R7) ;set eggs to 13
      
	  ADDIU R6, zero, 0x0001 
	  SW R6, 0x0500(R8) ;advance state
	  
	  BEQ zero, zero, HouseKeeping
	  NOP
   
State2:;Entering Menu
   LH R5, 0x1250(R9)
   ANDI R5, R5, 0x0400
   BNE R5, zero, HouseKeeping
	  ADDIU R6, zero, 0x0002 
	  SW R6, 0x0500(R8) ;advance state
	  BEQ zero, zero, HouseKeeping
	  NOP

State3:;In Menu
   LW R5 0x5F64(R7)
   BLEZ R5, MenuNoEggs ;eggs<=0
   ADDIU R6, 0x000D
   SUB R5, R5, R6
   BLEZ R5, MenuInEggRange ;eggs <13
   MenuTooManyEggs:
      ADDIU R5, zero, 0x0001
      SW R5 0x5F64(R7)
	  BEQ zero, zero, MenuInEggRange
   MenuNoEggs:
      ADDIU R5, zero, 0x000D
	  SW R5 0x5F64(R7)
   MenuInEggRange:
   LH R5, 0x1250(R9)
   ANDI R5, R5, 0x0400
   BEQ R5, zero, HouseKeeping
	  LW R6, 0x5F64(R7)
	  ADDIU R9, zero, 0x0D
	  BEQ R6, R9, NoWarp ; 13 = cancel
	  ADDIU R9, zero, 0x01
	  ADDIU R5, zero, 0x01
	  ADDIU R10, zero, 0x01
	  BEQ R6, R9, Warp   ;  1 = SM = 0x0101
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x69
	  ADDIU R10, zero, 0x02
	  BEQ R6, R9, Warp   ;  2 = MM = 0x6902
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x6D
	  ADDIU R10, zero, 0x00
	  BEQ R6, R9, Warp   ;  3 = TTC = 0x6D00 
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x70
	  ADDIU R10, zero, 0x02
	  BEQ R6, R9, Warp   ;  4 = CC = 0x7002 
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x7202
	  BEQ R6, R9, Warp   ;  5 = BGS = 0x7202 
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x6F 
	  ADDIU R10, zero, 0x06
	  BEQ R6, R9, Warp   ;  6 = FP = 0x6F06 
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x6E
	  ADDIU R10, zero, 0x03 
	  BEQ R6, R9, Warp   ;  7 = GV = 0x6E03 
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x75
	  ADDIU R10, zero, 0x02
	  BEQ R6, R9, Warp   ;  8 = MMM = 0x7502
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x77
	  BEQ R6, R9, Warp   ;  9 = RBB = 0x7702
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x79
	  ADDIU R10, zero, 0x04
	  BEQ R6, R9, Warp   ;  10 = CCW = 0x7904
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x8E
	  ADDIU R10, zero, 0x04
	  BEQ R6, R9, Warp   ;  11 = DoG = 0x8E04
	  ADDIU R9, R9, 0x01
	  ADDIU R5, zero, 0x93
	  ADDIU R10, zero, 0x01
	  BEQ R6, R9, Warp   ;  12 = Grunty = 0x9301
	   
   Warp:	  
	  SB R5, @PreviousRoom //only way I could get save byte to work at this location
	  SB R10, @PreviousDoor //only way I could get save byte to work at this location
	  ADDIU R5, zero, 0x01
	  SB R5, @WarpTrigger //only way I could get save byte to work at this location
	  
   NoWarp:	  
	  LW R5, 0x0504(R8)
	  SW R5, 0x5F64(R7) ;Restore eggs
	  ADDIU R6, zero, 0x0003  
	  SW R6, 0x0500(R8) ;advance state

HouseKeeping:
POP R5
POP R6
POP R7
POP R8
POP R9
POP R10;

.halfword 0x0809
.halfword 0x3908
NOP