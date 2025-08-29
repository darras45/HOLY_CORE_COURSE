import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

@cocotb.test()
async def addi_exec_and_writeback(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Deassert reset and sample the ADDI cycle *before* the next posedge
    dut.rst_n.value = 1
    await ReadOnly()
    assert int(dut.instr_o.value) == 0x00100093, "Expect ADDI x1,x0,1 at PC=0"

    # During this same cycle, ALU result (wb path) should be 1 combinationally
    assert int(dut.wb_data_o.value) == 1, f"wb_data_o (ALU) should be 1 pre-edge, got {int(dut.wb_data_o.value)}"

    # On the next posedge, regfile writes x1 <= 1
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.x1_o.value) == 1, f"x1 should capture 1 after edge, got {int(dut.x1_o.value)}"
