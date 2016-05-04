local data = {}

data.registers = {
    [0]=
    'R0', 'AT', 'V0', 'V1', 'A0', 'A1', 'A2', 'A3',
    'T0', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7',
    'S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7',
    'T8', 'T9', 'K0', 'K1', 'GP', 'SP', 'FP', 'RA',
}

data.sys_registers = {
    [0]=
    "INDEX",     "RANDOM",    "ENTRYLO0",  "ENTRYLO1",
    "CONTEXT",   "PAGEMASK",  "WIRED",     "RESERVED0",
    "BADVADDR",  "COUNT",     "ENTRYHI",   "COMPARE",
    "STATUS",    "CAUSE",     "EPC",       "PREVID",
    "CONFIG",    "LLADDR",    "WATCHLO",   "WATCHHI",
    "XCONTEXT",  "RESERVED1", "RESERVED2", "RESERVED3",
    "RESERVED4", "RESERVED5", "PERR",      "CACHEERR",
    "TAGLO",     "TAGHI",     "ERROREPC",  "RESERVED6",
}

data.fpu_registers = {
    [0]=
    'F0',  'F1',  'F2',  'F3',  'F4',  'F5',  'F6',  'F7',
    'F8',  'F9',  'F10', 'F11', 'F12', 'F13', 'F14', 'F15',
    'F16', 'F17', 'F18', 'F19', 'F20', 'F21', 'F22', 'F23',
    'F24', 'F25', 'F26', 'F27', 'F28', 'F29', 'F30', 'F31',
}

data.all_directives = {
    'ORG', 'ALIGN', 'SKIP',
    'ASCII', 'ASCIIZ',
    'BYTE', 'HALFWORD', 'WORD',
    --'HEX', -- excluded here due to different syntax
    'INC', 'INCASM', 'INCLUDE',
    'INCBIN',
    -- these are unlikely to be implemented
    'FLOAT', 'DOUBLE',
}

data.directive_aliases = {
    SPACE = 'SKIP',
    HALF = 'HALFWORD',
}

data.all_registers = {}
for k, v in pairs(data.registers) do
    data.all_registers[k] = v
end
for k, v in pairs(data.sys_registers) do
    data.all_registers[k + 32] = v
end
for k, v in pairs(data.fpu_registers) do
    data.all_registers[k + 64] = v
end

-- set up reverse table lookups
local function revtable(t)
    for k, v in pairs(t) do
        t[v] = k
    end
end

revtable(data.registers)
revtable(data.sys_registers)
revtable(data.fpu_registers)
revtable(data.all_registers)
revtable(data.all_directives)

-- alternate register names
data.registers['ZERO'] = 0
data.all_registers['ZERO'] = 0
data.registers['S8'] = 30
data.all_registers['S8'] = 30

for i=0, 31 do
    local r = 'REG'..tostring(i)
    data.registers[r] = i
    data.all_registers[r] = i
end

data.fmt_single = 16
data.fmt_double = 17
data.fmt_word = 20
data.fmt_long = 21

local __ = {}
data.instructions = {
    --[[
    data guide:
    --INSTRUCTION_NAME = {opcode, infmt, outfmt, const, fmtconst},
    underscores are translated to dots later.
    opcode: the first 6 bits of the instruction.
    infmt: the input format; one character per argument.
    outfmt: the output format: R-, I-, and J-types are inferred by length.
    const: (optional) the number to replace 'C' with in outfmt.
    fmtconst: (optional) the number to replace 'F' with in outfmt.

    input format guide:
        such and such: expects a...
        d:  register for rd
        s:  register for rs
        t:  register for rt
        D:  floating point register for fd
        S:  floating point register for fs
        T:  floating point register for ft
        X:  system register for rd
        Y:  system register for rs (unused)
        Z:  system register for rt (unused)
        o:  constant for offset
        b:  register to dereference for base
        r:  relative constant or label for offset
        I:  constant or label for index (long jump)
        i:  immediate (must fit in a halfword; cannot be a label)
        k:  immediate to negate (must fit in a halfword; cannot be a label)
        K:  signed immediate (-0x8000 <= immediate < 0x10000; cannot be a label)

    output format guide:
        such and such: writes ... at this position
        0:  zero (sometimes used to refer to R0)
        d:  rd
        s:  rs
        t:  rt
        D:  fd
        S:  fs
        T:  ft
        o:  offset
        b:  base
        i:  immediate (infmt 'i' and 'k' both write to here)
        I:  index
        C:  constant (given in argument immediately after)
        F:  format constant (given in argument after constant)
    --]]

    J       = {2, 'I', 'I'},
    JAL     = {3, 'I', 'I'},

    JALR    = {0, 'ds', 's0d0C', 9},

    JR      = {0, 's', 's000C',  8},

    BREAK   = {0, '', '0000C', 13},
    SYSCALL = {0, '', '0000C', 12},

    SYNC    = {0, '', '0000C', 15},

    LB      = {32, 'tob', 'bto'},
    LBU     = {36, 'tob', 'bto'},
    LD      = {55, 'tob', 'bto'},
    LDL     = {26, 'tob', 'bto'},
    LDR     = {27, 'tob', 'bto'},
    LH      = {33, 'tob', 'bto'},
    LHU     = {37, 'tob', 'bto'},
    LL      = {48, 'tob', 'bto'},
    LLD     = {52, 'tob', 'bto'},
    LW      = {35, 'tob', 'bto'},
    LWL     = {34, 'tob', 'bto'},
    LWR     = {38, 'tob', 'bto'},
    LWU     = {39, 'tob', 'bto'},
    SB      = {40, 'tob', 'bto'},
    SC      = {56, 'tob', 'bto'},
    SCD     = {60, 'tob', 'bto'},
    SD      = {63, 'tob', 'bto'},
    SDL     = {44, 'tob', 'bto'},
    SDR     = {45, 'tob', 'bto'},
    SH      = {41, 'tob', 'bto'},
    SW      = {43, 'tob', 'bto'},
    SWL     = {42, 'tob', 'bto'},
    SWR     = {46, 'tob', 'bto'},

    LUI     = {15, 'ti', '0ti'},

    MFHI    = {0, 'd', '00d0C', 16},
    MFLO    = {0, 'd', '00d0C', 18},

    MTHI    = {0, 's', 's000C', 17},
    MTLO    = {0, 's', 's000C', 19},

    ADDI    = { 8, 'tsK', 'sti'},
    ADDIU   = { 9, 'tsK', 'sti'},
    ANDI    = {12, 'tsK', 'sti'},
    DADDI   = {24, 'tsK', 'sti'},
    DADDIU  = {25, 'tsK', 'sti'},
    ORI     = {13, 'tsi', 'sti'},
    SLTI    = {10, 'tsi', 'sti'},
    SLTIU   = {11, 'tsi', 'sti'},
    XORI    = {14, 'tsi', 'sti'},

    ADD     = {0, 'dst', 'std0C', 32},
    ADDU    = {0, 'dst', 'std0C', 33},
    AND     = {0, 'dst', 'std0C', 36},
    DADD    = {0, 'dst', 'std0C', 44},
    DADDU   = {0, 'dst', 'std0C', 45},
    DSLLV   = {0, 'dts', 'std0C', 20},
    DSUB    = {0, 'dst', 'std0C', 46},
    DSUBU   = {0, 'dst', 'std0C', 47},
    NOR     = {0, 'dst', 'std0C', 39},
    OR      = {0, 'dst', 'std0C', 37},
    SLLV    = {0, 'dts', 'std0C',  4},
    SLT     = {0, 'dst', 'std0C', 42},
    SLTU    = {0, 'dst', 'std0C', 43},
    SRAV    = {0, 'dts', 'std0C',  7},
    SRLV    = {0, 'dts', 'std0C',  6},
    SUB     = {0, 'dst', 'std0C', 34},
    SUBU    = {0, 'dst', 'std0C', 35},
    XOR     = {0, 'dst', 'std0C', 38},

    DDIV    = {0, 'st', 'st00C', 30},
    DDIVU   = {0, 'st', 'st00C', 31},
    DIV     = {0, 'st', 'st00C', 26},
    DIVU    = {0, 'st', 'st00C', 27},
    DMULT   = {0, 'st', 'st00C', 28},
    DMULTU  = {0, 'st', 'st00C', 29},
    MULT    = {0, 'st', 'st00C', 24},
    MULTU   = {0, 'st', 'st00C', 25},

    DSLL    = {0, 'dti', '0tdiC', 56},
    DSLL32  = {0, 'dti', '0tdiC', 60},
    DSRA    = {0, 'dti', '0tdiC', 59},
    DSRA32  = {0, 'dti', '0tdiC', 63},
    DSRAV   = {0, 'dts', '0tdsC', 23},
    DSRL    = {0, 'dti', '0tdiC', 58},
    DSRL32  = {0, 'dti', '0tdiC', 62},
    DSRLV   = {0, 'dts', '0tdsC', 22},
    SLL     = {0, 'dti', '0tdiC',  0},
    SRA     = {0, 'dti', '0tdiC',  3},
    SRL     = {0, 'dti', '0tdiC',  2},

    BEQ     = { 4, 'str', 'sto'},
    BEQL    = {20, 'str', 'sto'},
    BNE     = { 5, 'str', 'sto'},
    BNEL    = {21, 'str', 'sto'},

    BGEZ    = { 1, 'sr', 'sCo',  1},
    BGEZAL  = { 1, 'sr', 'sCo', 17},
    BGEZALL = { 1, 'sr', 'sCo', 19},
    BGEZL   = { 1, 'sr', 'sCo',  3},
    BGTZ    = { 7, 'sr', 'sCo',  0},
    BGTZL   = {23, 'sr', 'sCo',  0},
    BLEZ    = { 6, 'sr', 'sCo',  0},
    BLEZL   = {22, 'sr', 'sCo',  0},
    BLTZ    = { 1, 'sr', 'sCo',  0},
    BLTZAL  = { 1, 'sr', 'sCo', 16},
    BLTZALL = { 1, 'sr', 'sCo', 18},
    BLTZL   = { 1, 'sr', 'sCo',  2},

    -- coprocessor-related instructions

    TEQ     = {0, 'st', 'st00C', 52},
    TGE     = {0, 'st', 'st00C', 48},
    TGEU    = {0, 'st', 'st00C', 49},
    TLT     = {0, 'st', 'st00C', 50},
    TLTU    = {0, 'st', 'st00C', 51},
    TNE     = {0, 'st', 'st00C', 54},

    TEQI    = {1, 'si', 'sCi', 12},
    TGEI    = {1, 'si', 'sCi',  8},
    TGEIU   = {1, 'si', 'sCi',  9},
    TLTI    = {1, 'si', 'sCi', 10},
    TLTIU   = {1, 'si', 'sCi', 11},
    TNEI    = {1, 'si', 'sCi', 14},

    CFC1    = {17, 'tS', 'CtS00', 2},
    CTC1    = {17, 'tS', 'CtS00', 6},
    DMFC1   = {17, 'tS', 'CtS00', 1},
    DMTC1   = {17, 'tS', 'CtS00', 5},
    MFC0    = {16, 'tX', 'Ctd00', 0},
    MFC1    = {17, 'tS', 'CtS00', 0},
    MTC0    = {16, 'tX', 'Ctd00', 4},
    MTC1    = {17, 'tS', 'CtS00', 4},

    LDC1    = {53, 'Tob', 'bTo'},
    LWC1    = {49, 'Tob', 'bTo'},
    SDC1    = {61, 'Tob', 'bTo'},
    SWC1    = {57, 'Tob', 'bTo'},

    -- immediate limited to 3 bits?
    CACHE   = {47, 'iob', 'bio'},

    -- misuses 'F' to write the initial bit
    ERET    = {16, '', 'F000C', 24, 16},
    TLBP    = {16, '', 'F000C',  8, 16},
    TLBR    = {16, '', 'F000C',  1, 16},
    TLBWI   = {16, '', 'F000C',  2, 16},
    TLBWR   = {16, '', 'F000C',  6, 16},

    -- only one condition code on the R4300i?
    BC1F    = {17, 'r', 'FCo', 0, 8},
    BC1FL   = {17, 'r', 'FCo', 2, 8},
    BC1T    = {17, 'r', 'FCo', 1, 8},
    BC1TL   = {17, 'r', 'FCo', 3, 8},

    ADD_D   = {17, 'DST', 'FTSDC', 0, data.fmt_double},
    ADD_S   = {17, 'DST', 'FTSDC', 0, data.fmt_single},
    DIV_D   = {17, 'DST', 'FTSDC', 3, data.fmt_double},
    DIV_S   = {17, 'DST', 'FTSDC', 3, data.fmt_single},
    MUL_D   = {17, 'DST', 'FTSDC', 2, data.fmt_double},
    MUL_S   = {17, 'DST', 'FTSDC', 2, data.fmt_single},
    SUB_D   = {17, 'DST', 'FTSDC', 1, data.fmt_double},
    SUB_S   = {17, 'DST', 'FTSDC', 1, data.fmt_single},

    C_EQ_D  = {17, 'ST', 'FTS0C', 50, data.fmt_double},
    C_EQ_S  = {17, 'ST', 'FTS0C', 50, data.fmt_single},
    C_F_D   = {17, 'ST', 'FTS0C', 48, data.fmt_double},
    C_F_S   = {17, 'ST', 'FTS0C', 48, data.fmt_single},
    C_LE_D  = {17, 'ST', 'FTS0C', 62, data.fmt_double},
    C_LE_S  = {17, 'ST', 'FTS0C', 62, data.fmt_single},
    C_LT_D  = {17, 'ST', 'FTS0C', 60, data.fmt_double},
    C_LT_S  = {17, 'ST', 'FTS0C', 60, data.fmt_single},
    C_NGE_D = {17, 'ST', 'FTS0C', 61, data.fmt_double},
    C_NGE_S = {17, 'ST', 'FTS0C', 61, data.fmt_single},
    C_NGL_D = {17, 'ST', 'FTS0C', 59, data.fmt_double},
    C_NGL_S = {17, 'ST', 'FTS0C', 59, data.fmt_single},
    C_NGLE_D= {17, 'ST', 'FTS0C', 57, data.fmt_double},
    C_NGLE_S= {17, 'ST', 'FTS0C', 57, data.fmt_single},
    C_NGT_D = {17, 'ST', 'FTS0C', 63, data.fmt_double},
    C_NGT_S = {17, 'ST', 'FTS0C', 63, data.fmt_single},
    C_OLE_D = {17, 'ST', 'FTS0C', 54, data.fmt_double},
    C_OLE_S = {17, 'ST', 'FTS0C', 54, data.fmt_single},
    C_OLT_D = {17, 'ST', 'FTS0C', 52, data.fmt_double},
    C_OLT_S = {17, 'ST', 'FTS0C', 52, data.fmt_single},
    C_SEQ_D = {17, 'ST', 'FTS0C', 58, data.fmt_double},
    C_SEQ_S = {17, 'ST', 'FTS0C', 58, data.fmt_single},
    C_SF_D  = {17, 'ST', 'FTS0C', 56, data.fmt_double},
    C_SF_S  = {17, 'ST', 'FTS0C', 56, data.fmt_single},
    C_UEQ_D = {17, 'ST', 'FTS0C', 51, data.fmt_double},
    C_UEQ_S = {17, 'ST', 'FTS0C', 51, data.fmt_single},
    C_ULE_D = {17, 'ST', 'FTS0C', 55, data.fmt_double},
    C_ULE_S = {17, 'ST', 'FTS0C', 55, data.fmt_single},
    C_ULT_D = {17, 'ST', 'FTS0C', 53, data.fmt_double},
    C_ULT_S = {17, 'ST', 'FTS0C', 53, data.fmt_single},
    C_UN_D  = {17, 'ST', 'FTS0C', 49, data.fmt_double},
    C_UN_S  = {17, 'ST', 'FTS0C', 49, data.fmt_single},

    CVT_D_L = {17, 'DS', 'F0SDC', 33, data.fmt_long},
    CVT_D_S = {17, 'DS', 'F0SDC', 33, data.fmt_single},
    CVT_D_W = {17, 'DS', 'F0SDC', 33, data.fmt_word},
    CVT_L_D = {17, 'DS', 'F0SDC', 37, data.fmt_double},
    CVT_L_S = {17, 'DS', 'F0SDC', 37, data.fmt_single},
    CVT_S_D = {17, 'DS', 'F0SDC', 32, data.fmt_double},
    CVT_S_L = {17, 'DS', 'F0SDC', 32, data.fmt_long},
    CVT_S_W = {17, 'DS', 'F0SDC', 32, data.fmt_word},
    CVT_W_D = {17, 'DS', 'F0SDC', 36, data.fmt_double},
    CVT_W_S = {17, 'DS', 'F0SDC', 36, data.fmt_single},

    ABS_D   = {17, 'DS', 'F0SDC',  5, data.fmt_double},
    ABS_S   = {17, 'DS', 'F0SDC',  5, data.fmt_single},
    CEIL_L_D= {17, 'DS', 'F0SDC', 10, data.fmt_double},
    CEIL_L_S= {17, 'DS', 'F0SDC', 10, data.fmt_single},
    CEIL_W_D= {17, 'DS', 'F0SDC', 14, data.fmt_double},
    CEIL_W_S= {17, 'DS', 'F0SDC', 14, data.fmt_single},
    FLOOR_L_D={17, 'DS', 'F0SDC', 11, data.fmt_double},
    FLOOR_L_S={17, 'DS', 'F0SDC', 11, data.fmt_single},
    FLOOR_W_D={17, 'DS', 'F0SDC', 15, data.fmt_double},
    FLOOR_W_S={17, 'DS', 'F0SDC', 15, data.fmt_single},
    MOV_D   = {17, 'DS', 'F0SDC',  6, data.fmt_double},
    MOV_S   = {17, 'DS', 'F0SDC',  6, data.fmt_single},
    NEG_D   = {17, 'DS', 'F0SDC',  7, data.fmt_double},
    NEG_S   = {17, 'DS', 'F0SDC',  7, data.fmt_single},
    ROUND_L_D={17, 'DS', 'F0SDC',  8, data.fmt_double},
    ROUND_L_S={17, 'DS', 'F0SDC',  8, data.fmt_single},
    ROUND_W_D={17, 'DS', 'F0SDC', 12, data.fmt_double},
    ROUND_W_S={17, 'DS', 'F0SDC', 12, data.fmt_single},
    SQRT_D  = {17, 'DS', 'F0SDC',  4, data.fmt_double},
    SQRT_S  = {17, 'DS', 'F0SDC',  4, data.fmt_single},
    TRUNC_L_D={17, 'DS', 'F0SDC',  9, data.fmt_double},
    TRUNC_L_S={17, 'DS', 'F0SDC',  9, data.fmt_single},
    TRUNC_W_D={17, 'DS', 'F0SDC', 13, data.fmt_double},
    TRUNC_W_S={17, 'DS', 'F0SDC', 13, data.fmt_single},

    -- pseudo-instructions

    B       = { 4, 'r', '00o'},         -- BEQ R0, R0, offset
    BAL     = { 1, 'r', '0Co', 17},     -- BGEZAL R0, offset
    BEQZ    = { 4, 'sr', 's0o'},        -- BEQ RS, R0, offset
    BEQZL   = {20, 'sr', 's0o'},        -- BEQL RS, R0, offset
    BNEZ    = { 5, 'sr', 's0o'},        -- BNE RS, R0, offset
    BNEZL   = {21, 'sr', 's0o'},        -- BNEL RS, R0, offset
    CL      = { 0, 'd', '00d0C', 37},   -- OR RD, R0, R0
    MOV     = { 0, 'ds', 's0d0C', 37},  -- OR RD, RS, R0
    NEG     = { 0, 'dt', '0td0C', 34},  -- SUB RD, R0, RT
    NOP     = { 0, '', '0'},            -- SLL R0, R0, 0
    NOT     = { 0, 'ds', 's0d0C', 39},  -- NOR RD, RS, R0
    SUBI    = { 8, 'tsk', 'sti'},       -- ADDI RT, RS, -immediate
    SUBIU   = { 9, 'tsk', 'sti'},       -- ADDIU RT, RS, -immediate

    -- ...that expand to multiple instructions
    LI      = __, -- only one instruction for values < 0x10000
    LA      = __,

    -- variable arguments
    PUSH    = __,
    POP     = __,
    JPOP    = __,

    ABS     = __, -- BGEZ NOP SUBU?
    MUL     = __, -- MULT MFLO
    --DIV     = __, -- 3 arguments
    REM     = __, -- 3 arguments

    NAND    = __, -- AND, NOT
    NANDI   = __, -- ANDI, NOT
    NORI    = __, -- ORI, NOT
    ROL     = __, -- SLL, SRL, OR
    ROR     = __, -- SRL, SLL, OR

    SEQ     = __, SEQI    = __, SEQIU   = __, SEQU    = __,
    SGE     = __, SGEI    = __, SGEIU   = __, SGEU    = __,
    SGT     = __, SGTI    = __, SGTIU   = __, SGTU    = __,
    SLE     = __, SLEI    = __, SLEIU   = __, SLEU    = __,
    SNE     = __, SNEI    = __, SNEIU   = __, SNEU    = __,

    BGE     = __,
    BLE     = __,
    BLT     = __,
    BGT     = __,

    BEQI    = __, BEQIL   = __,
    BNEI    = __, BNEIL   = __,
    BGEI    = __, BGEIL   = __,
    BLEI    = __, BLEIL   = __,
    BLTI    = __, BLTIL   = __,
    BGTI    = __, BGTIL   = __,
}

data.all_instructions = {}
local i = 1
for k, v in pairs(data.instructions) do
    data.all_instructions[k:gsub('_', '.')] = i
    i = i + 1
end
revtable(data.all_instructions)

return data
