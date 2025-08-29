module instr_mem #(
  parameter int DEPTH_WORDS = 256
)(
  input  logic [31:0] addr,
  output logic [31:0] instr
);
  localparam int ADDR_W = $clog2(DEPTH_WORDS);

  logic [31:0] mem [0:DEPTH_WORDS-1];

  // Program layout:
  // 0x00: addi x1, x0, 1   0x0010_0093
  // 0x04: addi x2, x0, 1   0x0010_0113  (x1 == x2)
  // 0x08: sw   x1, 0(x0)   0x0010_2023
  // 0x0C: lw   x3, 0(x0)   0x0000_2183
  // 0x10: beq  x1, x2, +8  0x0020_8663  (skip next)
  // 0x14: addi x3, x0, 99  0x0630_0193  (skipped if branch taken)
  // 0x18: addi x3, x0, 42  0x02A0_0193  (branch target)

  initial begin : init
    integer i;
    for (i = 0; i < DEPTH_WORDS; i++) mem[i] = 32'h0000_0013; // NOP (ADDI x0,x0,0)

    mem[0] = 32'h0010_0093; // addi x1, x0, 1
    mem[1] = 32'h0010_0113; // addi x2, x0, 1
    mem[2] = 32'h0010_2023; // sw   x1, 0(x0)
    mem[3] = 32'h0000_2183; // lw   x3, 0(x0)
    mem[4] = 32'h0020_8663; // beq  x1, x2, +8
    mem[5] = 32'h0630_0193; // addi x3, x0, 99
    mem[6] = 32'h02A0_0193; // addi x3, x0, 42
  end

  wire [ADDR_W-1:0] word_idx = addr[ADDR_W+1:2];
  assign instr = mem[word_idx];
endmodule
