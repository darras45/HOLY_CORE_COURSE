import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

@cocotb.test()
async def fetch_increments_pc(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Hold reset for 2 cycles
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Deassert reset and sample immediately (same cycle, before next posedge)
    dut.rst_n.value = 1
    await ReadOnly()
    pc0   = int(dut.pc_o.value)
    instr0 = int(dut.instr_o.value)
    assert pc0 == 0, f"PC should be 0 right after reset deassert, got {pc0:#x}"
    assert instr0 == 0x00100093, f"Expected ADDI x1,x0,1 at 0, got {instr0:#010x}"

    # Next cycles: PC increments by 4 each posedge
    await RisingEdge(dut.clk); await ReadOnly()
    assert int(dut.pc_o.value) == 4

    await RisingEdge(dut.clk); await ReadOnly()
    assert int(dut.pc_o.value) == 8
