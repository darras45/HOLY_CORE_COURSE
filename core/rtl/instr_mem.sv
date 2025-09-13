module instr_mem #(
  parameter int DEPTH_WORDS = 256
)(
  input  logic [31:0] addr,   // byte address
  output logic [31:0] instr
);
  localparam int ADDR_W = $clog2(DEPTH_WORDS);
  logic [31:0] mem [0:DEPTH_WORDS-1];

  // Program layout (one instr/cycle in this single-cycle design):
  // 0x00: jal  x1,+8        = 0x008000ef  ; link=PC+4=0x4, jump to 0x08
  // 0x04: addi x3,x0,99     = 0x06300193  ; skipped by JAL
  // 0x08: addi x1,x0,1      = 0x00100093
  // 0x0C: sw   x1,0(x0)     = 0x00102023  ; store 1 to DMEM[0]
  // 0x10: lw   x3,0(x0)     = 0x00002183  ; x3 <- 1 (this is what mem test checks)
  // 0x14: addi x2,x0,1      = 0x00100113  ; x1==x2
  // 0x18: bne  x1,x2,+8     = 0x00209463  ; NOT taken
  // 0x1C: beq  x1,x2,+8     = 0x00208463  ; taken -> 0x24
  // 0x20: addi x3,x0,99     = 0x06300193  ; skipped by BEQ
  // 0x24: addi x3,x0,42     = 0x02A00193
  // 0x28: addi x2,x0,2      = 0x00200113  ; x1!=x2 now
  // 0x2C: bne  x1,x2,+8     = 0x00209463  ; TAKEN -> 0x34
  // 0x30: addi x3,x0,77     = 0x04D00193  ; skipped by BNE
  // 0x34: addi x3,x0,55     = 0x03700193  ; final (used by branch tests)

  initial begin
    integer i;
    for (i = 0; i < DEPTH_WORDS; i++) mem[i] = 32'h0000_0013; // NOP

    mem[0]  = 32'h0080_00ef; // jal  x1,+8
    mem[1]  = 32'h0630_0193; // addi x3,99 (skipped)

    mem[2]  = 32'h0010_0093; // addi x1,1
    mem[3]  = 32'h0010_2023; // sw   x1,0(x0)
    mem[4]  = 32'h0000_2183; // lw   x3,0(x0)
    mem[5]  = 32'h0010_0113; // addi x2,1
    mem[6]  = 32'h0020_9463; // bne  x1,x2,+8 (not taken)
    mem[7]  = 32'h0020_8463; // beq  x1,x2,+8 (taken)
    mem[8]  = 32'h0630_0193; // addi x3,99 (skipped)
    mem[9]  = 32'h02A0_0193; // addi x3,42
    mem[10] = 32'h0020_0113; // addi x2,2
    mem[11] = 32'h0020_9463; // bne  x1,x2,+8 (taken)
    mem[12] = 32'h04D0_0193; // addi x3,77 (skipped)
    mem[13] = 32'h0370_0193; // addi x3,55 (final)
  end

  wire [ADDR_W-1:0] word_idx = addr[ADDR_W+1:2];
  assign instr = mem[word_idx];
endmodule
