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

---

## Pipeline (Big Picture)

The CPU has five stages that it must go through to complete a single instruction:
1. `IF` / `Instruction Fetch`: Fetches the current cycle's instruction from memory
2. `ID`/ `Instruction Decode`: Converts instructions into register addresses, opcodes, etc.
3. `EX` / `Execute`: Perform operations with those opcodes/register values 
4. `MEM` / `Memory`: Writes/loads data to memory, more important for load/store instructions
5. `WB` / `Writeback`: Writes result into the register file for next cycle, repeat

---

## Components

### Program Counter

The program counter acts as a tracker for the CPU. Namely, what instruction are we executing right now?
It is a register that holds the address of the instruction that's currently being executed. This number
can be updated based on normal sequencing (+4 bytes per cycle for 4-byte instructions) or conditional branches
and jumps that can happen in the code. The pins you'll need are:

- `clk`: program counter needs to update on the clock, keeping it synchronized with the rest of the CPU
- `pc_in`: this is a little tricky but this is the next address to execute, it may come from a branch 
- `pc_out`: this is the current address being executed, and `pc_in` will propagate on the next edge

Essentially, the program counter is just a large 32-bit flip-flop if that helps the Verilog code. 
As for the lack of reset pins for this program counter, it's cleaner to have a separate register
in the top module that's sensitive to the reset and propagate it into the program counter, as opposed
to having reset here and needing to reset the `pc` signal in the top module anyway.

### Instruction Memory

Instruction memory is a piece of RAM that stores your instructions for the processor to execute. It may
be more intuitive to think of an instruction memory as an array:

```C
// this array would be your instruction memory
unsigned char instructions[256] ={0x00000013, 0x00000013, 0x00000013, ...};
// to access the array, you need to do some indexing
// normal cpu operation

// we have a register named curr_instr
unsigned char curr_instr;

// we use a for loop here, the counter variable
// i is just like our program counter
for (int i = 0; i < 256; i++) {
    curr_instr = instructions[i];
}
```

For those who are technically sharp, this isn't 100% accurate because of possible branch/jump instructions,
but for 99% of cases when the CPU is running sequentially, this is a perfect parallel. The pins you'll need are:

- `pc`: the output of your program counter (incrementer)
- `instr`: whatever instruction needs to be executed

Hint: to instantiate an array block in Verilog, you can do this:

```Verilog
    wire [WIDTH-1:0] mem [0:DEPTH-1];
```
- Just remember if you're updating it in a process, use `reg` instead
- `mem` is just the assigned name, you can name it anything
- `WIDTH` is how wide each word is, maybe let's say 32 bits wide
- `DEPTH` is how many words can be stored at a given time in `mem`

### Register File

The `register file` is a module that, in RISC-V specification, contains 32 distinct registers. Each register itself can store a 32-bit word, which can then be used as operands within the ALU. Some design questions:

- Does the register file need a `clk` signal? What are the advantages/tradeoffs of having a clocked register file?
- We will need read and write ports for the register file. 
For 32 registers, how many bits do we need to identify a unique
register? We will need three addresses: `rd_addr1`, `rd_addr2`, and `wr_addr`.

### Immediate Generator

The immediate generator, like its name suggests, generates an immediate value. But what is an immediate value? Take a look at the following assembly instruction:

```txt
add x3, x1, x2
```

In RISC-V, there are six types of instructions: R-type, I-type, S-type, B-type, U-type, and J-type instructions. This `add` instruction is an R-type instruction, as it adds the contents of two registers (namely `x1 ` and `x2`) and saves the result in `x3`. There is no immediate here. Now let's take a look at an I-type instruction:

```txt
addi x3, x1, 1
```

With a blank register file that will initiate all register values to 0 on power up, you would be pretty limited in what you can do with just zeroes. This "add immediate" instruction allows you to add any integer with x1, and save the result to x3. 

<p align="center">
    <img 
    src="./images/riscv-format.png" 
    height="250px"
    />
</p>

*Source: RISC-V International, The RISC-V Instruction Set Manual, Volume I: User-Level ISA, Version 2.2.*

Refer to this diagram to see how the immediates are encoded in each instruction. You can determine based on the opcodes what type of instruction it is. As for designing/writing the RTL code, treat the immediate generator as a switch case that based on the opcode, decodes the immediate value from the instruction. For simplicity, make the immediate a 32-bit logic value to keep things consistent.

### Control Unit

The control unit asserts flags that help facilitate the `execute` stage of the CPU. Generally, it needs to take in the opcode, funct3, and funct7 as inputs, and it outputs the following values:

- RegWrite: write to reg
- MemRead: read from memory
- MemWrite: write to memory
- BranchEq: did branch equal
- MemToReg: Load to reg from mem
- ALUSrc: add from register or immediate
- ALUCont: opcode for ALU
- JMP: did a jump occur

### Arithmetic Logic Unit

### Data Memory

---

## How to test

Explain how to use your project

---

## External hardware

There's no hardware needed to run this ASIC! It will run a Fibonacci sequence 
on the seven-segment display using assembly instructions.

---

## References

---
