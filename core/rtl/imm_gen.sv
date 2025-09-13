module imm_gen (
  input  logic [31:0] instr,
  output logic [31:0] imm_i,
  output logic [31:0] imm_s,
  output logic [31:0] imm_b,
  output logic [31:0] imm_j
);
  // I-type
  wire [11:0] imm_i_u = instr[31:20];
  // S-type
  wire [11:0] imm_s_u = {instr[31:25], instr[11:7]};
  // B-type: [12|10:5|4:1|11|0], LSB=0
  wire [12:0] imm_b_u = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  // J-type: [20|10:1|11|19:12|0], LSB=0
  wire [20:0] imm_j_u = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

  // sign extend
  assign imm_i = {{20{imm_i_u[11]}}, imm_i_u};
  assign imm_s = {{20{imm_s_u[11]}}, imm_s_u};
  assign imm_b = {{19{imm_b_u[12]}}, imm_b_u};
  assign imm_j = {{11{imm_j_u[20]}}, imm_j_u};
endmodule
