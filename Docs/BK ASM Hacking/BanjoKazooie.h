/*---------------------------------------
| BanjoKazooie.h
| Authors: Michael "Mittenz" Salino-Hugg
|
| 
\----------------------------------------*/

//version of BK you're using needs to be defined at the top of your C program before including this library:
//Syntax: #define BK_VERSION BK_???
//Valid version options: BK_NTSC, BK_NTSC_REV_A, BK_PAL, BK_NTSC_J

#ifndef BK_H
#define BK_H
#include <stdint.h>
#include <stdbool.h>

/*enumerations*/



/*function pointer typeDefs*/
typedef uint32_t (*bkGetPIStatusRegProc)(void);

typedef void (*bkSetCOP0StatusRegProc)(uint32_t input);
typedef uint32_t (*bkGetCOP0StatusRegProc)(void);

typedef void (*bkSetStatusRegProc)(uint32_t input);

typedef uint32_t (*bkGetMaskedGlobalOnCounterProc)(uint32_t mask);
typedef uint32_t (*bkGetGlobalOnCounterProc)(void);
typedef void (*bkResetGlobalOnCounterProc)(void);

typedef void (*bkIncrementGlobalOnCounterProc)(void);
typedef void (*bkDecrementGlobalOnCounterProc)(void);

typedef void (*bkSetApplyButtonInputsToBanjoFlagProc)(void);

typedef void (*bkSetFrameSkipProc)(uint32_t input);
typedef uint32_t (*bkGetFrameSkipProc)(void);

typedef void (*bkUpdateButtonInputsProc)(void);

typedef float (*bkArcCosProc)(float input);

typedef float (*bkDotProductProc)(float* input1XPtr, float* input2XPtr);
typedef float (*bkGetDistance3DProc)(float* input1XPtr, float* input2XPtr);

typedef float (*bkGetDistanceSquared3DProc)(float* input1XPtr, float* input2Ptr);

typedef float (*bkGetDistanceToOrigin3DProc)(float* inputXPtr);

typedef float (*bkArcSinProc)(float input);

typedef uint32_t (*bkClampIntProc)(uint32_t input, uint32_t lowerLimit, uint32_t upperLimit);
typedef float (*bkClampFloatProc)(float input, float lowerLimit, float upperLimit);

typedef float (*bkGetAngleBetween0And360Proc)(float input);
typedef float (*bkRemainderFloatProc)(float input);
typedef float (*bkSelectMaxFloatProc)(float input1, float input2);
typedef float (*bkSelectMinFloatProc)(float input1, float input2);
typedef int32_t (*bkSelectMaxIntProc)(int32_t input1, int32_t input2);
typedef int32_t (*bkSelectMinIntProc)(int32_t input1, int32_t input2);
typedef float (*bkAbsFloatProc)(float input);
typedef float (*bkSumOfAbsXZProc)(float* Xptr);
typedef int32_t (*bkAbsIntProc)(int32_t input);

typedef void (*bkClearXYZDataProc)(float* XPtr);
typedef void (*bkCopyXYZDataProc)(float* destXPtr, float* srcXPtr);
typedef void (*bkSaveXYZDiffernceProc)(float* resultXPtr, float* minuendXPtr, float* subtrahendXPtr);
typedef void (*bkSubtractVectorXYZProc)(float* destAndSrc1XPtr, float* src2XPtr);
typedef void (*bkSetXYZDataProc)(float* destXPtr, float XInput, float YInput, ZInput);
typedef void (*bkAddVectorYXZProc)(float* destAndSrc1XPtr, float* src2XPtr);
typedef void (*bkScaleXYZDataProc)(float* XPtr, float scalingFactor);
typedef void (*bkScaleCopyXYZDataProc)(float* destXPtr, float* srcXPtr, float scalingFactor);
typedef void (*bkSumOfAbsValuesXYZProc)(float* destAndSrc1XPtr, float* src2XPtr);
typedef void (*bkConvertXYZFloatToWordProc)(int32_t* destXPtr, float* srcXPtr);
typedef void (*bkConvertXYZFloatToHalfProc)(int16_t* destXPtr, float* srcXPtr);
typedef void (*bkTruncXYZFloatToWordProc)(int32_t* destXPtr, float* srcXPtr);
typedef void (*bkTruncXYZFloatToHalfProc)(int16_t* destXPtr, float* srcXPtr);

typedef float (*bkDifferenceOfAnglesProc)(float input1, float input2);

typedef void (*bkDecrementTimerBy1FrameProc)(float* timerPtr);

typedef float (*bkSquareRootProc)(float input);

typedef uint32_t (*GetPlayerPointerProc)(void);

typedef bool (*bkGetBeakBargeUnlockedFlagProc)(void);
typedef bool (*bkGetBeakBombUnlockedFlagProc)(void);
typedef bool (*bkGetBeakBusterUnlockedFlagProc)(void);
typedef bool (*bkGetCameraControlsUnlockedFlagProc)(void);
typedef bool (*bkGetBearPunchUnlockedFlagProc)(void);
typedef bool (*bkGetClimbTreesUnlockedFlagProc)(void);

typedef bool (*bkGetEggMovesUnlockedFlagProc)(void);

typedef bool (*bkGetFlapFlipUnlockedFlagProc)(void);
typedef bool (*bkGetFlyingUnlockedFlagProc)(void);
typedef bool (*bkGetHoldAToJumpHigherUnlockedFlagProc)(void);

typedef bool (*bkGetRollUnlockedFlagProc)(void);
typedef bool (*bkGetShockSpringJumpUnlockedFlagProc)(void);
typedef bool (*bkGetWadingBootsUnlockedFlagProc)(void);
typedef bool (*bkGetTalonTrotUnlockedFlagProc)(void);
typedef bool (*bkGetTalonTrotUnlockedFlag_copyProc)(void);
typedef bool (*bkGetWonderWingUnlockedFlagProc)(void);

typedef bool (*bkIsCurrentlyInTermiteMoveSetProc)(void);
typedef bool (*bkIsCurrentlyInPumpkinMoveSetProc)(void);

typedef bool (*bkIsPlayerGT60AboveGroundProc)(void);

typedef bool (*bkIsCurrentLevelRBBProc)(void);
    
typedef bool (*bkIsPlayerInWaterProc)(void);
typedef bool (*bkIsPlayerSwimmingProc)(void);

typedef void (*bkUpdateBanjoProc)(void);

typedef void (*bkPrint_ScalableEggFontProc)(int32_t XPos, int32_t YPos, char* string, float size);
typedef void (*bkPrint_HUDEggFontProc)(int32_t XPos, int32_t YPos, char* string);
typedef void (*bkPrint_CharFontProc)(int32_t XPos, int32_t YPos, char* string);
typedef void (*bkPrint_CharFontWithBGProc)(int32_t XPos, int32_t YPos, char* string);
typedef void (*bkPrint_FadingCharFontProc)(int32_t XPos, int32_t YPos, char* string);

typedef void (*bkSpawnActorProc)(uint32_t actorIndex, float* locationPtr, float rotaion);

typedef void (*bkAppendStringProc)(char* destStr, char* tagOnStr);
typedef void (*bkAppendCharProc)(char* destStr, char inputChar);
typedef void (*bkFToA_prec2Proc)(char* destStr, float input);
typedef void (*bkFToAProc)(char* destStr, float input, uint32_t precision);
typedef void (*bkIToA_base10Proc)(char* destStr, int32_t input);
typedef void (*bkIToAProc)(char* destStr, int32_t input, uint32_t radix);
typedef int32_t (*bkCompareStringsProc)(char* str1, char* str2);
typedef void (*bkCopyStringProc)(char* destStr, char* srcStr);
typedef uint32_t (*bkGetStringSizeProc)(char* string);

typedef void (*bkToUpperProc)(char* string);



#ifndef BK_VERSION
    #error "Version of Banjo-Kazooie no Defined. See 1st comment in BanjoKazooie.h." 
#else
    /*---------------------------------\
    | NTSC                             |
    \---------------------------------*/
    #if BK_VERSION == BK_NTSC
        //all NTSC specific definitions

        //Variables
        #define slope_timer_addr        0x8037C2E4

        //FUNCTIONS
        #define bkGetPIStatusReg        ((bkGetPIStatusRegProc)     0x8000210C)

        #define bkSetCOP0StatusReg      ((bkSetCOP0StatusRegProc)   0x80002190)
        #define bkGetCOP0StatusReg      ((bkGetCOP0StatusRegProc)   0x800021A0)

        #define bkSetStatusReg          ((bkSetStatusRegProc)       0x80003FE0)

        #define bkGetMaskedGlobalOnCounter   ((bkGetMaskedGlobalOnCounterProc)    0x8023DB4C)
        #define bkGetGlobalOnCounter    ((bkGetGlobalOnCounterProc) 0x8023DB5C)
        #define bkResetGlobalOnCounter  ((bkResetGlobalOnCounterProc)   0x8023DB68)

        #define bkIncrementGlobalOnCounter ((bkIncrementGlobalOnCounterProc) 0x8023DCDC)
        #define bkDecrementGlobalOnCounter  ((bkDecrementGlobalOnCounterProc)   0x8023DCF4)

        #define bkSetApplyButtonInputsToBanjoFlag ((bkSetApplyButtonInputsToBanjoFlagProc) 0x8023E06C)

        #define bkSetFrameSkip          ((bkSetFrameSkipProc)       0x8024BF94)
        #define bkGetFrameSkip          ((bkGetFrameSkipProc)       0x8024BFA0)

        #define bkUpdateButtonInputs    ((bkUpdateButtonInputsProc) 0x8024E7C8)

        #define bkArcCos                ((bkArcCosProc)             0x80255D70)

        #define bkDotProduct            ((bkDotProductProc)         0x80256034)
        #define bkGetDistance3D         ((bkGetDistance3DProc)      0x80256064)

        #define bkGetDistanceSquared3D  ((bkGetDistanceSquared3DProc)   0x80256280)
        
        #define bkGetDistanceToOrigin3D ((bkGetDistanceToOrigin3DProc)  0x80256378)

        #define bkArcSin                ((bkArcSinProc)             0x80256FE0)

        #define bkClampInt              ((bkClampIntProc)           0x80257EA8)
        #define bkClampFloat            ((bkClampFloatProc)         0x80257ED8)
        
        #define bkGetAngleBetween0And360    ((bkGetAngleBetween0And360Proc) 0x8025881C)
        #define bkRemainderFloat        ((bkRemainderFloatProc)     0x802588D0)
        #define bkSelectMaxFloat        ((bkSelectMaxFloatProc)     0x802588DC)
        #define bkSelectMinFloat        ((bkSelectMinFloatProc)     0x80258904)
        #define bkSelectMaxInt          ((bkSelectMaxIntProc)       0x8025892C)
        #define bkSelectMinInt          ((bkSelectMinIntProc)       0x80258948)
        #define bkAbsFloat              ((bkAbsFloatProc)           0x80258964)
        #define bkSumOfAbsXZ            ((bkSumOfAbsXZProc)         0x80258994)
        #define bkAbsInt                ((bkAbsIntProc)             0x802589CC)
        
        #define bkClearXYZData          ((bkClearXYZDataProc)       0x80258B8C)
        #define bkCopyXYZData           ((bkCopyXYZDataProc)        0x80258BA4)
        #define bkSaveXYZDiffernce      ((bkSaveXYZDiffernceProc))  0x80258BC0)
        #define bkSubtractVectorXYZ     ((bkSubtractVectorXYZProc)) 0x80258BF4)
        #define bkSetXYZData            ((bkSetXYZDataProc)         0x80258C28)
        #define bkAddVectorXYZ          ((bkAddVectorYXZProc)       0x80258C48)
        #define bkScaleXYZData          ((bkScaleXYZDataProc)       0x80258C7C)
        #define bkScaleCopyXYZData      ((bkScaleCopyXYZDataProc))  0x80258CB0)
        #define bkSumOfAbsValuesXYZ     ((bkSumOfAbsValuesXYZProc)  0x80258CDC)
        #define bkConvertXYZFloatToWord ((bkConvertXYZFloatToWordProc)  0x80258D68)
        #define bkConvertXYZFloatToHalf ((bkConvertXYZFloatToHalfProc)  0x80258DA8)
        #define bkTruncXYZFloatToWord   ((bkTruncXYZFloatToWordProc)    0x80258DE8)
        #define bkTruncXYZFloatToHalf   ((bkTruncXYZFloatToHalfProc)    0x80258E24)

        #define bkDifferenceOfAngles    ((bkDifferenceOfAnglesProc) 0x802591D8)

        #define bkDecrementTimerBy1Frame    ((bkDecrementTimerBy1FrameProc) 0x80259430)

        #define bkSquareRoot            ((bkSquareRootProc)         0x80265350)

        #define bkGetPlayerPointer      ((bkGetPlayerPointerProc)   0x80289F64)
        
        #define bkGetBeakBargeUnlockedFlag  ((bkGetBeakBargeUnlockedFlagProc)   0x8028A960)
        #define bkGetBeakBombUnlockedFlag   ((bkGetBeakBombUnlockedFlagProc)    0x8028A980)
        #define bkGetBeakBusterUnlockedFlag ((bkGetBeakBusterUnlockedFlagProc)  0x8028A9A0)
        #define bkGetCameraControlsUnlockedFlag ((bkGetCameraControlsUnlockedFlagProc)  0x8028A9C0)
        #define bkGetBearPunchUnlockedFlag  ((bkGetBearPunchUnlockedFlagProc)   0x8028A9E0)
        #define bkGetClimbTreesUnlockedFlag ((bkGetClimbTreesUnlockedFlagProc)  0x8028AA00)
        
        #define bkGetEggMovesUnlockedFlag   ((bkGetEggMovesUnlockedFlagProc)    0x8028AA98)

        #define bkGetFlapFlipUnlockedFlag   ((bkGetFlapFlipUnlockedFlagProc)    0x8028AB08)
        #define bkGetFlyingUnlockedFlag ((bkGetFlyingUnlockedFlagProc)  0x8028AB28)
        #define bkGetHoldAToJumpHigherUnlockedFlag  ((bkGetHoldAToJumpHigherUnlockedFlagProc)   0x8028AB48)

        #define bkGetRollUnlockedFlag   ((bkGetRollUnlockedFlagProc)    0x8028AC18)
        #define bkGetShockSpringJumpUnlockedFlag    ((bkGetShockSpringJumpUnlockedFlagProc) 0x8028AC38)
        #define bkGetWadingBootsUnlockedFlag    ((bkGetWadingBootsUnlockedFlagProc) 0x8028AC58)
        #define bkGetTalonTrotUnlockedFlag  ((bkGetTalonTrotUnlockedFlagProc)   0x8028AC78)
        #define bkGetTalonTrotUnlockedFlag_copy  ((bkGetTalonTrotUnlockedFlag_copyProc)   0x8028AC98)
        #define bkGetWonderWingUnlockedFlag ((bkGetWonderWingUnlockedFlagProc)  0x8028ACB8)

        #define bkIsCurrentlyInTermiteMoveSet ((bkIsCurrentlyInTermiteMoveSetProc)  0x8028AD64)
        #define bkIsCurrentlyInPumpkinMoveSet ((bkIsCurrentlyInPumpkinMoveSetProc)  0x8028AD8C)

        #define bkIsPlayerGT60AboveGround   ((bkIsPlayerGT60AboveGroundProc)    0x8028B094)

        #define bkIsCurrentLevelRBB     ((bkIsCurrentLevelRBBProc)  0x8028B148)

        #define bkIsPlayerInWater       ((bkIsPlayerInWaterProc)    0x8028B51C)
        #define bkIsPlayerSwimming      ((bkIsPlayerSwimmingProc)   0x8028B528)

        #define bkUpdateBanjo           ((bkUpdateBanjoProc)        0x8028E71C)

        #define bkPrint_ScalableEggFont    ((bkPrint_ScalableEggFontProc)   0x802F7870)
        #define bkPrint_HUDEggFont      ((bkPrint_HUDEggFontProc)   0x802F78C0)
        #define bkPrint_CharFont        ((bkPrint_CharFontProc)     0x802F78FC)
        #define bkPrint_CharFontWithBG  ((bkPrint_CharFontWithBGProc)   0x80F7938)
        #define bkPrint_FadingCharFont  ((bkPrint_FadingCharFontProc)   0x802F7974)

        #define bkSpawnActor            ((bkSpawnActorProc)         0x8032813C)        
        
        #define bkAppendString          ((bkAppendStringProc)       0x8033D660)
        #define bkAppendChar            ((bkAppendCharProc)         0x8033D6A8)
        #define bkFToA_prec2            ((bkFToA_prec2Proc)         0x8033D6E0)
        #define bkFToA                  ((bkFToAProc)               0x8033D7B0)
        #define bkIToA_base10           ((bkIToA_base10Proc)        0x8033D884)
        #define bkIToA                  ((bkIToAProc)               0x8033D8A4)
        #define bkCompareStrings        ((bkCompareStringsProc)     0x8033D9D4)
        #define bkCopyString            ((bkCopyStringProc)         0x8033DA54)
        #define bkGetStringSize         ((bkGetStringSizeProc)      0x8033DA80)

        #define bkToUpper               ((bkToUpperProc)            0x8033DBA4)



    /*---------------------------------\
    | PAL                              |
    \---------------------------------*/
    #elseif BK_VERSION == BK_PAL
        //all PAL specific definitions
        
        //VARIABLES
        #define slope_timer_addr        0x8037CCB4

        //FUNCTIONS
        #define bkSpawnActor            ((bkSpawnActorProc)         0x80328594)

        #define bkPrint_ScalableEggFont ((bkPrint_ScalableEggFontProc)  0x802F7A50)
        #define bkPrint_HUDEggFont      ((bkPrint_HUDEggFontProc)   0x802F7AA0)
        #define bkPrint_CharFont        ((bkPrint_CharFontProc)     0x802F7ADC)
        
        #define bkFToA                  ((bkFToAProc)               0x8033DC00)

        #define bkCopyString            ((bkCopyStringProc)         0x8033DEA4)
        


    #elseif BK_VERSION == BK_NTSC_J
        //all NTSC_J specific definitions

        #define bkSpawnActor            ((bkSpawnActorProc)         0x803285C4)



    #elseif BK_VERSION == BK_NTSC_REV_A
        //all NTSC_REV_A specific definitions


        #define bkSpawnActor            ((bkSpawnActorProc)         0x80327334)


    #else
        #error "Version of Banjo-Kazooie not valid. See 1st comment in BanjoKazooie.h.
    #endif 
#endif