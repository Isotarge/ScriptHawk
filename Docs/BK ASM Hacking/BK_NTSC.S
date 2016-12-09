/*-------------------------------
| VARIABLES
---------------------------------*/
[PauseMenuStringsBase]: 0x8036C4E0

[PlayerPointer]: 0x8037BF20

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

[GetPIStatusReg]: 0x800020E0 ;Outputs: [word $v0]


[SetCOP0StatusRegister]: 0x80002190 ;Inputs: (word $a0 input)
[GetCOP0StatusRegister]: 0x800021A0 ;Outputs: [word $v0]


[SetStatusRegister]: 0x80003FE0 ;Inputs: (word $a0 input)


[GetGlobalOnCounter]: 0x8023DB5C ;Outputs: [word $v0]
[ResetGlobalOnCounter]: 0x8023DB68


[IncrementGlobalOnCounter]: 0x8023DCDC
[DecrementGlobalOnCounter]: 0x8023DCF4


[MainLoop]: 0x8023DF9C


[SetApplyButtonInputsToBanjoFlag]: 0x8023E06C


[SetFrameSkip]: 0x8024BF94 ;Inputs: (word $a0 input)
[GetFrameSkip]: 0x8024BFA0 ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby


[CopyCameraXYZRotation]: 0x8024C764 ;Inputs: (float* $a0 destinationXPtr)
[GetCamera_YRotation]: 0x8024C788 ;Outputs: [float $f0]


[SetCamera_XYZPosition]: 0x8024CD88 ;Inputs: (float* $a0 xPosPtr)


[ClampInt]:     0x80257EA8  ;I: (word $a0 input, word $a1 lowerLimit, word $a2 upperLimit)      O: [word $v0]
[ClampFloat]:   0x80257ED8  ;I: (float $f12 input, float $f14 lowerLimit, float $a2 upperLimit) O: [float $f0]


[GetAngleBetween0And360]:   0x8025881C  ;I: ( float $f12 inputDegrees)                 O: [float $f0]
[RemainderFloat]:           0x802588D0  ;I: (float $f12 dividend, float $f14 divisor)  O: [float $f0]
[SelectMaxFloat]:           0x802588DC  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMinFloat]:           0x80258904  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMaxInt]:             0x8025892C  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[SelectMinInt]:             0x80258948  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[AbsFloat]:                 0x80258964  ;I: (float $f12)                               O: [float $f0]
[SumOfAbsXZ]:               0x80258994  ;I: (float* $a0 Xptr)                          O: [float $f0]
[AbsInt]:                   0x802589CC  ;I: (word $a0)                                 O: [word $v0]


[UpdatePlayerModelToMumboTransFormation]: 0x80291D04

[GetPlayerModel]:   0x80291FAC  ;Outputs:   [half $v0]
[SetPlayerTransparency]:    0x80291FB8 ;Inputs: (byte $a0 input)
[SetPlayerModel]:   0x80291FC4  ;Inputs: (half $a0 modelIndex)

[LockAllMoves]: 0x80295804
[SetMovesUnlockedBitfield]: 0x8029586C

[GetXZVelocity]: 0x80297AB8 ;Outputs: [float $f0]

[SetGravitationalAcceleration]:0x80297BEC

[SetMumboTransformation]: 0x8029A960

[TakeMeThere_LevelReset]:    0x802E4048  ;I: (word $a0 Map, word $a1 exit, word $a2 loadTransitionTypeIndex)
[TakeMeThere]:  0x802E4078  ;I: (word $a0 Map, word $a1 exit, word $a2 loadTransitionTypeIndex)


[Print_TotalMenuFont]: 0x802F7870 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)


[Print_CharFont]: 0x802F78FC ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[GetMainMapFromLevelIndex]: 0x8030ADD8;
[GetMainExitFromLevelIndex]: 0x8030AE24;

[PauseMenu]: 0x80313380


[GetJiggiesCollectedBitfield]:  0x80320F70  ;Outputs: [word $v0]


[IsJiggyCollected]:                 0x80320FF0  ;I: (word $a0 JiggyIndex)   O: [bool $v0]
[ZeroJiggyCollectedBitfield]:       0x8032103C
[SetJiggyCollectedBit]:             0x8032108C  ;I: (word $a0 JiggyIndex, bool $a1 collected)


[GetTotalJiggiesCollectedinLevel]:  0x803211AC  ;I: (byte $a0 LevelIndex)   O: [word $v0]
[GetTotalJiggiesCollected]:         0x8032123C  ;                           O: [word $v0]


[IsEmptyHoneycombCollected]:                0x803212E4  ;I: (word $a0 EmptyHoneycombIndex)  O: [bool $v0]
[ZeroEmptyHoneycombCollectedBitfield]:      0x80321340
[SetEmptyHoneycombCollectedBit]:            0x80321364  ;I: (word $a0 EmptyHoneycombIndex, bool $a1 collected)
[GetTotalEmptyHoneycombsCollectedInLevel]:  0x803213F8  ;I: (word $a0 levelIndex)           O: [byte $v0]
[GetTotalEmptyHoneycombsCollected]:         0x8032149C  ;                                   O: [byte $v0]


[IsMumboTokenCollected]:            0x80321364  ;Inputs: (word $a0 MumboTokenIndex) //Outputs: [bool $v0]
[ZeroMumboTokenCollectedBitfield]:  0x803215A0
[SetMumboTokenCollectedBit]:        0x803215D0  ;Inputs: (word $a0 MumboTokenIndex), (bool $a1 collected)
[GetTotalMumboTokensCollected]:     0x80321664  ;Outputs: [byte $v0]


[GetCurrentLevel]:  0x80321900  ;   O: [byte $v0]
[GetEnteringLevelFlag]: 0x8032190C  ;   O: [byte $v0]
[SetEnteringLevelFlag]: 0x80321918  ;I: (byte $a0 input)


[SpawnActor]: 0x8032813C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (float $a2 rotation)


//STRING LIBRARY
[AppendString]:     0x8033D660  ;I: (char* $a0 destStr, char* $a1 srcStr)
[AppendChar]:       0x8033D6A8  ;I: (char* $a0 destStr, char $a1 inputChar)
[FToA_2Dec]:        0x8033D6E0  ;I: (char* $a0 destStr, float $a1 inputFloat)
[FToA]:             0x8033D7B0  ;I: (char* $a0 destStr, float $a1 inputFloat, int $a2 float precision) //appends to destination string
[IToA_10]:          0x8033D884  ;I: (char* $a0 destStr, word $a1 inputInt) //base 10
[IToA]:             0x8033D884  ;I: (char* $a0 destStr, word $a1 inputInt), (word $a2 Radix)
[CompareStrings]:   0x8033D9D4  ;I: (char* $a0 str1, char* $a1 str2)    O: [byte $v0] //$v0 = 0 if (strings are the same),-1 if (str1 < str2), 1 if (str1 > str2)
[CopyString]:       0x8033DA54  ;I: (char* $a0 destStr, char* $a1 srcStr)
[GetStringSize]:    0x8033DA80  ;I: (char* $a0 string)                  O: [word $v0]
[DoTokensMatch]:    0x8033DAB0  ;I: (char* $a0 delimiter, char* $a1 str1, char* $a2 str2)   O: [bool $v0]
[NextTokenStart]:   0x8033DB18  ;I: (char* $a0 delimiter, char* $a1 str) O: [char* $v0]
[StrToken]:         0x8033DB60  ;I: (char* $a0 delimiter, char* $a1 destStr, char* $a2 srcStr)
[ToUpper]:          0x8033DBA4  ;I: (char* $a0 string)
