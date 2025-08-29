module imm_gen(
  input  logic [31:0] instr,
  output logic [31:0] imm_i,  // I-type  (e.g., LW, ADDI)
  output logic [31:0] imm_s,  // S-type  (e.g., SW)
  output logic [31:0] imm_b   // B-type  (future)
);
  // I-type sign-extend [31:20]
  assign imm_i = {{20{instr[31]}}, instr[31:20]};

  // S-type: imm[11:5]=[31:25], imm[4:0]=[11:7]
  wire [11:0] imm_s_raw = {instr[31:25], instr[11:7]};
  assign imm_s = {{20{imm_s_raw[11]}}, imm_s_raw};

  // B-type: imm[12|10:5|4:1|11] << 1
  logic [12:0] b;
  assign b     = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  assign imm_b = {{19{b[12]}}, b};
endmodule
