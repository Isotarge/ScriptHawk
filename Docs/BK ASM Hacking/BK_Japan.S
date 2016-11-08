/*-------------------------------
| VARIABLES
---------------------------------*/
[PauseMenuStringsBase]: 0x8036CAF0

[PlayerPointer]: 0x8037CA20

[XPos]: 0x8037D0A0

[XVelocity]: 0x8037CFB8

[SlopeTimer]: 0x8037CDE4

[PauseMenuState]: 0x80383B50

[ReturnToLairEnabled]: 0x80383BC0

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

[GetGlobalOnCounter]: 0x8023D7BC ;Outputs: [word $v0]
[ResetGlobalOnCounter]: 0x8023D7C8

[IncrementGlobalOnCounter]: 0x8023D93C
[DecrementGlobalOnCounter]: 0x8023D954

[SetApplyButtonInputsToBanjoFlag]: 0x8023DCCC

[SetFrameSkip]: 0x8024AD18 ;Inputs: (word $a0 input) 
[GetFrameSkip]: 0x8024AD24 ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[CopyCameraXYZRotation]: 0x8024B4B4 ;Inputs: (float* $a0 destinationXPtr)
[GetCamera_YRotation]: 0x8024B4D8 ;Outputs: [float $f0]

[SetCamera_XYZPosition]: 0x8024BAD8 ;Inputs: (float* $a0 xPosPtr)

[ClampInt]: 0x80256BF8 ;Inputs: (word $a0 input), (word $a1 lowerLimit), (word $a2 upperLimit)
                       ;Outputs: [word $v0]
[ClampFloat]: 0x80256C28 ;Inputs: (float $f12 input), (float $f14 lowerLimit), (float $a2 upperLimit)
                         ;Outputs: [float $f0]

[GetAngleBetween0And360]: 0x8025756C ;Inputs: ( float $f12 inputDegrees)
                                     ;Outputs: [ float $f0 ]
[RemainderFloat]: 0x80257600 ;Inputs: (float $f12 dividend), (float $f14 divisor)
                             ;Outputs: [float $f0]
[SelectMaxFloat]: 0x8025762C ;Inputs: (float $f12 input1), (float $f14 input2)
                             ;Outputs: [float $f0]
[SelectMinFloat]: 0x80257654 ;Inputs: (float $f12 input1), (float $f14 input2)
                             ;Outputs: [float $f0]
[SelectMaxInt]: 0x8025767C ;Inputs: (word $a0 input1), (word $a1 input2)
                           ;Outputs: [word $v0]
[SelectMinInt]: 0x80257698 ;Inputs: (word $a0 input1), (word $a1 input2)
                           ;Outputs: [word $v0]
[AbsFloat]: 0x802576B4 ;Inputs: (float $f12)
                       ;Outputs: [float $f0]
[SumOfAbsXZ]: 0x802576E4 ;Inputs: (float* $a0 Xptr)
                         ;Outputs: [float $f0]
[AbsInt]: 0x8025771C ;Inputs: (word $a0)
                     ;Outputs: [word $v0]

[GetXZVelocity]: 0x80296958 ;Outputs: [float $f0]

[Print_TotalMenuFont]: 0x802F6CA4 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)      

[Print_CharFont]: 0x802F6D30 ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[PauseMenu]: 0x80312B88

[SpawnActor]: 0x803285C4 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

[AppendString]: 0x8033DAE0 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[AppendChar]: 0x8033DB28 ;Inputs: (char* $a0 destinationStr), (char $a1 inputChar)

[FToA]: 0x8033DC30 ;Inputs: (char* $a0 destinationStr), (float $a1 inputFloat), (int $a2 float precision) //appends to destination string
[IToA_10]: 0x8033DD04 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt) //base 10
[IToA]: 0x8033DD24 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt), (word $a2 Radix)
[CompareStrings]: 0x8033DE54 ;Inputs: (char* $a0 str1), (char* $a1 str2)
                             ;Output: byte $v0 //$v0 = 0 if (strings are the same),-1 if (str1 < str2), 1 if (str1 > str2)
[CopyString]: 0x8033DED4 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[GetStringSize]: 0x8033DF00 ;Inputs: (char* $a0 string)
							;Outputs: [word $v0]

[ToUpper]: 0x8033E024 ;Inputs: (char* $a0 string)
