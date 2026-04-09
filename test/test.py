# SPDX-FileCopyrightText: © 2024 CWRU Hacker Fab
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

FIBONACCI = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]  # fixed sequence
PRNT_OPCODE = 0x7F


async def reset(dut):
    """Helper to apply and release reset."""
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value  = 1


@cocotb.test()
async def test_reset(dut):
    """uo_out should be 0 during reset."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0

    await ClockCycles(dut.clk, 5)
    assert dut.uo_out.value == 0, \
        f"Expected uo_out=0 during reset, got {dut.uo_out.value}"
    dut._log.info("Reset test passed")


@cocotb.test()
async def test_fibonacci(dut):
    """
    Poll for each PRNT instruction (opcode 0x7F) and check
    rd_data1 matches the expected fibonacci term.
    """
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    dut._log.info("Reset released — CPU running")

    cpu = dut.user_project

    for i, expected in enumerate(FIBONACCI):
        while True:
            await RisingEdge(dut.clk)
            instr = cpu.current_instruction.value.to_unsigned()
            if dut.rst_n.value == 1 and (instr & 0x7F) == PRNT_OPCODE:
                break

        observed = cpu.rd_data1.value.to_unsigned()
        dut._log.info(f"  Term {i+1}: rd_data1={observed}, expected={expected}")
        assert observed == expected, \
            f"FAIL at Fibonacci term {i+1}: got {observed}, expected {expected}"

    dut._log.info("All 10 Fibonacci terms matched — PASS")


@cocotb.test()
async def test_pc_advances(dut):
    """PC should increment by 4 each cycle during normal execution."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    cpu = dut.user_project
    prev_pc = None
    consecutive = 0

    for _ in range(100):
        await RisingEdge(dut.clk)
        current_pc = cpu.pc_out.value.to_unsigned()
        instr = cpu.current_instruction.value.to_unsigned()
        opcode = instr & 0x7F

        # skip branches, jumps, and PRNT
        if opcode in (0x63, 0x6F, 0x67, PRNT_OPCODE):
            prev_pc = None
            continue

        if prev_pc is not None:
            assert current_pc == (prev_pc + 4) & 0xFFFFFFFF, \
                f"PC did not advance by 4: prev={prev_pc:#010x}, curr={current_pc:#010x}"
            consecutive += 1
            if consecutive >= 5:
                break
        prev_pc = current_pc

    assert consecutive >= 5, "Could not find 5 consecutive non-branch PC increments"
    dut._log.info(f"PC advance test passed ({consecutive} consecutive +4 steps verified)")


@cocotb.test()
async def test_halt(dut):
    """After all fibonacci terms print, uo_out should stay stable."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    cpu = dut.user_project
    prints_seen = 0

    for _ in range(2000):
        await RisingEdge(dut.clk)
        instr = cpu.current_instruction.value.to_unsigned()
        if (instr & 0x7F) == PRNT_OPCODE:
            prints_seen += 1

    assert prints_seen >= len(FIBONACCI), \
        f"Only saw {prints_seen} PRNT instructions, expected at least {len(FIBONACCI)}"

    snapshot = dut.uo_out.value.to_unsigned()
    await ClockCycles(dut.clk, 20)
    assert dut.uo_out.value.to_unsigned() == snapshot, \
        f"uo_out changed after halt: was {snapshot}, now {dut.uo_out.value.to_unsigned()}"

    dut._log.info(f"Halt stability test passed — uo_out stable at {snapshot}")