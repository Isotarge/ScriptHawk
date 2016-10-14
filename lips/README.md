# lips

An assembler for the MIPS R4300i processor, written in Lua.

This is not a 'true' assembler; it won't produce executable binary files.
This was intended to assist in hacking N64 games.
It does little more than output hex.

Not for production.
Much of the code and syntax is untested and likely to change.
Even this README is incomplete.

## Usage

`local lips = require "lips.init"`

You can then use it as such:
[example.lua][elua] — [example.asm][easm]

[elua]: ./example.lua
[easm]: ./example.asm

By default, lips will print the assembled word values in hex:
```
18800017
00001025
2401002F
10810002
0081082A
10200012
2488FFFF
00084080
etc...
```

Other predefined output formats are available in [lips.writers][writers];
you can instantiate one and pass it through the second argument of lips.

Since lips is designed to assist with ROM/RAM hacking,
it cannot produce executable files on its own.
Instead, it is meant to be integrated with
an existing executable or memory dump.
For instance, consider [this injection routine][inject.lua]
written for the Nintendo 64 Zelda games.

[writers]: /lips/writers.lua
[inject.lua]: https://github.com/notwa/mm/blob/master/Lua/inject.lua

## Syntax

lips uses a derivative of [CajeASM's][caje] syntax.
It takes a couple of notes from other assemblers as well.

[caje]: https://github.com/Tarek701/CajeASM/

A run-down of various syntax elements:
```asm
// this is a comment.
/* this is a block comment */
; this is a more traditional assembly style of comment.
; we'll be using this so github's syntax highlighting doesn't blow up.

; set a variable. these are inlined in the preprocessing stage.
[my_const]: 0xDEADBEEF
; we can then use it in instructions by adding a @ prefix:
    li      a0, @my_const

; whitespace is optional.
li a0,@myconst
; commas can be optional too,
; but this feature will likely be removed in the future.
li a0 @myconst
; instructions may end in an extra comma;
; this may make mass-entry or generation of instructions easier.
li  a0, @my_const,

; instruction/register names are case-insensitive, as are hex digits.
    LI      A0, @my_const
    LuI     a0, 0xDeAd
; however, note that the 'x' in "0x" must be lowercase.
; the same applies for 0b and 0o for binary and octal, respectively.

; coprocessor 0 registers are case-insensitive as well,
; though this may change in the future.
    mfc0    a1, CouNT

; labels are defined with a colon, and referenced without a prefix, as such:
my_label:
    b       my_label
    nop

; directives are prefixed with a dot.
; also, labels may be used in .word directives.
    .word   my_label, 1, 2, 3, 0x4567

; numbers may be written in eight different ways: two for each base.
    li      t1, 0xDEADBEEF
    li      t2, $DEADBEEF
    li      t3, %11011110101011011011111011101111
    li      t4, 0b11011110101011011011111011101111
    li      t5, 0o33653337357
    li      t6, 033653337357
    li      t7, 3735928559
    li      t8, #3735928559

; though, as a stylistic choice, the preferred way of writing them are as such:
    li      t1, 0xDEADBEEF
    li      t4, 0b11011110101011011011111011101111
    li      t5, 0o33653337357
    li      t7, 3735928559

.align ; implied argument of 2, for a 2**n=4 byte alignment

; loading and storing can be written in several ways (addressing modes):
    lw      s0, label
    lw      s1, (s0)
    lw      s2, 256(s0)
    lw      s3, label(s0)
    sw      s2, label+4
    sw      s3, label+4(s0)

; relative labels are borrowed from asw, except ours require a suffixing colon:
-:              ; #1
    b       ++  ; branches to #3
    nop
+:
-:              ; #2
    b       --  ; branches to #1
    nop
+:              ; #3
    b       -   ; branches to #2
    nop

; TODO: more examples!
```

## Instructions

Instructions were primarily referenced from [the N64 Toolkit: Opcodes][n64op]
and the [bass assembler.][basstables]

An in-depth look at instructions for MIPS IV processors
is given by [the MIPS IV Instruction Set manual.][mipsiv]
Most of this applies to our MIPS III architecture.

[The MIPS64 Instruction Set manual][mips64] is sometimes useful.
Much of it doesn't apply to our older MIPS III architecture,
but it's a little cleaner than the older manuals.

Last, but not least, [the R4300i datasheet][r4300i] covers
some of the nuances of the processor.

[n64op]: https://github.com/mikeryan/n64dev/tree/master/docs/n64ops
[basstables]: https://github.com/ARM9/bass/tree/master/bass/arch/table/mipseb
[mipsiv]: http://www.cs.cmu.edu/afs/cs/academic/class/15740-f97/public/doc/mips-isa.pdf
[mips64]: http://scc.ustc.edu.cn/zlsc/lxwycj/200910/W020100308600769158777.pdf
[r4300i]: http://www.futuretech.blinkenlights.nl/R4300_datasheet.Rev0.3.pdf

### Unimplemented Instructions

As far as I know, all native R4300i instructions have been implemented.
Whether or not they output the proper machine code is another thing.

### Unimplemented Pseudo-Instructions

* MUL, DIV, REM

* many Set [Condition] pseudo-instructions

## Registers

In order of numerical value, with intended usage:

* ZERO: always zero; cannot be changed.

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

* R#: whereas # is a decimal number from 0 to 31.
aliased to the appropriate register, for instance:
R0 is ZERO, R1 is AT, R2 is V0, etc.

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
aligns the next datum to a `2**n` boundary using `fill` for spacing.
if `n` is omitted, 2 is implied.
if `fill` is omitted, 0 is implied.

* `.skip {n} [fill]`  
skips the next `n` bytes using `fill` for spacing.
if `fill` is omitted, no bytes are overwritten,
and only the position is changed.

* `.org {address}`  
set the current address for writing to; seek to origin.

* `.base {offset}`  
sets a virtual offset relative to the origin (.org).
defaults to 0x80000000.
this allows you to have a PC value different from origin:
`PC = origin + base`

* `.push {vars...}`  
`.pop {vars...}`  
pushes or pops variables with an internal stack.
supported variables: org, base, pc.

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

* `.incbin {filename}`  
write an external binary file as-is at this position.
lips will look for the included file
in the directory of the file using the directive.

* `.ascii "some\ntext\0"`  
writes a string using its characters' ASCII values.
a few escapes are currently supported: `\ " a b f n r t v 0`

* `.asciiz "some\ntext"`  
same as ascii, but with a null byte added to the end.

### Unimplemented

* `.float {numbers..}`  
`.double {numbers..}`  
writes a list of 32-bit/64-bit floating point numbers until end-of-line.
this may not get implemented in vanilla Lua due to a lack of aliasing.
