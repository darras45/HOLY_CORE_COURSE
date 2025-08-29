import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly

@cocotb.test()
async def smoke(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # reset for 2 cycles
    dut.rst_n.value = 0
    dut.a.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # release reset and wait a clean cycle
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info(f"After reset: y={int(dut.y.value)} (expect 0)")

    # DRIVE on falling edge (never in ReadOnly)
    await FallingEdge(dut.clk)
    dut.a.value = 41
    cocotb.log.info("Drove a=41")

    # Wait ONE posedge for y to update, then read-only to sample
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info(f"Cycle+1: a={int(dut.a.value)} y={int(dut.y.value)}")

    # Give it one more cycle just to be extra safe (helps if any sim delta)
    await RisingEdge(dut.clk)
    await ReadOnly()
    cocotb.log.info(f"Cycle+2: a={int(dut.a.value)} y={int(dut.y.value)}")

    assert int(dut.y.value) == 42, f"Expected 42, got {int(dut.y.value)}"
