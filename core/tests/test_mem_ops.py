import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def mem_store_then_load(dut):
    """Program: sw x1,0(x0); lw x3,0(x0) -> x3 should equal x1 (=1)"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # enough cycles to execute addi/addi, sw, lw
    for _ in range(14):
        await RisingEdge(dut.clk)

    x1 = int(dut.x1_o.value)
    x3 = int(dut.x3_o.value)
    dut._log.info(f"After SW/LW: x1={x1}, x3={x3}")
    assert x3 == x1 == 1, f"SW/LW failed: expected x1=x3=1, got x1={x1}, x3={x3}"
