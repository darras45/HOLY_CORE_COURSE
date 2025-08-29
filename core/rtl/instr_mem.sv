module instr_mem #(
  parameter int DEPTH_WORDS = 256
)(
  input  logic [31:0] addr,   // byte address
  output logic [31:0] instr
);
  localparam int ADDR_W = $clog2(DEPTH_WORDS);

  logic [31:0] mem [0:DEPTH_WORDS-1];

  // Program:
  // 0x0000: addi x1,x0,1   = 0x00100093
  // 0x0004: addi x2,x1,5   = 0x00508113
  // 0x0008: sw   x1,0(x0)  = 0x00102023
  // 0x000C: lw   x3,0(x0)  = 0x00002183
  initial begin : init
    integer i;
    for (i = 0; i < DEPTH_WORDS; i++) mem[i] = 32'h0000_0013; // NOP: addi x0,x0,0
    mem[0] = 32'h0010_0093; // addi x1,x0,1
    mem[1] = 32'h0050_8113; // addi x2,x1,5
    mem[2] = 32'h0010_2023; // sw   x1,0(x0)
    mem[3] = 32'h0000_2183; // lw   x3,0(x0)
  end

  // word index = addr >> 2, sized to depth
  wire [ADDR_W-1:0] word_idx = addr[ADDR_W+1:2];
  assign instr = mem[word_idx];
endmodule
