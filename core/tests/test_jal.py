import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def jal_writes_link_and_jumps(dut):
    """JAL at PC=0 should set x1=PC+4=4 and jump to 0x8. Sequence then continues to final x3=55."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # active-low reset
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # Execute the JAL at PC=0 and sample right away before x1 is overwritten by later ADDI.
    await RisingEdge(dut.clk)   # cycle that executes JAL and writes link at posedge
    x1_now = int(dut.x1_o.value)
    assert x1_now == 4, f"JAL link incorrect: expected x1=4 right after JAL, got {x1_now}"

    # Let the rest of the program run; final x3 should be 55 (same as branch flow)
    for _ in range(80):
        await RisingEdge(dut.clk)

    assert int(dut.x3_o.value) == 55, f"Final x3 should be 55, got {int(dut.x3_o.value)}"
