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

typedef uint32_t (*bkGetGlobalOnCounterProc)(void);

typedef void (*bkIncrementGlobalOnCounterProc)(void);

typedef void (*bkSetApplyButtonInputsToBanjoFlagProc)(void);

typedef void (*bkSetFrameSkipProc)(uint32_t input);
typedef uint32_t (*bkGetFrameSkipProc)(void);

typedef uint32_t (*bkClampIntProc)(uint32_t input, uint32_t lowerLimit, uint32_t upperLimit);
typedef float (*bkClampFloatProc)(float input, float lowerLimit, float upperLimit);

#ifndef BK_VERSION
    #error "Version of Banjo-Kazooie no Defined. See 1st comment in BanjoKazooie.h." 
#else
    #if BK_VERSION == BK_NTSC
        //all NTSC specific definitions

        /*variable addresses*/
        #define slope_timer_addr        0x8037C2E4

        /*function point addresses*/
        #define bkGetPIStatusReg        ((bkGetPIStatusRegProc)     0x8000210C);

        #define bkSetCOP0StatusReg      ((bkSetCOP0StatusRegProc)   0x80002190);
        #define bkGetCOP0StatusReg      ((bkGetCOP0StatusRegProc)   0x800021A0);

        #define bkGetGlobalOnCounter    ((bkGetGlobalOnCounterProc) 0x8023DB5C);
        
        #define bkIncrementGlobalOnCounter ((bkIncrementGlobalOnCounterProc) 0x8023DCDC);

        #define bkSetApplyButtonInputsToBanjoFlag ((bkSetApplyButtonInputsToBanjoFlagProc) 0x8023E06C);

        #define bkSetFrameSkip          ((bkSetFrameSkipProc)       0x8024BF94);
        #define bkGetFrameSkip          ((bkGetFrameSkipProc)       0x8024BFA0);

        #define bkClampInt              ((bkClampIntProc)           0x80257EA8);
        #define bkClampFloat            ((bkClampFloatProc)         0x80257ED8);

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