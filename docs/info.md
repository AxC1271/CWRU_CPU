# CWRU CPU Docs

<p align="center">
    <img 
    height="500px"
    src="./images/riscv-architecture.png"
    >
</p>

*Credit: Patterson & Hennessy, [Computer Organization and Design: RISC-V Edition](https://www.elsevier.com/books/computer-organization-and-design-risc-v-edition/patterson/978-0-12-812275-4)*


## How It Works

This is an educational technical project aimed at teaching CWRU computer engineering students 
how to design a single-cycle RISC-V processor in Verilog. This `info.md` is meant to serve as 
pedagogical material for those also interested in learning computer architecture concepts. The
deliverable will be a complete processor that executes a Fibonacci sequence using RISC-V assembly.

## Pipeline (Big Picture)

The CPU has five stages that it must go through to complete a single instruction:
1. `IF` / Instruction Fetch: Fetches the current cycle's instruction from memory
2. `ID`/ Instruction Decode: Converts instructions into register addresses, opcodes, etc.
3. `EX`: Execute: Perform operations with those opcodes/register values 
4. `MEM`: Memory: Writes/loads data to memory, more important for load/store instructions
5. `WB`: Writeback: Writes result into the register file for next cycle


## Components

### Program Counter

The program counter acts as a tracker for the CPU. Namely, what instruction are we executing right now?
It is a register that holds the address of the instruction that's currently being executed. This number
can be updated based on normal sequencing (+4 bytes per cycle for 4-byte instructions) or conditional branches
and jumps that can happen in the code. For designing it, you'll need:

- `clk`: program counter needs to update on the clock, keeping it synchronized with the rest of the CPU
- `pc_in`: this is a little tricky but this is the next address to execute, it may come from a branch 
- `pc_out`: this is the current address being executed, and `pc_in` will propagate on the next edge

Essentially, the program counter is just a large 32-bit flip-flop if that helps the Verilog code.

### Instruction Memory

### Register File

### Immediate Generator

### Arithmetic Logic Unit

### Data Memory

## How to test

Explain how to use your project

## External hardware

There's no hardware needed to run this ASIC! It will run a Fibonacci sequence 
on the seven-segment display using assembly instructions.
