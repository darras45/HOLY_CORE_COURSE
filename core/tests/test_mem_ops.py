import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

@cocotb.test()
async def mem_store_then_load(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # reset 2 cycles
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Deassert reset; pre-edge @PC=0 -> ADDI x1,x0,1
    dut.rst_n.value = 1
    await ReadOnly()
    assert int(dut.instr_o.value) == 0x00100093
    assert int(dut.wb_data_o.value) == 1

    # Edge 1: x1 = 1, PC=4 (ADDI x2,x1,5)
    await RisingEdge(dut.clk); await ReadOnly()
    assert int(dut.x1_o.value) == 1
    assert int(dut.instr_o.value) == 0x00508113
    assert int(dut.wb_data_o.value) == 6

    # Edge 2: x2 = 6, PC=8 (SW x1,0(x0))
    await RisingEdge(dut.clk); await ReadOnly()
    assert int(dut.x2_o.value) == 6
    assert int(dut.instr_o.value) == 0x00102023  # store

    # Edge 3: store commits; PC=12 (LW x3,0(x0)); pre-edge ALU addr formed, DMEM read visible
    await RisingEdge(dut.clk); await ReadOnly()
    assert int(dut.instr_o.value) == 0x00002183  # load
    # At this pre-edge, DMEM rdata should reflect the value stored at addr 0 -> 1
    assert int(dut.wb_data_o.value) == 1

    # Edge 4: x3 captures 1
    await RisingEdge(dut.clk); await ReadOnly()
    assert int(dut.x3_o.value) == 1
