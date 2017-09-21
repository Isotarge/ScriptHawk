
/*------------------------------
| Constants
-------------------------------*/
[Const_TeminalVelocity]: -3600

/*-------------------------------
| VARIABLES
---------------------------------*/
[P1NewlyPressedButtons]: 0x80281074
[RawP1Buttons]: 0x802810D8

[PauseMenuStringsBase]: 0x8036C99C

[PlayerPointer]: 0x8037C8F0
[PlayerGrounded]:0x8037C930

[XPos]: 0x8037CF70

[XVelocity]: 0x8037CE88

[SlopeTimer]: 0x8037CCB4

[MaxFallVelocity]: 0x8037CEBC

[MapLoadState]: 0x8037F2C4
[Map]: 0x8037F2C5
[Exit]: 0x8037F2C6

[PauseMenuState]: 0x803839F0

[GameProgressBitfield]: 0x80383B88
[JiggyBitfield]: 0x80383CA0
[EmptyHoneycombBitfield]: 0x80383CC0
[MumboTokensBitfield]: 0x80383CD0

[ReturnToLairEnabled]: 0x80383A60

[ItemBase]: 0x80386910

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

[GetMaskedGlobalOnCounter]: 0x8023E74C	;I:	(word $a0 bitMask)	O: [word $v0]
[GetGlobalOnCounter]: 0x8023E75C ;O: [word $v0]
[ResetGlobalOnCounter]: 0x8023E768

[IncrementGlobalOnCounter]: 0x8023E8E0
[DecrementGlobalOnCounter]: 0x8023E8F8
[Main]:	0x8023E910
[MainLoop]: 0x8023EBA0

[SetApplyButtonInputsToBanjoFlag]: 0x8023EC6C

[SetFrameSkip]: 0x8024BC00 ;I: (word $a0 input)
[GetFrameSkip]: 0x8024BC0C ;O: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[GetFrameTimer]: 0x8024C138	;O: [word $v0]
[SetFrameTimer]: 0x8024C148	;I: (word $a0 input)

[CopyCameraXYZRotation]: 0x8024C3B4 ;Inputs: (float* $a0 destinationXPtr)
[GetCamera_YRotation]: 0x8024C3D8 ;Outputs: [float $f0]


[SetCamera_XYZPosition]: 0x8024C9D8 ;Inputs: (float* $a0 xPosPtr)


[ClampInt]:     0x80257AF8  ;I: (word $a0 input, word $a1 lowerLimit, word $a2 upperLimit)      O: [word $v0]
[ClampFloat]:   0x80257B28  ;I: (float $f12 input, float $f14 lowerLimit, float $a2 upperLimit) O: [float $f0]


[GetAngleBetween0And360]:   0x8025846C  ;I: ( float $f12 inputDegrees)                 O: [float $f0]
[RemainderFloat]:           0x80258500  ;I: (float $f12 dividend, float $f14 divisor)  O: [float $f0]
[SelectMaxFloat]:           0x8025852C  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMinFloat]:           0x80258554  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMaxInt]:             0x8025857C  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[SelectMinInt]:             0x80258598  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[AbsFloat]:                 0x802585B4  ;I: (float $f12)                               O: [float $f0]
[SumOfAbsXZ]:               0x802585E4  ;I: (float* $a0 Xptr)                          O: [float $f0]
[AbsInt]:                   0x8025861C  ;I: (word $a0)                                 O: [word $v0]

[SpawnAndCarryActor]: 0x8028DC2C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr)

[UpdateBanjo]:	0x8028E53C

[GetPlayerMovementStructPtr_0]:	0x8028E5AC	;O:	[struct* $v0]

[GetMumboTransformation_0]:			0x8028E5EC	;O:	[byte $v0]
[GetClimbingPole_Bottom_Pos_0]:		0x8028E60C	;I: (float* $a0 destXPtr)
[GetShoesTimer_0]:					0x8028E62C	;I:	(byte $a0 shoeIndex)	O: [float $f0]
[GetHeightOfGroundBeneathPlayer_0]:	0x8028E64C	;O: [float $f0]
[GetFloorObjectNormalRotation_0]:	0x8028E66C	;I: (float* $a0 destXPtr)
[GetCarriedObject_UnknownStruct2Ptr_0]:	0x8028E68C	;[struct* $v0]

[TransformMe]: 0x8028F9A8 ;I (byte $a0 transformationIndex)


[UpdatePlayerModelToMumboTransFormation]: 0x80291B24

[GetPlayerModel]:        	0x80291DCC 	;O: [half $v0]
[SetPlayerTransparency]: 	0x80291DD8 	;I: (byte $a0 input)
[SetPlayerModel]:        	0x80291DE4 	;I: (half $a0 modelIndex)


[SetMiscFlag]: 0x80293208 ;I: (byte $a0 byteIndex)

[GetButtonPressTimer]: 		0x8029539C 	;I: (byte $a0 ButtonIndex)
[GetButtonReleaseTimer]: 	0x802953B0 	;I: (byte $a0 ButtonIndex)

[GetMovesUnlockedBitfield]: 0x80295630 	;O: [word $a0]

[LockAllMoves]: 			0x80295644

[SetMovesUnlockedBitfield]: 0x802956A4
[SetHasUsedMovesBitfield]:  0x802956B0

[SetYVelocity]: 			0x802977E0 ;I: (float $f12)

[GetXZVelocity]: 			0x802978F8 ;O: [float $f0]

[SetGravitationalAcceleration]: 0x80297A2C
[SetTerminalVelocity]:          0x80297A38

[AddToYPos]: 				0x80298368 ;I: (float $f12)

[SetMumboTransformation]: 	0x8029A79C

[TakeMeThere_LevelReset]: 	0x802E4238  ;I: (word $a0 Map, word $a1 exit, word $a2 loadTransitionTypeIndex)
[TakeMeThere]:            	0x802E4268  ;I: (word $a0 Map, word $a1 exit, word $a2 loadTransitionTypeIndex)


[Print_TotalMenuFont]: 		0x802F7A50 ;I: (word $a0 XPos, word $a1 YPos, word $a3 fontSize, char* $a3 str)

[Print_CharFont]: 			0x802F7ADC ;I: (word $a0 XPos, word $a1 YPos, char* $a2 str)
[Print_CharFont_Background]: 0x802F7BB0 ;I: (word $a0 XPos, word $a1 YPos, char* $a2 str)

[GetLevelAssociatedWithMap]: 	0x8030AEE8	;I: (byte $a0 MapIndex)	O: [byte $v0]

[GetMainMapFromLevelIndex]: 	0x8030AF78	;I: (byte $a0 LevelIndex)	O:[byte $v0]
[GetMainExitFromLevelIndex]: 	0x8030AFC4	;I: (byte $a0 LevelIndex)	O:[byte $v0]


[TimeToString]: 0x80311EB0

[PauseMenu]: 0x803136B4

[ClearAllGameProgress]: 0x8031FF90

[ClearGameProgressFlags]: 0x8032039C
[SetGameProgressFlag]: 0x803203F4 ;I: (byte $a0 flagIndex, bool $a1 value)

[ClearSomeProgressThing]: 0x8032087C
[SetCheatFlag]: 0x803208D4

[GetJiggiesCollectedBitfield]:  0x80321360  ;Outputs: [word $v0]

[IsJiggyCollected]:                 0x803213D0  ;I: (word $a0 JiggyIndex)   O: [bool $v0]
[ZeroJiggyCollectedBitfield]:       0x8032142C
[SetJiggyCollectedBit]:             0x8032147C  ;I: (word $a0 JiggyIndex, bool $a1 collected)

[GetTotalJiggiesCollectedinLevel]:  0x8032159C  ;I: (byte $a0 LevelIndex)   O: [word $v0]
[GetTotalJiggiesCollected]:         0x8032162C  ;                           O: [word $v0]


[IsEmptyHoneycombCollected]:                0x803216D4  ;I: (word $a0 EmptyHoneycombIndex)  O: [bool $v0]
[ClearEmptyHoneyCombsCollectedBitfield]:    0x80321730
[ZeroEmptyHoneycombCollectedBitfield]:      0x80321730
[SetEmptyHoneycombCollectedBit]:            0x80321754  ;I: (word $a0 EmptyHoneycombIndex, bool $a1 collected)
[GetTotalEmptyHoneycombsCollectedInLevel]:  0x803217E8  ;I: (word $a0 levelIndex)           O: [byte $v0]
[GetTotalEmptyHoneycombsCollected]:         0x8032188C  ;                                   O: [byte $v0]


[IsMumboTokenCollected]:            0x80321934  ;Inputs: (word $a0 MumboTokenIndex) //Outputs: [bool $v0]
[ClearCollectedMumboTokenFlags]:    0x80321990
[ZeroMumboTokenCollectedBitfield]:  0x80321990
[SetMumboTokenCollectedBit]:        0x803219C0  ;Inputs: (word $a0 MumboTokenIndex), (bool $a1 collected)
[GetTotalMumboTokensCollected]:     0x80321A54  ;Outputs: [byte $v0]


[GetCurrentLevel]:      0x80321CF0  ;   O: [byte $v0]
[GetEnteringLevelFlag]: 0x80321CFC  ;   O: [byte $v0]
[SetEnteringLevelFlag]: 0x80321D08  ;I: (byte $a0 input)


[SpawnActor]: 0x80328594 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (float $a2 rotation)


//STRING LIBRARY
[AppendString]:     0x8033DAB0  ;I: (char* $a0 destStr, char* $a1 srcStr)
[AppendChar]:       0x8033DAF8  ;I: (char* $a0 destStr, char $a1 inputChar)
[FToA_2Dec]:        0x8033DB30  ;I: (char* $a0 destStr, float $a1 inputFloat)
[FToA]:             0x8033DC00  ;I: (char* $a0 destStr, float $a1 inputFloat, int $a2 float precision) //appends to destination string
[IToA_10]:          0x8033DCD4  ;I: (char* $a0 destStr, word $a1 inputInt) //base 10
[IToA]:             0x8033DCF4  ;I: (char* $a0 destStr, word $a1 inputInt), (word $a2 Radix)
[CompareStrings]:   0x8033DE24  ;I: (char* $a0 str1, char* $a1 str2)    O: [byte $v0] //$v0 = 0 if (strings are the same),-1 if (str1 < str2), 1 if (str1 > str2)
[CopyString]:       0x8033DEA4  ;I: (char* $a0 destStr, char* $a1 srcStr)
[GetStringSize]:    0x8033DED0  ;I: (char* $a0 string)                  O: [word $v0]
[DoTokensMatch]:    0x8033DF00  ;I: (char* $a0 delimiter, char* $a1 str1, char* $a2 str2)   O: [bool $v0]
[NextTokenStart]:   0x8033DF68  ;I: (char* $a0 delimiter, char* $a1 str) O: [char* $v0]
[StrToken]:         0x8033DFB0  ;I: (char* $a0 delimiter, char* $a1 destStr, char* $a2 srcStr)
[ToUpper]:          0x8033DFF4  ;I: (char* $a0 string)

[GetGameTimeScaleFactor]: 0x8033E1E0 ;  O;[word $v0]
[SetGameSpeedCoefficient]: 0x8033E270; I: (float $f12 gameSpeedCoefficient)

[ClearLevelNoteScores]: 0x803471C8

[ClearInGameLevelTimer]: 0x803474B0
[GetInGameTimeInSeconds]: 0x803474F0