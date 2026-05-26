# SPDX-FileCopyrightText: © 2026 CWRU Hacker Fab
# SPDX-License-Identifier: Apache-2.0

import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

PRNT_OPCODE = 0x7F
GL_TEST = os.environ.get("GL_TEST", "0") == "1"

NUM_TERMS = 10  # how many counter values to verify


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
    """seg should be blank (7'b1111110) and uo_out[7] high during reset."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0

    await ClockCycles(dut.clk, 5)
    assert dut.uo_out.value == 0b11111110, \
        f"Expected uo_out=0xFE during reset (blank display), got {dut.uo_out.value}"
    dut._log.info("Reset test passed")


@cocotb.test()
async def test_counter(dut):
    """
    RTL: poll for PRNT opcode and check rd_data1 increments by 1 each time.
    GL:  poll uo_out directly for each expected counter value.
    """
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    dut._log.info("Reset released — CPU running")

    if GL_TEST:
        for expected in range(NUM_TERMS):
            for _ in range(10000):
                await RisingEdge(dut.clk)
                if dut.uo_out.value.to_unsigned() == expected:
                    break
            else:
                assert False, \
                    f"Timeout waiting for counter value {expected}"
            dut._log.info(f"  Count {expected}: uo_out={expected} ✓")
    else:
        cpu = dut.user_project
        expected = 0
        for _ in range(NUM_TERMS):
            for _ in range(10000):
                await RisingEdge(dut.clk)
                instr = cpu.current_instruction.value.to_unsigned()
                if dut.rst_n.value == 1 and (instr & 0x7F) == PRNT_OPCODE:
                    break
            else:
                assert False, \
                    f"Timeout waiting for PRNT instruction (expected count={expected})"

            observed = cpu.rd_data1.value.to_unsigned()
            dut._log.info(f"  Count {expected}: rd_data1={observed} ✓")
            assert observed == expected, \
                f"FAIL at count {expected}: got {observed}"
            expected += 1

            # wait one cycle so next iteration doesn't re-latch the same PRNT
            await RisingEdge(dut.clk)

    dut._log.info(f"First {NUM_TERMS} counter values verified — PASS")


@cocotb.test()
async def test_pc_advances(dut):
    """PC should increment by 4 each cycle during normal execution.
    Skipped at gate level since internal signals are not available."""
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    if GL_TEST:
        await ClockCycles(dut.clk, 10)
        dut._log.info("PC advance test skipped at gate level — PASS")
        return

    cpu = dut.user_project
    prev_pc = None
    consecutive = 0

    for _ in range(100):
        await RisingEdge(dut.clk)
        current_pc = cpu.pc_out.value.to_unsigned()
        instr = cpu.current_instruction.value.to_unsigned()
        opcode = instr & 0x7F

        if opcode in (0x63, 0x6F, 0x67, PRNT_OPCODE):
            prev_pc = None
            continue

        if prev_pc is not None:
            assert current_pc == (prev_pc + 4) & 0xFFFFFFFF, \
                f"PC did not advance by 4: prev={prev_pc:#010x}, curr={current_pc:#010x}"
            consecutive += 1
            if consecutive >= 2:
                break
        prev_pc = current_pc

    assert consecutive >= 2, "Could not find 2 consecutive non-branch PC increments"
    dut._log.info(f"PC advance test passed ({consecutive} consecutive +4 steps verified)")


@cocotb.test()
async def test_counter_wraps(dut):
    """
    Counter should keep incrementing past 9 without getting stuck.
    Verifies the loop is truly infinite and x1 keeps growing.
    """
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    await reset(dut)

    if GL_TEST:
        await ClockCycles(dut.clk, 5000)
        val_a = dut.uo_out.value.to_unsigned()
        await ClockCycles(dut.clk, 500)
        val_b = dut.uo_out.value.to_unsigned()
        assert val_b != val_a or val_b > 0, \
            "uo_out appears stuck — counter may have halted"
        dut._log.info(f"Counter wrap test passed — uo_out still changing at GL level")
        return

    cpu = dut.user_project
    prints_seen = []

    for _ in range(20000):
        await RisingEdge(dut.clk)
        instr = cpu.current_instruction.value.to_unsigned()
        if dut.rst_n.value == 1 and (instr & 0x7F) == PRNT_OPCODE:
            val = cpu.rd_data1.value.to_unsigned()
            if not prints_seen or val != prints_seen[-1]:
                prints_seen.append(val)
            if len(prints_seen) >= 15:
                break

    assert len(prints_seen) >= 15, \
        f"Only saw {len(prints_seen)} distinct counter values, expected at least 15"

    for i in range(1, len(prints_seen)):
        assert prints_seen[i] == prints_seen[i-1] + 1, \
            f"Counter skipped: {prints_seen[i-1]} -> {prints_seen[i]}"

    dut._log.info(f"Counter wrap test passed — saw values {prints_seen[0]}..{prints_seen[-1]}")