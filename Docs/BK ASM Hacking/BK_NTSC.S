/*-------------------------------
| VARIABLES
---------------------------------*/
[PauseMenuStringsBase]:0x8036C4E0

[PlayerPointer]:0x8037BF20

[XPos]: 0x8037C5A0

[XVelocity]: 0x8037C4B8

[SlopeTimer]: 0x8037C2E4

[PauseMenuState]: 0x80383010

[ReturnToLairEnabled]: 0x80383080



/*-------------------------------
| Functions
---------------------------------*/
/* 
   NOTE: Consecutive functions identify no unknown functions in between 
   NOTE 2: If inputs or outputs are not listed, assume they are void
*/

[GetPIStatusReg]: 0x8000210C ;Outputs: [word $v0]

[SetCOP0StatusRegister]: 0x80002190 ;Inputs: (word $a0 input)                                 
[GetCOP0StatusRegister]: 0x800021a0 ;Outputs: [word $v0]

[SetStatusRegister]: 0x80003FE0 ;Inputs: (word $a0 input)

[GetGlobalOnCounter]: 0x8023DB5C; Outputs: [word $v0]

[IncrementGlobalOnCounter]: 0x8023DCDC

[SetApplyButtonInputsToBanjoFlag]: 0x8023E06C

[SetFrameSkip]: 0x8024BF94 ;Inputs: (word $a0 input) 
[GetFrameSkip]: 0x8024BFA0 ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby




[ClampInt]: 0x80257EA8 ;Inputs: (word $a0 input), (word $a1 lowerLimit), (word $a2 upperLimit)
                       ;Outputs: [word $v0]
[ClampFloat]: 0x80257ED8 ;Inputs: (float $f12 input), (float $f14 lowerLimit), (float $a2 upperLimit)
                         ;Outputs: [float $f0]

[GetAngleBetween0And360]: 0x8025881C ;Inputs: ( float $f12 inputDegrees)
                                     ;Outputs: [ float $f0 ]
[RemainderFloat]: 0x802588D0 ;Inputs: (float $f12 dividend), (float $f14 divisor)
                             ;Outputs: [float $f0]
[SelectMaxFloat]: 0x802588DC ;Inputs: (float $f12 input1), (float $f14 input2)
                             ;Outputs: [float $f0]
[SelectMinFloat]: 0x80258904 ;Inputs: (float $f12 input1), (float $f14 input2)
                             ;Outputs: [float $f0]
[SelectMaxInt]: 0x8025892C ;Inputs: (word $a0 input1), (word $a1 input2)
                           ;Outputs: [word $v0]
[SelectMinInt]: 0x80258948 ;Inputs: (word $a0 input1), (word $a1 input2)
                           ;Outputs: [word $v0]
[AbsFloat]: 0x80258964 ;Inputs: (float $f12)
                       ;Outputs: [float $f0]
[SumOfAbsXZ]: 0x80258994 ;Inputs: (float* $a0 Xptr)
                         ;Outputs: [float $f0]
[AbsInt]: 0x802589CC ;Inputs: (word $a0)
                     ;Outputs: [word $v0]

[GetXZVelocity]: 0x80297AB8 ;Outputs: [float $f0]

[CopyCameraXYZRotation]: 0x8024C764 ;Inputs: (float* $a0 destinationXPtr)
[GetCamera_YRotation]: 0x8024C788 ;Outputs: [float $f0]

[SetCamera_XYZPosition]: 0x8024CD88 ;Inputs: (float* $a0 xPosPtr)





[Print_TotalMenuFont]: 0x802F7870 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)      

[Print_CharFont]: 0x802F78FC ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[PauseMenu]: 0x80313380

[SpawnActor]: 0x8032813C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)


[AppendString]: 0x8033D670 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[AppendChar]: 0x8033D6A8 ;Inputs: (char* $a0 destinationStr), (char $a1 inputChar)
                          
[FToA]: 0x8033D7B0 ;Inputs: (char* $a0 destinationStr), (float $a1 inputFloat), (int $a2 float precision) //appends to destination string
[IToA_10]: 0x8033D884 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt) //base 10
[IToA]: 0x8033D884 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt), (word $a2 Radix)
[CompareStrings]: 0x8033D9D4 ;Inputs: (char* $a0 str1), (char* $a1 str2)
                             ;Output: byte $v0 //$v0 = 0 if (strings are the same),-1 if (str1 < str2), 1 if (str1 > str2)
[CopyString]: 0x8033DA54 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[GetStringSize]: 0x8033DA80 ;Inputs: (char* $a0 string)
                            ;Outputs: [word $v0]
                            
[ToUpper]: 0x8033DBA4 ;Inputs: (char* $a0 string)



