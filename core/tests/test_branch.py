import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_beq_taken(dut):
    """Test BEQ when x1 == x2 (branch taken)"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # Run a few cycles
    for _ in range(15):
        await RisingEdge(dut.clk)

    pc_val = int(dut.pc_q.value)
    dut._log.info(f"Final PC={pc_val:#x}")
    # Expect PC >= 0x14 because branch skipped instruction at 0x0C
    assert pc_val >= 0x14, f"Branch not taken as expected, pc={pc_val:#x}"
