# lips

An assembler for the MIPS R4300i architecture, written in Lua.

This is not a 'true' assembler; it won't produce executable binary files.
This was intended to assist in hacking N64 games.
It does little more than output hex.

Not for production. Much of the code and syntax is untested and likely to change.
Even this README is incomplete.

## Syntax

(TODO)

A derivative of [CajeASM's][caje] syntax.

[caje]: https://github.com/Tarek701/CajeASM/

## Instructions

Instructions were primarily referenced from [the N64 Toolkit: Opcodes.][n64op]

An in-depth look at instructions for MIPS IV processors
is given by [the MIPS IV Instruction Set manual.][mipsiv]
Most of this applies to our MIPS III architecture.

[The MIPS64 Instruction Set manual][mips64] is sometimes useful.
Much of it doesn't apply to our older MIPS III architecture,
but it's a little cleaner than the older manual.

There's also a brief and incomplete [overview of MIPS instructions.][overview]
First-time writers of MIPS assembly may find this the most useful.

[n64op]: https://github.com/mikeryan/n64dev/tree/master/docs/n64ops
[mipsiv]: http://www.cs.cmu.edu/afs/cs/academic/class/15740-f97/public/doc/mips-isa.pdf
[mips64]: http://scc.ustc.edu.cn/zlsc/lxwycj/200910/W020100308600769158777.pdf
[overview]: http://www.mrc.uidaho.edu/mrc/people/jff/digital/MIPSir.html

### Unimplemented

As far as I know, all native R4300i instructions have been implemented.
Whether or not they output the proper machine code is another thing.

### Unimplemented Pseudo-Instructions

Besides implicit arguments for existing instructions, there are:

* ABS, MUL, DIV, REM

* BGE, BLE, BLT, BGT

* any Set (Condition) \[Immediate\] \[Unsigned\] pseudo-instructions

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

* F#: coprocessor 1 registers, whereas # is a decimal number from 0 to 31.

* coprocessor 0 (system) registers are as follows:

```
Index     Random    EntryLo0  EntryLo1
Context   PageMask  Wired     Reserved0
BadVAddr  Count     EntryHi   Compare
Status    Cause     EPC       PRevID
Config    LLAddr    WatchLo   WatchHi
XContext  Reserved1 Reserved2 Reserved3
Reserved4 Reserved5 PErr      CacheErr
TagLo     TagHi     ErrorEPC  Reserved6
```

## Directives

* `.byte {numbers...}`  
writes a series of 8-bit numbers until end-of-line.
be wary of potential alignment issues.

* `.halfword {numbers...}`  
writes a series of 16-bit numbers until end-of-line.
be wary of potential alignment issues.

* `.word {numbers...}`  
writes a series of 32-bit numbers until end-of-line.

* `.align [n] [fill]`  
aligns the next datum to a `n*2` boundary using `fill` for spacing.
if `n` is not given, 2 is implied.
if `fill` is not given, 0 is implied.

* `.skip {n} [fill]`  
skips the next `n` bytes using `fill` for spacing.
if `fill` is not given, no bytes are overwritten,
and only the position is changed.

* `.org {address}`  
set the current address for writing to; seek.
until lips is a little more optimized,
be cautious of seeking to large addresses.

* `HEX { ... }`  
write a series of bytes given in hexadecimal.
all numbers must be given in hex — no prefix is required.
```
butts:  HEX {
    F0 0D
    DE AD BE EF
}
.align
```

* `.inc {filename}`  
`.incasm {filename}`  
`.include {filename}`  
include an external assembly file as-is at this position.
lips will look for the included file
in the directory of the file using the directive.

### Unimplemented

* FLOAT: writes a list of 32-bit floating point numbers until end-of-line.
this may not get implemented due to a lack of aliasing in vanilla Lua,
and thus accuracy issues.

* ASCII: writes a string using its characters' ASCII values.

* ASCIIZ: same as ASCII, but with a null byte added to the end.

* INCBIN: write an external binary file as-is at this position.
