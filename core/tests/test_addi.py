import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def addi_exec_and_writeback(dut):
    """ADDI x1, x0, 1 should write 1 into x1"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    for _ in range(8):
        await RisingEdge(dut.clk)

    x1 = int(dut.x1_o.value)
    dut._log.info(f"x1 after ADDI = {x1}")
    assert x1 == 1, f"ADDI failed: expected x1=1, got {x1}"
