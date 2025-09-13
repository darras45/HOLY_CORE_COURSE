import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def mem_store_then_load(dut):
    """Program: sw x1,0(x0); lw x3,0(x0) -> x3 should equal x1 (=1) shortly after LW."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # active-low reset
    dut.rst_n.value = 0
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # Timeline with our program (1 instr per cycle):
    # t0: JAL
    # t1: ADDI x1,1
    # t2: SW  x1,0(x0)
    # t3: LW  x3,0(x0)
    # Sample immediately after LW settles, before later code clobbers x3.
    for _ in range(6):
        await RisingEdge(dut.clk)

    x1 = int(dut.x1_o.value)
    x3 = int(dut.x3_o.value)
    dut._log.info(f"After SW/LW (early sample): x1={x1}, x3={x3}")
    assert x1 == 1 and x3 == 1, f"SW/LW failed: expected x1=x3=1, got x1={x1}, x3={x3}"
