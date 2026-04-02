# SPDX-FileCopyrightText: © 2024 CWRU Hacker Fab
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


# fibonacci sequence produced by the program:
# first sw fires after add x3,x1,x2 computes 0+1=1, so sequence starts at 1
FIBONACCI = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]

# how many cycles the CPU needs to reach the first sw instruction.
# _start has 4 addi instructions before loop, so first store is at cycle 4+3=7
# (4 inits + add + sw). Adjust if your pipeline behaves differently.
CYCLES_TO_FIRST_STORE = 7

# how many cycles between each subsequent store (6 instructions in the loop body)
CYCLES_PER_TERM = 6


@cocotb.test()
async def test_reset(dut):
    """PC and registers should be zero immediately after reset."""
    dut._log.info("Testing reset behavior")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value   = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0

    await ClockCycles(dut.clk, 5)

    # while in reset, uo_out should be 0
    assert dut.uo_out.value == 0, \
        f"Expected uo_out=0 during reset, got {dut.uo_out.value}"

    dut._log.info("Reset test passed")


@cocotb.test()
async def test_fibonacci(dut):
    """
    Run the Fibonacci program and check that uo_out (lower 8 bits of mem_data)
    reflects each term after the corresponding sw instruction commits.
    """
    dut._log.info("Starting Fibonacci test")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # reset
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1

    dut._log.info("Reset released — CPU running")

    # wait until the first store fires
    await ClockCycles(dut.clk, CYCLES_TO_FIRST_STORE)

    for i, expected in enumerate(FIBONACCI):
        await RisingEdge(dut.clk)
        observed = dut.uo_out.value.integer
        dut._log.info(f"  Term {i+1}: uo_out={observed}, expected={expected}")
        assert observed == expected, \
            f"FAIL at Fibonacci term {i+1}: got {observed}, expected {expected}"

        if i < len(FIBONACCI) - 1:
            # advance to just before the next store
            await ClockCycles(dut.clk, CYCLES_PER_TERM - 1)

    dut._log.info("All 10 Fibonacci terms matched — PASS")


@cocotb.test()
async def test_halt(dut):
    """after the program halts (jal x0, done), uo_out should stay stable."""
    dut._log.info("Testing halt stability")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1

    # run well past the end of the program
    total_program_cycles = CYCLES_TO_FIRST_STORE + (len(FIBONACCI) * CYCLES_PER_TERM) + 20
    await ClockCycles(dut.clk, total_program_cycles)

    snapshot = dut.uo_out.value.integer
    await ClockCycles(dut.clk, 10)

    assert dut.uo_out.value.integer == snapshot, \
        f"uo_out changed after halt: was {snapshot}, now {dut.uo_out.value.integer}"

    dut._log.info(f"Halt stable at uo_out={snapshot} — PASS")