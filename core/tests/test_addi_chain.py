import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

@cocotb.test()
async def addi_chain_x1_then_x2(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Deassert reset and sample pre-edge (ADDI x1,x0,1 @ PC=0)
    dut.rst_n.value = 1
    await ReadOnly()
    assert int(dut.instr_o.value) == 0x00100093, "Expect ADDI x1,x0,1 at PC=0"
    assert int(dut.wb_data_o.value) == 1, "ALU/wb_data for ADDI@0 should be 1 pre-edge"

    # Edge 1: x1 should capture 1; PC -> 4
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.x1_o.value) == 1, "x1 should be 1 after first edge"

    # Now executing ADDI x2,x1,5 @ PC=4; pre-edge check ALU/wb=6
    assert int(dut.instr_o.value) == 0x00508113, "Expect ADDI x2,x1,5 at PC=4"
    assert int(dut.wb_data_o.value) == 6, "ALU/wb_data for ADDI@4 should be 6 pre-edge"

    # Edge 2: x2 should capture 6
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.x2_o.value) == 6, "x2 should be 6 after second edge"
