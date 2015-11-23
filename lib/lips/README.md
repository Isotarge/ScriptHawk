# lips

An assembler for the MIPS R4300i architecture, written in Lua.

Not for production. Much of the code is untested and likely to change.
Even this README is incomplete.

## Syntax

TODO

## Instructions

[refer to these instruction documents.][instrdocs]

[instrdocs]: https://github.com/mikeryan/n64dev/tree/master/docs/n64ops

### Unimplemented

* CACHE

* ERET

* TLBP, TLBR, TLBWI, TLBWR

* BC1F, BC1FL, BC1T, BC1TL

### Unimplemented Pseudo-Instructions

Besides implied arguments for existing instructions, there are:

* ABS, MUL, DIV, REM

* NAND, NANDI, NORI, ROL, ROR

* SEQ, SEQI, SEQIU, SEQU

* SGE, SGEI, SGEIU, SGEU

* SGT, SGTI, SGTIU, SGTU

* SLE, SLEI, SLEIU, SLEU

* SNE, SNEI, SNEIU, SNEU

* BEQI, BNEI, BGE, BGEI, BLE, BLEI, BLT, BLTI, BGT, BGTI

## Registers

In order of numerical value, with intended usage:

* R0: always zero; cannot be written to. 'zero' is an acceptable alias.

* AT: assembler temporary. used by various pseudo-instructions.
  user may use freely if they're wary.

* V0, V1: subroutine return values.

* A0 A1 A2 A3: subroutine arguments.

* T0 T1 T2 T3 T4 T5 T6 T7: temporary registers.

* S0 S1 S2 S3 S4 S5 S6 S7: saved registers.

* T8 T9: more temporary registers.

* K0 K1: kernel registers. not recommended to use outside of kernel code.

* GP: global pointer.

* SP: stack pointer.

* FP: frame pointer. 'S8' is an acceptable alias.

* RA: subroutine return address.

* REG#: whereas # is a decimal number from 0 to 31.
aliased to the appropriate register. eg: REG0 is R0, REG1 is at, REG2 is V0.

* f#: coproccesor 1 registers, whereas # is a decimal number from 0 to 31.

### Unimplemented

all coprocessor 0 registers:

```
Index,     Random,    EntryLo0,     EntryLo1,
Context,   PageMask,  Wired,        RESERVED,
BadVAddr,  Count,     EntryHi,      Compare,
Status,    Cause,     ExceptionPC,  PRId,
Config,    LLAddr,    WatchLo,      WatchHi,
XContext,  RESERVED,  RESERVED,     RESERVED,
RESERVED,  RESERVED,  RESERVED,     CacheErr,
TagLo,     TagHi,     ErrorEPC,     RESERVED
```

## Directives

* BYTE: writes a list of 8-bit numbers until end-of-line.
be wary of potential alignment issues.

* HALFWORD: writes a list of 16-bit numbers until end-of-line.
be wary of potential alignment issues.

* WORD: writes a list of 32-bit numbers until end-of-line.

* SKIP: takes one or two arguments.

* ORG: change the current address for writing to; seeking.
for now, this is untested and likely to cause performance issues.

### Unimplemented

* ALIGN: takes one or two arguments.
unlike some other assemblers,
ALIGN only affects the first immediately following datum.

* FLOAT: writes a list of 32-bit floating point numbers until end-of-line.
this may not get implemented due to a lack of aliasing in vanilla Lua,
and thus accuracy issues.

* ASCII: writes a string using its characters' ASCII values.

* ASCIIZ: same as ASCII, but with a null byte added to the end.

* INC, INCASM, INCLUDE: include an external assembly file as-is at this position.

* INCBIN: write an external binary file as-is at this position.
