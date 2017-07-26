.align
L2Levitate_NormalMode:
ADDIU sp -0x28
SW ra 0x24(sp)
SW a0 0x20(sp)
SW a1 0x1C(sp)
SW a2 0x18(sp)
SW at 0x14(sp)


LB a0 L2LevitateState
BEQ a0 zero L2Levitate_Normal_Off
NOP
	JAL @GetButtonPressTimer
	LI a0 0x02 ;L button Index
	BEQ v0 zero L2Levitate_Normal_Off
	LUI a0 0x4220
		MTC1 zero f12
		JAl @SetYVelocity ;Vel increases while airborn, if Vel > pos change then banjo still falls
		LUI a0 0x41a0
		MTC1 a0 f12
		JAl @AddToYPos
        NOP
L2Levitate_Normal_Off:
	
LW ra 0x24(sp)
LW a0 0x20(sp)
LW a1 0x1C(sp)
LW a2 0x18(sp)
LW at 0x14(sp)
ADDIU sp 0x28
JR
NOP