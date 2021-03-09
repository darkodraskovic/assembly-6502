# 6502 Assembly Language Examples

## Assemble

Put [dasm](https://dasm-assembler.github.io/) somewhere on your path. `cd` to directory with assembly file and

```
dasm <filename>.asm -f3 -v0 -ocart.bin
```

## Run

Install [stella](https://stella-emu.github.io/). `cd` to directory with cartridge file and

```
stella cart.bin
```

For further options, see [stella command line options](https://stella-emu.github.io/docs/index.html#CommandLine)

## Assemle and run example

To compile and run a program in a `cleanmem` directory, for example, from project root directory execute

```
cd cleanmem && dasm cart.asm -f3 -v0 -ocart.bin && stella cart.bin
```

or 

```
cd cleanmem && dasm cart.asm -f3 -v0 -ocart.bin && stella cart.bin -debug
```
if you want to jump in directly into the debug mode.
