/*---------------------------------------
| BanjoKazooie.h
| Authors: Michael "Mittenz" Salino-Hugg
|
| 
\----------------------------------------*/

//version of BK you're using needs to be defined at the top of your C program before including this library:
//Syntax: #define VERSION
//Valid version options: BK_NTSC, BK_NTSC_REV_A, BK_PAL, BK_NTSC_J

#include <stdint.h>

//TypeDefs
typedef void func_v_v(void);
typedef int32_t func_v_w(void);

typedef void func_w_v(int32_t);
typedef int32_t func_www_w(int32_t, int32_t, int32_t);

typedef float func_fff_f(float, float, float);

#ifndef BK_VERSION
    #error "Version of Banjo-Kazooie no Defined. See 1st comment in BanjoKazooie.h." 
#else
    #if BK_VERSION == BK_NTSC
        //all NTSC specific definitions
        //float _attribute_((section (".slopeTimer"))) bkSlopeTimer;

        func_v_w* bkGetPIStatusReg = (func_v_w*)0x8000210C;

        func_w_v* bkSetCOP0StatusReg = (func_w_v*)0x80002190;
        func_v_w* bkGetCOP0StatusReg = (func_v_w*)0x800021A0;

        func_v_w* bkGetGlobalOnCounter = (func_v_w*)0x8023DB5C;
        
        func_v_v* bkIncrementGlobalOnCounter = (func_v_v*)0x8023DCDC;

        func_v_v* bkSetApplyButtonInputsToBanjoFlag = (func_v_v*)0x8023E06C;

        func_w_v* bkSetFrameSkip = (func_w_v*)0x8024BF94;
        func_v_w* bkGetFrameSkip = (func_v_w*)0x8024BFA0;

        func_www_w* bkClampInt = (func_www_w*)0x80257EA8;
        func_fff_w* bkClampFloat = (func_fff_f*)0x80257ED8;

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