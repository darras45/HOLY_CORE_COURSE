import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

@cocotb.test()
async def decode_addi_fields(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # reset (2 cycles)
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # deassert and sample same cycle (before next posedge)
    dut.rst_n.value = 1
    await ReadOnly()

    instr0 = int(dut.instr_o.value)
    assert instr0 == 0x00100093, f"instr@0 mismatch: {instr0:#010x}"

    assert int(dut.opcode_o.value) == 0x13, "opcode != OP-IMM (0x13)"
    assert int(dut.funct3_o.value) == 0x0,  "funct3 != 0 (ADDI)"
    assert int(dut.rs1_o.value)    == 0x0,  "rs1 != x0"
    assert int(dut.rd_o.value)     == 0x1,  "rd != x1"
    assert int(dut.imm_i_o.value)  == 0x1,  "imm_i != 1"
