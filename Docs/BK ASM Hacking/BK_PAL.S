/*-------------------------------
| VARIABLES
---------------------------------*/
[PauseMenuStringsBase]: 0x8036C99C

[PlayerPointer]: 0x8037C8F0

[XPos]: 0x8037CF70

[XVelocity]: 0x8037CE88

[SlopeTimer]: 0x8037CCB4

[PauseMenuState]: 0x803839F0

[ReturnToLairEnabled]: 0x80383A60

/*-------------------------------
| Functions
---------------------------------*/
/* 
	NOTE: Consecutive functions identify no unknown functions in between 
	NOTE 2: If inputs or outputs are not listed, assume they are void
*/

[GetPIStatusReg]: 0x800020E0 ;Outputs: [word $v0]

[SetCOP0StatusRegister]: 0x80002190 ;Inputs: (word $a0 input)                                 
[GetCOP0StatusRegister]: 0x800021A0 ;Outputs: [word $v0]

[SetStatusRegister]: 0x80003FE0 ;Inputs: (word $a0 input)

[GetGlobalOnCounter]: 0x8023E75C ;Outputs: [word $v0]
[ResetGlobalOnCounter]: 0x8023E768

[IncrementGlobalOnCounter]: 0x8023E8E0
[DecrementGlobalOnCounter]: 0x8023E8F8

[SetApplyButtonInputsToBanjoFlag]: 0x8023EC6C

[SetFrameSkip]: 0x8024BC00 ;Inputs: (word $a0 input) 
[GetFrameSkip]: 0x8024BC0C ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[CopyCameraXYZRotation]: 0x8024C3B4 ;Inputs: (float* $a0 destinationXPtr)
[GetCamera_YRotation]: 0x8024C3D8 ;Outputs: [float $f0]

[SetCamera_XYZPosition]: 0x8024C9D8 ;Inputs: (float* $a0 xPosPtr)

[ClampInt]: 0x80257AF8 ;Inputs: (word $a0 input), (word $a1 lowerLimit), (word $a2 upperLimit)
                       ;Outputs: [word $v0]
[ClampFloat]: 0x80257B28 ;Inputs: (float $f12 input), (float $f14 lowerLimit), (float $a2 upperLimit)
                         ;Outputs: [float $f0]

[GetAngleBetween0And360]: 0x8025846C ;Inputs: ( float $f12 inputDegrees)
                                     ;Outputs: [ float $f0 ]
[RemainderFloat]: 0x80258500 ;Inputs: (float $f12 dividend), (float $f14 divisor)
                             ;Outputs: [float $f0]
[SelectMaxFloat]: 0x8025852C ;Inputs: (float $f12 input1), (float $f14 input2)
                             ;Outputs: [float $f0]
[SelectMinFloat]: 0x80258554 ;Inputs: (float $f12 input1), (float $f14 input2)
                             ;Outputs: [float $f0]
[SelectMaxInt]: 0x8025857C ;Inputs: (word $a0 input1), (word $a1 input2)
                           ;Outputs: [word $v0]
[SelectMinInt]: 0x80258598 ;Inputs: (word $a0 input1), (word $a1 input2)
                           ;Outputs: [word $v0]
[AbsFloat]: 0x802585B4 ;Inputs: (float $f12)
                       ;Outputs: [float $f0]
[SumOfAbsXZ]: 0x802585E4 ;Inputs: (float* $a0 Xptr)
                         ;Outputs: [float $f0]
[AbsInt]: 0x8025861C ;Inputs: (word $a0)
                     ;Outputs: [word $v0]

[GetXZVelocity]: 0x802978F8 ;Outputs: [float $f0]

[Print_TotalMenuFont]: 0x802F7A50 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)      

[Print_CharFont]: 0x802F7ADC ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[PauseMenu]: 0x803136B4

[SpawnActor]: 0x80328594 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

[AppendString]: 0x8033DAB0 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[AppendChar]: 0x8033DAF8 ;Inputs: (char* $a0 destinationStr), (char $a1 inputChar)

[FToA]: 0x8033DC00 ;Inputs: (char* $a0 destinationStr), (float $a1 inputFloat), (int $a2 float precision) //appends to destination string
[IToA_10]: 0x8033DCD4 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt) //base 10
[IToA]: 0x8033DCF4 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt), (word $a2 Radix)
[CompareStrings]: 0x8033DE24 ;Inputs: (char* $a0 str1), (char* $a1 str2)
                             ;Output: byte $v0 //$v0 = 0 if (strings are the same),-1 if (str1 < str2), 1 if (str1 > str2)
[CopyString]: 0x8033DEA4 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[GetStringSize]: 0x8033DED0 ;Inputs: (char* $a0 string)
							;Outputs: [word $v0]

[ToUpper]: 0x8033DFF4 ;Inputs: (char* $a0 string)
