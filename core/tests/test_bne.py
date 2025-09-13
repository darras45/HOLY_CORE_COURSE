import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def bne_smoke(dut):
    """BNE behavior: first BNE not taken (x1==x2), later BNE taken (x1!=x2). Final x3=55."""
    # Start a free-running 10 ns clock on dut.clk
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Active-low reset
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # Let the program run
    for _ in range(60):
        await RisingEdge(dut.clk)

    x3 = int(dut.x3_o.value)
    assert x3 == 55, f"Expected x3=55 after BEQ/BNE flow, got {x3}"
