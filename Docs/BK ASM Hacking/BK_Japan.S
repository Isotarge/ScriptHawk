/*-------------------------------
| VARIABLES
---------------------------------*/
[PauseMenuStringsBase]: 0x8036CAF0

[PlayerPointer]: 0x8037CA20

[XPos]: 0x8037D0A0

[XVelocity]: 0x8037CFB8

[SlopeTimer]: 0x8037CDE4

[MapLoadState]: 0x8037F404
[Map]: 0x8037F405
[Exit]: 0x8037F406

[PauseMenuState]: 0x80383B50

[ReturnToLairEnabled]: 0x80383BC0

[ItemBase]: 0x80386A70

/*-------------------------------
| Functions
---------------------------------*/
/*
	NOTE: Consecutive functions identify no unknown functions in between
	NOTE 2: If inputs or outputs are not listed, assume they are void
*/

[GetPIStatusReg]: 0x800020E0 ;O: [word $v0]

[SetCOP0StatusRegister]: 0x80002190 ;I: (word $a0 input)
[GetCOP0StatusRegister]: 0x800021A0 ;O: [word $v0]

[SetStatusRegister]: 0x80003FE0 ;I: (word $a0 input)

[GetMaskedGlobalOnCounter]: 0x8023D7AC	;I:	(word $a0 bitMask)	O: [word $v0]
[GetGlobalOnCounter]: 0x8023D7BC ;O: [word $v0]
[ResetGlobalOnCounter]: 0x8023D7C8

[IncrementGlobalOnCounter]: 0x8023D93C
[DecrementGlobalOnCounter]: 0x8023D954
[Main]:	0x8023D96C
[MainLoop]: 0x8023DBFC

[SetApplyButtonInputsToBanjoFlag]: 0x8023DCCC

[SetFrameSkip]: 0x8024AD18 ;I: (word $a0 input)
[GetFrameSkip]: 0x8024AD24 ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[GetFrameTimer]: 0x8024B238	;O: [word $v0]
[SetFrameTimer]: 0x8024B248	;I: (word $a0 input)

[CopyCameraXYZRotation]: 0x8024B4B4 ;Inputs: (float* $a0 destinationXPtr)
[GetCamera_YRotation]: 0x8024B4D8 ;Outputs: [float $f0]

[SetCamera_XYZPosition]: 0x8024BAD8 ;Inputs: (float* $a0 xPosPtr)

[ClampInt]:     0x80256BF8  ;I: (word $a0 input, word $a1 lowerLimit, word $a2 upperLimit)      O: [word $v0]
[ClampFloat]:   0x80256C28  ;I: (float $f12 input, float $f14 lowerLimit, float $a2 upperLimit) O: [float $f0]

[GetAngleBetween0And360]:   0x8025756C  ;I: ( float $f12 inputDegrees)                 O: [float $f0]
[RemainderFloat]:           0x80257600  ;I: (float $f12 dividend, float $f14 divisor)  O: [float $f0]
[SelectMaxFloat]:           0x8025762C  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMinFloat]:           0x80257654  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMaxInt]:             0x8025767C  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[SelectMinInt]:             0x80257698  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[AbsFloat]:                 0x802576B4  ;I: (float $f12)                               O: [float $f0]
[SumOfAbsXZ]:               0x802576E4  ;I: (float* $a0 Xptr)                          O: [float $f0]
[AbsInt]:                   0x8025771C  ;I: (word $a0)                                 O: [word $v0]

[SpawnAndCarryActor]: 0x8028CC6C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr)

[GetXZVelocity]: 0x80296958 ;Outputs: [float $f0]

[Print_TotalMenuFont]: 0x802F6CA4 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)

[Print_CharFont]: 0x802F6D30 ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[PauseMenu]: 0x80312B88

[ClearAllGameProgress]: 0x80320010

[ClearGameProgressFlags]: 0x8032041C

[ClearSomeProgressThing]: 0x803208FC

[GetJiggiesCollectedBitfield]:  0x803213E0  ;Outputs: [word $v0]

[IsJiggyCollected]:                 0x80321450  ;I: (word $a0 JiggyIndex)   O: [bool $v0]
[ZeroJiggyCollectedBitfield]:       0x803214AC
[SetJiggyCollectedBit]:             0x803214FC  ;I: (word $a0 JiggyIndex, bool $a1 collected)

[GetTotalJiggiesCollectedinLevel]:  0x8032161C  ;I: (byte $a0 LevelIndex)   O: [word $v0]
[GetTotalJiggiesCollected]:         0x803216AC  ;                           O: [word $v0]


[IsEmptyHoneycombCollected]:                0x80321754  ;I: (word $a0 EmptyHoneycombIndex)  O: [bool $v0]
[ClearEmptyHoneyCombsCollectedBitfield]:    0x803217B0
[ZeroEmptyHoneycombCollectedBitfield]:      0x803217B0
[SetEmptyHoneycombCollectedBit]:            0x803217D4  ;I: (word $a0 EmptyHoneycombIndex, bool $a1 collected)
[GetTotalEmptyHoneycombsCollectedInLevel]:  0x80321868  ;I: (word $a0 levelIndex)           O: [byte $v0]
[GetTotalEmptyHoneycombsCollected]:         0x8032190C  ;                                   O: [byte $v0]


[IsMumboTokenCollected]:            0x803219B4  ;Inputs: (word $a0 MumboTokenIndex) //Outputs: [bool $v0]
[ClearCollectedMumboTokenFlags]:    0x80321A10
[ZeroMumboTokenCollectedBitfield]:  0x80321A10
[SetMumboTokenCollectedBit]:        0x80321A40  ;Inputs: (word $a0 MumboTokenIndex), (bool $a1 collected)
[GetTotalMumboTokensCollected]:     0x80321AD4  ;Outputs: [byte $v0]


[GetCurrentLevel]:      0x80321D70  ;   O: [byte $v0]
[GetEnteringLevelFlag]: 0x80321D7C  ;   O: [byte $v0]
[SetEnteringLevelFlag]: 0x80321D88  ;I: (byte $a0 input)


[SpawnActor]: 0x803285C4 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (float $a2 rotation)


//STRING LIBRARY
[AppendString]:     0x8033DAE0  ;I: (char* $a0 destStr, char* $a1 srcStr)
[AppendChar]:       0x8033DB28  ;I: (char* $a0 destStr, char $a1 inputChar)
[FToA_2Dec]:        0x8033DB30  ;I: (char* $a0 destStr, float $a1 inputFloat)
[FToA]:             0x8033DC30  ;I: (char* $a0 destStr, float $a1 inputFloat, int $a2 float precision) //appends to destination string
[IToA_10]:          0x8033DD04  ;I: (char* $a0 destStr, word $a1 inputInt) //base 10
[IToA]:             0x8033DD24  ;I: (char* $a0 destStr, word $a1 inputInt), (word $a2 Radix)
[CompareStrings]:   0x8033DE54  ;I: (char* $a0 str1, char* $a1 str2)    O: [byte $v0] //$v0 = 0 if (strings are the same),-1 if (str1 < str2), 1 if (str1 > str2)
[CopyString]:       0x8033DED4  ;I: (char* $a0 destStr, char* $a1 srcStr)
[GetStringSize]:    0x8033DF00  ;I: (char* $a0 string)                  O: [word $v0]
[DoTokensMatch]:    0x8033DF30  ;I: (char* $a0 delimiter, char* $a1 str1, char* $a2 str2)   O: [bool $v0]
[NextTokenStart]:   0x8033DF98  ;I: (char* $a0 delimiter, char* $a1 str) O: [char* $v0]
[StrToken]:         0x8033DFE0  ;I: (char* $a0 delimiter, char* $a1 destStr, char* $a2 srcStr)
[ToUpper]:          0x8033E024  ;I: (char* $a0 string)


[ClearLevelNoteScores]: 0x80347298

[ClearInGameLevelTimer]: 0x80347580