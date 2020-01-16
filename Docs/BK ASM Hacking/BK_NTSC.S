/*------------------------------
| Constants
-------------------------------*/
[Const_TeminalVelocity]: -4000
[Heap_addr]: 0x8002D500
[Lib_Data_addr]: 0x80275610
[Game_Eng_Data_addr]: 0x80363590
[Heap_size]: 0x210520
[Lid_Data_size]: 0x11980
[Game_Eng_Data_size]: 0x22E60

/*-------------------------------
| VARIABLES
---------------------------------*/
[P1NewlyPressedButtons]: 0x80281254
[RawP1Buttons]: 0x802812B8


[PauseMenuStringsBase]: 0x8036C4E0

[ObjectArrayPointer]: 0x8036E560

[PlayerPointer]: 0x8037BF20
[PlayerGrounded]: 0x8037BF60

[voidout_maxPos]: 0x8037C3C0
[voidout_minPos]: 0x8037C3CC

[XPos]: 0x8037C5A0

[XVelocity]: 0x8037C4B8

[SlopeTimer]: 0x8037C2E4

[MaxFallVelocity]: 0x8037C4EC

[MovementState]: 0x8037D164

[MapLoadState]: 0x8037E8F4
[Map]: 0x8037E8F5
[Exit]: 0x8037E8F6

[PauseMenuState]: 0x80383010

[GameProgressBitfield]:0x803831A8
[JiggyBitfield]: 0x803832C0
[EmptyHoneycombBitfield]: 0x803832E0
[MumboTokensBitfield]: 0x803832F0

[ReturnToLairEnabled]: 0x80383080

[ItemBase]: 0x80385F30

[NoteScore]: 0x80385FF0


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

[GetMaskedGlobalOnCounter]: 0x8023DB4C	;I:	(word $a0 bitMask)	O: [word $v0]
[GetGlobalOnCounter]: 0x8023DB5C ;O: [word $v0]
[ResetGlobalOnCounter]: 0x8023DB68

[IncrementGlobalOnCounter]: 0x8023DCDC
[DecrementGlobalOnCounter]: 0x8023DCF4
[Main]:	0x8023DD0C
[MainLoop]: 0x8023DF9C

[SetApplyButtonInputsToBanjoFlag]: 0x8023E06C

[NormalizeVector]: 0x80245FA4 ;I: (float* $a0 XPtr, float* $a1 YPtr, float* $a2 ZPtr)

[SetFrameSkip]: 0x8024BF94 ;I: (word $a0 input)
[GetFrameSkip]: 0x8024BFA0 ;O: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[GetFrameTimer]: 0x8024C4E8	;O: [word $v0]
[SetFrameTimer]: 0x8024C4F8	;I: (word $a0 input)

//NOTE: Camera_ is the render camera for Objects and Terrain containing Transparencies
[GetDistanceToCamera_]:	0x8024C584	;I: (float* $a0 destinationXPtr)

[GetCamera_Position]: 0x8024C5CC	;I:	(float* $a0 destinationXPtr)

[CopyCamera_XYZRotation]:	0x8024C764	;I: (float* $a0 destinationXPtr)
[GetCamera_YRotation]:		0x8024C788	;O: [float $f0]
[CopyCamera_XYZRotation_0]: 0x8024C794	;I: (float* $a0 destXPtr, float* $a1 destYPtr, float* $a2 destZPtr)

[SetCamera_XYZPosition]:	0x8024CD88	;I: (float* $a0 XPosPtr)
[SetCamera_XYZPosition_0]: 	0x8024CDB0	;I: (float* $a0 XPosPtr)
[SetCamera_XYZPosition_1]: 	0x8024CDF8	;I: (float $f12 XPos, float $f14 YPos, float $a2 ZPos)
[SetCamera_XYZRotation]:	0x8024CE18	;I: (float* $a0 XPosPtr)
[SetCamera_XYZRotation_0]:	0x8024CE40	;I: (float $f12 XPos, float $f14 YPos, float $a2 ZPos)

[GetFieldOfView]:   0x8024DDA8  ;O: [float $f0]
[SetFieldOfView]:   0x8024DDB4  ;I: (float $f12 input)
[GetAspectRatio]:   0x8024DDC0  ;O: [float $f0]

[UpdateButtonInputs]:	0x8024E7C8

[memcpy]: 0x80254608 ;I: (void * $a0 dest, void *a1 src, size_t $a2 size)
[IncreaseGlobalOnTimerby50]: 0x80254F90

[IncrementGlobalOnTimer]:	0x80255ACC

[ArcCos]:	0x80255D70	;I: (float $f12 input)	O: [ float $f0 ]

[CrossProduct]:	0x80255F74	;I: (float* $a0 resultXPtr, float* $a1 inputXPtr1, float* $a2 inputXPtr2 )
[GetPointIfTravelingScaledDistanceFromPointATowardsPointB]:	0x80255FE4	;I: (float* $a0 resultXPtr, float* $a1 pointAXPtr, float* $a2 pointBXPtr, float $a3 travelDistance)
[DotProduct]: 0x80256034	;I: (float* $a0 input1XPtr, float* $a1 input2XPtr)	O: [float $f0]
[GetDistance3D]: 0x80256064	;I: (float* $a0 input1XPtr, float* $a1 input2XPtr)	O: [float $f0]

[GetDistanceSquared3D]:	0x80256280	;I:	(float* $a0 input1XPtr, float* $a1 input2XPtr)	O: [float $f0]

[GetDistanceToOrigin3D]:	0x80256378	;I:	(float* $a0 inputXPtr)	O: [float $f0]

[ArcSin]:	0x80256FE0	;I: ( float $f12 inputDegrees )	O: [ float $f0 ]

[ClampInt]:     0x80257EA8  ;I: (word $a0 input, word $a1 lowerLimit, word $a2 upperLimit)      O: [word $v0]
[ClampFloat]:   0x80257ED8  ;I: (float $f12 input, float $f14 lowerLimit, float $a2 upperLimit) O: [float $f0]
[GetYRotationFromPointAToB]:	0x80257F18	;I: (float* $a0 pointAXPtr, float* $a1 BXPtr, float* $a2 result)

[IsAtOrigin]:			0x802582EC	;I:	(float* $a0 inputXPtr)	O: [byte $v0 bool]
[IsNotAtOrigin]:		0x80258368	;I:	(float* $a0 inputXPtr)	O: [byte $v0 bool]
[IsNotOnYAxisToOrigin]:	0x802583D8	;I:	(float* $a0 inputXPtr)	O: [byte $v0 bool]

[IsPointInRectVol]:		0x802584FC	;I: (float* $a0 inputXptr, float* $a1 minXPtr, float* $a2 maxXPtr)	O: [byte $v0 bool]

[GetDistanceSquared2D_XZ]:	0x802586B0	;I:	(float* $a0 input1XPtr, float* $a1 input2XPtr)	O: [float $f0]

[GetSumOfDifferencesSquared]:	0x80258780	;I:	(float* $a0 input1XPtr, float* $a1 input2XPtr)	O: [float $f0]

[GetAngleBetween0And360]:   0x8025881C  ;I: ( float $f12 inputDegrees)                 O: [float $f0]
[RemainderFloat]:           0x802588D0  ;I: (float $f12 dividend, float $f14 divisor)  O: [float $f0]
[SelectMaxFloat]:           0x802588DC  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMinFloat]:           0x80258904  ;I: (float $f12 input1, float $f14 input2)     O: [float $f0]
[SelectMaxInt]:             0x8025892C  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[SelectMinInt]:             0x80258948  ;I: (word $a0 input1, word $a1 input2)         O: [word $v0]
[AbsFloat]:                 0x80258964  ;I: (float $f12)                               O: [float $f0]
[SumOfAbsXZ]:               0x80258994  ;I: (float* $a0 Xptr)                          O: [float $f0]
[AbsInt]:                   0x802589CC  ;I: (word $a0)                                 O: [word $v0]

[ClearXYZData]:			0x80258B8C	;I: (float* $a0 xPtr)
[CopyXYZData]:			0x80258BA4 	;I: (float* $a0 destXPtr, float* $a1 srcXPtr)
[CopyXYZDifference]:	0x80258BC0	;I: (float* $a0 resultXPtr, float* $a1 minuendXPtr, float* $a2 subtraendXPtr)
[SubtractVectorXYZ]:	0x80258BF4	;I: (float* $a0 destMinuendXPtr, float* $a1 subtraendXPtr)
[SetXYZData]:			0x80258C28	;I: (float* $a0 destXPtr, float $a1 xInput, float $a2 yInput, float $a3 ZInput)
[CopyXYZSum]:			0x80258C48	;I: (float* $a0 destXPtr, float* $a1 src1XPtr, float* $a2 src2XPtr)
[ScaleXYZ]:				0x80258C7C	;I:	(float* $a0 XPtr, float $a1 scalingFactor)
[ScaleCopyXYZ]: 		0x80258CB0	;I:	(float *$a0 destXPtr, float* $a1 srcXPtr, float $a2 scalingFactor)
[SumOfAbsoluteValueXYZ]:	0x80258CDC	;I: (float* $a0 destAndSrc1Xptr, float* $a1 src2Ptr)
[ConvertXYZFloatToWord]:	0x80258D58 	;I: (word* $a0 destXPtr, float* srcXPtr)
[ConvertXYZFloatToHalf]:	0x80258DA8 	;I: (half* $a0 destXPtr, float* srcXPtr)
[TruncXYZFloatToWord]:	0x80258DE8	;I:	(word* $a0 destXPtr, float* srcXPtr)
[TruncXYZFloatToHalf]:	0x80258E24	;I: (half* $a0 destXPtr, float* srcXPtr)

[ClampToAbsValue_Float]:	0x80269190	;I: (float $f12 input, float $f14 clampValue)	O: [float $f0]
[GetDifferenceOfAngles]:	0x802591D8	;I:	(float $f12 minuend, float $f14 subtrend)	O: [float $f0]
[Are2PointsWithinDistance_2D_XZ]:	0x80259254	;I: (float* $a0 XPtr1, float $a1 X2, float $a2 Z2, float $a3 distance)	O: [byte $v0 bool]
[Are2PointsWithinDistance_2D_XZ_1]:	0x802592C4	;I: (float* $a0 XPtr1, float* $a1 XPtr2, float $a2 distance)	O: [byte $v0 bool]
[Are2PointsWithinDistance_2D_XZ_2]:	0x80259328	;I: (float* $a0 XPtr1, float* $a1 XPtr2, float $a2 distance)	O: [byte $v0 bool]
[Are2PointsWithinDistance]:			0x80259328	;I: (float* $a0 XPtr1, float* $a1 XPtr2, float $a2 distance)	O: [byte $v0 bool]

[DecrementTimerByOneFrame]:	0x8025943C	;I: ( float* $a0 timerPtr )

[SquareRoot]:	0x80265350	;I: (float $f12 input)	O: [float $f0]
[osDisableInt]: 0x8026ACB0
[osRestoreInt]: 0x8026ACD0

/* ****************
 * Movement Struct (size:0x28):
 * 0x00: [word]		AnimationStructPtr
 * 0x04: [float]	AnimationTimer
 * 0x08: [float]	???
 * 0x0C: [float]	MovementDuration
 * 0x10: [float]	AnimationDuration
 * 0x14: [float]	TransistionDuration
 * 0x18: [word?]	???
 * 0x1C: [word]		MovementState
 * 0x20: [byte]		MovementSubstate
 */
[SetMovementStruct_MovementState]:					0x80287460	;I: (struct* $a0 movementStruct, word $a1 input)
[GetMovementStruct_AnimationStructPtr]:				0x80287464	;I: (struct* $a0 movementStruct)	O: [word $v0]

[SetMovementStruct_AnimationStruct_AnimationTimer]:	0x8028764C	;I: (struct* $a0 movementStruct, float $a1 input)
[set_objMoveStruct_playType]:				        0x80287474	;I: (struct* $a0 movementStruct, byte $a1 input)
[SetMovementStruct_Byte_0x21]:						0x8028767C	;I: (struct* $a0 movementStruct, byte $a1 input)
[SetMovementStruct_Byte_0x22]:						0x80287684	;I: (struct* $a0 movementStruct, byte $a1 input)
[SetMovementStruct_AnimationDuration]:				0x8028768C	;I: (struct* $a0 movementStruct, float $a1 input)
[SetMovementStruct_TransitionDuration]:				0x802876C0	;I: (struct* $a0 movementStruct, float $a1 input)

[SetMovementStruct_AnimationStruct_AnimationState]:	0x80287790	;I:	(struct* $a0 movementStruct)	O: [word $v0]
[GetMovementStruct_MovementSubstate]:				0x802877B0	;I: (struct* $a0 movementStruct)	O: [byte $v0]
[GetMovementStruct_Byte_0x21]:						0x802877B8	;I: (struct* $a0 movementStruct)	O: [byte $v0]
[GetMovementStruct_Byte_0x22]:						0x802877C0	;I: (struct* $a0 movementStruct)	O: [byte $v0]
[GetMovementStruct_AnimationDuration]:				0x802877CC	;I: (struct* $a0 movementStruct)	O: [float $f0]
[GetMovementStruct_TransitionDuration]:				0x802877D0	;I: (struct* $a0 movementStruct)	O: [float $f0]
[GetMovementStruct_AnimationStruct_AnimationTimer]:	0x802877D8	;I: (struct* $a0 movementStruct)	O: [float $f0]
[GetMovementStruct_AnimationTimer]:					0x802877F8	;I: (struct* $a0 movementStruct)	O: [float $f0]
[SetMovementStruct_AnimationTimer]:					0x80287800	;I: (struct* $a0 movementStruct)	O: [float $f0]

[IsMovementStruct_MovementSubstate3]:				0x802878C4	;I: (struct* $a0 movementStruct, float $a1 input)


/* ****************
 * Animation Struct (size:0x24):
 * 0x00: [word]		???
 * 0x04: [word]		???
 * 0x08: [byte?]	???
 * 0x09: [byte?]	???
 * 0x0A: [half]		???
 * 0x0C: [half]		???
 * 0x0E: [half]		???
 * 0x10: [word]		AnimationState
 * 0x14: [float]	AnimationTimer
 * 0x18: [float]	???
 * 0x1C: [byte]     ???
 * 0x1D: [byte]		???
 * 0x1E: [byte]		???
 */
[SetTo1AnimationStruct_Byte_0x1C]:		0x80289674	;I:	(struct* $a0 animationStruct)
//[Get0x20]: 0x80289674
[GetAnimationStruct_AnimationState]:	0x80289688	;I: (struct* $a0 animationStruct)	O: [word $v0]
[GetAnimationStruct_AnimationTimer]:	0x80289690	;I: (struct* $a0 animationStruct)	O: [float $f0]
[GetAnimationStruct_Float_0x18]:		0x80289698	;I:	(struct* $a0 animationStruct)	O: [float $f0]

[SetAnimationStruct_AnimationState]:	0x8028977C	;I: (struct* $a0 animationStruct, word $a1 input)
[SetAnimationStruct_AnimationTimer]:	0x80289690	;I: (struct* $a0 animationStruct, float $a1 input)
[SetAnimationStruct_Word_0x00]:			0x80289790	;I: (struct* $a0 animationStruct, word $a1 input)
[SetAnimationStruct_Word_0x04]:			0x80289798	;I: (struct* $a0 animationStruct, word $a1 input)

[SetAnimationStruct_Float_0x18]:		0x802897C8	;I: (struct* $a0 animationStruct, float $a1 input)

[SetTo2ObjectAnimationStruct_Byte_0x1C]: 0x8028980C	;I:	(struct* $a0 animationStruct)
[SetPlayerBounceRate]:	0x80289820	;I:	(word $a0 input)

[UpdateMovementAnimationFrame]: 0x80289E00  ;

[GetPlayerBounceRate]:	0x80289EA4	;O:	[word $v0]
[SetLimitsOfPlayerWalkingCycleTime]: 0x80289EA8 ;I: (float $f12 minTime, float $f14 maxTime)

[SetPlayerBounceRate_0]:	0x80289F10	;I:	(word $a0 input)

[GetPlayerMovementStructPtr]:				0x80289F64	;O:	[struct* $v0]
[GetPlayerAnimationStruct_AnimationTimer]:	0x80289F70	;O: [float $a0]
[IsPlayerInAnimationState]:					0x80289F94	;I:	(word $a0 inputState)	O: [byte $v0 bool]
[IsPlayerMovementStruct_Substate3]:			0x80289FC4	;O:	[byte $vo bool]

[SetPlayerMovementState]:	0x8028A180	;I:	(word $a0 animationIndex, float $a1 animationDuration)

[GetBeakBargeUnlockedFlag]:			0x8028A960	;O: [word $v0]
[GetBeakBombUnlockedFlag]:			0x8028A980	;O: [word $v0]
[GetBeakBusterUnlockedFlag]:		0x8028A9A0	;O: [word $v0]
[GetCameraControlsUnlockedFlag]:	0x8028A9C0	;O: [word $v0]
[GetBearPunchUnlockedFlag]:			0x8028A9E0	;O: [word $v0]
[GetClimbTreesUnlockedFlag]:		0x8028AA00	;O: [word $v0]
[IsAbleToDive]:						0x8028AA20	;O:	[byte $v0 bool]
[GetEggMovesUnlockedFlag]:			0x8028AA98	;O: [word $v0]
[IsAbleToUseFeatheryFlap]:			0x8028AAB8	;O:	[byte $v0 bool]
[GetFlapFlipUnlockedFlag]:			0x8028AB08	;O: [word $v0]
[GetFlyingUnlockedFlag]:			0x8028AB28	;O: [word $v0]
[GetHoldAToJumpHigherUnlockedFlag]:	0x8028AB48	;O: [word $v0]
[IsAbleToUseFeatheryFlap]:			0x8028AB68	;O:	[byte $v0 bool]

[GetRollUnlockedFlag]:				0x8028AC18	;O: [word $v0]
[GetShockSpringJumpUnlockedFlag]:	0x8028AC38	;O: [word $v0]
[GetWadingBootsUnlockedFlag]:		0x8028AC58	;O: [word $v0]
[GetTalonTrotUnlockedFlag]:			0x8028AC78	;O: [word $v0]
[GetTalonTrotUnlockedFlag_0]:		0x8028AC98	;O: [word $v0]
[GetWonderWingUnlockedFlag]:		0x8028ACB8	;O: [word $v0]

[IsCurrentlyInTermiteMovementState]:	0x8028AD64	;O: [byte $v0 bool]
[IsCurrentlyInPumpkinMovementState]:	0x8028AD8C	;O: [byte $v0 bool]
[IsEnteringLevelOtherThanSM]:			0x8028ADBC	;O:	[byte $v0 bool]

[IsPlayerMoreThan60AboveGround]:	0x8028B094	;O: [byte $v0 bool]
[IsPlayerWithinDistanceOfPoint_XZ]: 0x8028B0E0  ;I: (float* $a0 pointXPtr, float $a1 distance)  O: [byte $v0 bool]
//[Get0]: 0x8028B120
[IsInSwampWaterOrSand]:	0x8028B128	;O: [byte $v0 bool]
[IsCurrentLevelRBB]:	0x8028B128	;O: [byte $v0 bool]

[IsInIceFrictionState]:	0x8028B2E8	;O: [byte $v0 bool]

[IsPlayerMovementStateinSwimmingSet]:	0x8028B470	;O: [byte $v0 bool]
[IsDifferenceBetweenMovingAndFacingAngleMoreThan135]:	0x8028B4C4	;O: [byte $v0 bool]
[IsPlayerInWater]:	0x8028B51C	;O: [byte $v0 bool]
[IsPlayerSwimming]:	0x8028B528	;O: [byte $v0 bool]

[SetPlayerAsGrounded]:	0x8028B6FC

[ObjectCollisionSwitchCases]:   0x8028B724

[UpdateItemAndEnemyCollision]:	0x8028D2E4

[SetCarriedObject_ModelIndex]:	0x8028D658	;I:	(word $a0 modelIndex)

[GetCarriedObject_ModelIndex]:	0x8028D670	;O:	[word $v0]

[SpawnAndCarryActor]: 0x8028DE0C ;I: (word $a0 ActorIndex), (float* $a1 LocationXPtr)

[IncrementAndDisplayCarriedObject]: 0x8028DF20

[SetCarriedItemCountToZeroAndDisplay]: 0x8028DFB8

[UpdateBanjo]:	0x8028E71C

[GetPlayerMovementStructPtr_0]:	0x8028E78C	;O:	[struct* $v0]

[GetMumboTransformation_0]:			0x8028E7CC	;O:	[byte $v0]
[GetClimbingPole_Bottom_Pos_0]:		0x8028E7EC	;I: (float* $a0 destXPtr)
[GetShoesTimer_0]:					0x8028E80C	;I:	(byte $a0 shoeIndex)	O: [float $f0]
[GetHeightOfGroundBeneathPlayer_0]:	0x8028E82C	;O: [float $f0]
[GetFloorObjectNormalRotation_0]:	0x8028E84C	;I: (float* $a0 destXPtr)
[GetCarriedObject_UnknownStruct2Ptr_0]:	0x8028E86C	;[struct* $v0]

[CopyXYZPosition_1]:    0x8028E9A4  ;I: (float* $a0 destXPtr)

[GetFacingAngle_1]: 0x8028EBA4  ;O: [float $f0]
[GetWalkingVelocity_1]: 0x8028EBC4  ;O: [float $f0]
[GetXRotation_1]:   0x8028EBE4  ;O: [float $f0]

[GetRotations]:  0x8028EC24    ;I: (float* $a0 DestinationXRot)

[GetMovingAngle_1]: 0x8028EF08  ;O: [float $f0]

[CopyXYZVelocity_1]: 0x8028EF70 ;I: (float* $a0 DestXPtr)

[IncrementAndDisplayCarriedObject_1]: 0x8028F030
[SetCarriedItemCountToZeroAndDisplay_1]: 0x8028F050
[IsPlayerAndShadowVisible]: 0x8028F070  ;O: [byte $v0 bool]

[IsMumboTransformBanjoOrWashingMachine]:    0x8028F0D4  ;O: [byte $v0 bool]
[InJiggyJigMovementState]:  0x8028F108  ;O: [byte $v0 bool]
[InMovementState0x0B]:  0x8028F140  ;O: [byte $v0 bool]
[GetPlayerIsVisibleFlag]:  0x8028F158  ;O: [byte $v0]
[InFirstPersonView]:  0x8028F170  ;O: [byte $v0 bool]
[GetSpecificMoveUnlockedFlag]:  0x8028F190  ;O: [byte $v0]

[GetPlayersShadowIsVisibleFlag]:  0x8028F1D4  ;O: [byte $v0]

[InDeathMovementState]: 0x8028F22C  ;O: [byte $v0 bool]

[IsPlayerSwimming_1]:   0x8028F2FC  ;O: [byte $v0 bool]

[UnlockMove]:   0x8028F3B8  ;I: (word $a0 moveUnlockedIndex)

[WritePlayerIsFrozenFlag]:  0x8028F7C8  ;I: (byte $a0 input)

[SetCurrentLevelMainMapAndExit_0]:	0x8028FA14	;I: (word $a0 MapIndex, word $a1 ExitIndex)

[SetXYZRotationTargets]:	0x8028FAEC	;I	(float* $a0 RotXPtr)
[ClearCarriedObjectBehaviorStructPointer]:	0x8028FB28

[TransformMe]: 0x8028FB88 ;I (byte $a0 transformationIndex)

[EnablePlayerIsVisibleFlag]:	0x8028FCAC
[ClearPlayerIsVisibleFlag]:	0x8028FCBC
[WritePlayerIsVisibleFlag_1]:	0x8028FCC8	;I: (byte $a0 input)

[ClearIdleTimerEnabledFlag]:	0x802900FC

[SetCameraZoomState]:	0x80290B60	;I: (byte $a0 input)

[UpdateCameraPositionRotationAndZoom]:	0x80291358
[GetCameraRotationState]:	0x8029147C	;O: [byte $v0]

[GetShoeTimer]:	0x80291670	;I: (byte $a0 shoeTimerIndex)	O: [float $f0]

[IsShoeTimerZero]:	0x80291698	;I: (byte $a0 shoeTimerIndex)	O: [byte $f0 bool]
[IsShoeTimerNotZero]:	0x802916CC	;I: (byte $a0 shoeTimerIndex)	O: [byte $f0 bool]
[IsValueBetweenShoeTimerAndTimerCopy]:	0x80291710	;I: (byte $a0 shoeTimerIndex, float $a1 input)	O: [byte $f0 bool]

[ClearShoeTimer]:	0x802917C4	;I: (byte $a0 shoeTimerIndex)
[SetShoeTimer]:	0x802917E4	;I: (byte $a0 shoeTimerIndex, float $a1 input)

[UpdatePlayerModelFacingAngle]: 0x802919F0

[UpdatePlayerModelToMumboTransFormation]: 0x80291D04

[GetPlayerModel]:        	0x80291FAC 	;O: [half $v0]
[SetPlayerTransparency]: 	0x80291FB8 	;I: (byte $a0 input)
[SetPlayerModel]:        	0x80291FC4 	;I: (half $a0 modelIndex)

[UpdateFacingAngleForDominantModelChange]:	0x80292090
[SetPlayerModelScale]:	0x802920FC	;I:	(float $f12 input)
[SetBanjoFacingAngle]:	0x80292134	;I:	(float $f12 input)

[IsMiscFlagCleared]: 0x802933D0 ;I:	(byte $a0 byteIndex)
[SetMiscFlag]: 0x802933E8 ;I: (byte $a0 byteIndex)

[IsButtonNewlyPressed]:     0x80295544  ;I: (byte $a0 ButtonIndex)  O: [Bool $v0]
[IsButtonNewlyReleased]:    0x80295560  ;I: (byte $a0 ButtonIndex)  O: [Bool $v0]
[GetButtonPressTimer]: 		0x8029557C 	;I: (byte $a0 ButtonIndex)
[GetButtonReleaseTimer]: 	0x80295590 	;I: (byte $a0 ButtonIndex)

[GetMovesUnlockedBitfield]: 0x802957F0 	;O: [word $v0]

[LockAllMoves]: 			0x80295804

[SetMovesUnlockedBitfield]: 0x80295864
[SetHasUsedMovesBitfield]:  0x80295870

[SetYVelocity]: 			0x802979A0 ;I: (float $f12)

[GetXZVelocity]: 			0x80297AB8 ;O: [float $f0]

[SetGravitationalAcceleration]: 0x80297BEC
[SetTerminalVelocity]:          0x80297BF8

[CopyXYZPosition]:			0x802984D4

[AddToYPos]: 				0x80298528 ;I: (float $f12)

[SetMovementState]: 0x8029A72C ;I: (byte $a0 movementStateIndex)

[SetMumboTransformation]: 	0x8029A960

[GetIdleMovementStateIndex]: 0x8029BF78

[TakeMeThere_LevelReset]: 	0x802E4048  ;I: (word $a0 Map, word $a1 exit, word $a2 loadTransitionTypeIndex)
[TakeMeThere]:            	0x802E4078  ;I: (word $a0 Map, word $a1 exit, word $a2 loadTransitionTypeIndex)


[Print_TotalMenuFont]: 		0x802F7870 ;I: (word $a0 XPos, word $a1 YPos, word $a3 fontSize, char* $a3 str)

[Print_CharFont]: 			0x802F78FC ;I: (word $a0 XPos, word $a1 YPos, char* $a2 str)
[Print_CharFont_Background]: 0x802F7938 ;I: (word $a0 XPos, word $a1 YPos, char* $a2 str)


[AddObjIDStructToObjectSpawnArray]: 0x803053E8

[GetLevelAssociatedWithMap]: 	0x8030AD48	;I: (byte $a0 MapIndex)	O: [byte $v0]

[GetMainMapFromLevelIndex]: 	0x8030ADD8	;I: (byte $a0 LevelIndex)	O:[byte $v0]
[GetMainExitFromLevelIndex]: 	0x8030AE24	;I: (byte $a0 LevelIndex)	O:[byte $v0]

[TimeToString]: 0x80311C64

[PauseMenu]: 0x80313380

[ClearAllGameProgress]: 0x8031FBA0

[ClearGameProgressFlags]: 0x8031FFAC
[SetGameProgressFlag]: 0x80320004 ;I: (byte $a0 flagIndex, bool $a1 value) 

[ClearSomeProgressThing]: 0x8032048C
[SetCheatFlag]: 0x803204E4

[GetJiggiesCollectedBitfield]:  0x80320F70  ;Outputs: [word $v0]

[IsJiggyCollected]:                 0x80320FF0  ;I: (word $a0 JiggyIndex)   O: [bool $v0]
[ZeroJiggyCollectedBitfield]:       0x8032103C
[SetJiggyCollectedBit]:             0x8032108C  ;I: (word $a0 JiggyIndex, bool $a1 collected)

[GetTotalJiggiesCollectedinLevel]:  0x803211AC  ;I: (byte $a0 LevelIndex)   O: [word $v0]
[GetTotalJiggiesCollected]:         0x8032123C  ;                           O: [word $v0]


[IsEmptyHoneycombCollected]:                0x803212E4  ;I: (word $a0 EmptyHoneycombIndex)  O: [bool $v0]
[ClearEmptyHoneyCombsCollectedBitfield]:    0x80321340
[ZeroEmptyHoneycombCollectedBitfield]:      0x80321340
[SetEmptyHoneycombCollectedBit]:            0x80321364  ;I: (word $a0 EmptyHoneycombIndex, bool $a1 collected)
[GetTotalEmptyHoneycombsCollectedInLevel]:  0x803213F8  ;I: (word $a0 levelIndex)           O: [byte $v0]
[GetTotalEmptyHoneycombsCollected]:         0x8032149C  ;                                   O: [byte $v0]


[IsMumboTokenCollected]:            0x80321544  ;Inputs: (word $a0 MumboTokenIndex) //Outputs: [bool $v0]
[ClearCollectedMumboTokenFlags]:    0x803215A0
[ZeroMumboTokenCollectedBitfield]:  0x803215A0
[SetMumboTokenCollectedBit]:        0x803215D0  ;Inputs: (word $a0 MumboTokenIndex), (bool $a1 collected)
[GetTotalMumboTokensCollected]:     0x80321664  ;Outputs: [byte $v0]


[GetCurrentLevel]:      0x80321900  ;   O: [byte $v0]
[GetEnteringLevelFlag]: 0x8032190C  ;   O: [byte $v0]
[SetEnteringLevelFlag]: 0x80321918  ;I: (byte $a0 input)


[SpawnActor]: 0x8032813C ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (float $a2 rotation)

[GetBehaviorStruct_ObjectStructOffset]: 0x80329958

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

[GetGameTimeScaleFactor]: 0x8033DD90 ;  O;[word $v0]

[SetGameSpeedCoefficient]: 0x8033DE20; I: (float $f12 gameSpeedCoefficient)

[GetItemCount]:         0x80345FA0 ;I: (byte $a0 itemIndex)
[ClearLevelNoteScores]: 0x80346D78

[SetAllLevelNotescoresTo100]: 0x80347018
[ClearInGameLevelTimer]: 0x80347060
[GetInGameTimeInSeconds]: 0x803470A0