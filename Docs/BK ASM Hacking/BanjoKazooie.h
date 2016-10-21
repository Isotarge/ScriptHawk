/*---------------------------------------
| BanjoKazooie.h
| Authors: Michael "Mittenz" Salino-Hugg
|
| 
\----------------------------------------*/

//version of BK you're using needs to be defined at the top of your C program before including this library:
//Syntax: #define VERSION
//Valid version options: BK_NTSC, BK_NTSC_REV_A, BK_PAL, BK_NTSC_J

#ifndef BK_H
#define BK_H
#include <stdint.h>

/*enumerations*/

/*function pointer typeDefs*/
typedef uint32_t (*bkGetPIStatusRegProc)(void);

typedef void (*bkSetCOP0StatusRegProc)(uint32_t input);
typedef uint32_t (*bkGetCOP0StatusRegProc)(void);

typedef void (*bkSetStatusRegProc)(uint32_t input);

typedef uint32_t (*bkGetGlobalOnCounterProc)(void);

typedef void (*bkIncrementGlobalOnCounterProc)(void);

typedef void (*bkSetApplyButtonInputsToBanjoFlagProc)(void);

typedef void (*bkSetFrameSkipProc)(uint32_t input);
typedef uint32_t (*bkGetFrameSkipProc)(void);

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



typedef void (*bkSpawnActorProc)(uint32_t actorIndex, float* locationPtr, float rotaion);




#ifndef BK_VERSION
    #error "Version of Banjo-Kazooie no Defined. See 1st comment in BanjoKazooie.h." 
#else
    #if BK_VERSION == BK_NTSC
        //all NTSC specific definitions

        /*variable addresses*/
        #define slope_timer_addr        0x8037C2E4

        /*function point addresses*/
        #define bkGetPIStatusReg        ((bkGetPIStatusRegProc)     0x8000210C)

        #define bkSetCOP0StatusReg      ((bkSetCOP0StatusRegProc)   0x80002190)
        #define bkGetCOP0StatusReg      ((bkGetCOP0StatusRegProc)   0x800021A0)

        #define bkSetStatusReg          ((bkSetStatusRegProc)       0x80003FE0)

        #define bkGetGlobalOnCounter    ((bkGetGlobalOnCounterProc) 0x8023DB5C)
        
        #define bkIncrementGlobalOnCounter ((bkIncrementGlobalOnCounterProc) 0x8023DCDC)

        #define bkSetApplyButtonInputsToBanjoFlag ((bkSetApplyButtonInputsToBanjoFlagProc) 0x8023E06C)

        #define bkSetFrameSkip          ((bkSetFrameSkipProc)       0x8024BF94)
        #define bkGetFrameSkip          ((bkGetFrameSkipProc)       0x8024BFA0)

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
        


        #define bkSpawnActor            ((bkSpawnActorProc)         0x8032813C)        
        


    #elseif BK_VERSION == BK_PAL
        //all PAL specific definitions

    #elseif BK_VERSION == BK_NTSC_J
        //all NTSC_J specific definitions
        

    #elseif BK_VERSION == BK_NTSC_REV_A
        //all NTSC_REV_A specific definitions

    #else
        #error "Version of Banjo-Kazooie not valid. See 1st comment in BanjoKazooie.h.
    #endif 
#endif