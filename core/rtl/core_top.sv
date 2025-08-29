module core_top(
  input  logic        clk,
  input  logic        rst_n,
  // observe-only outputs for tests
  output logic [31:0] pc_o,
  output logic [31:0] instr_o,
  output logic [6:0]  opcode_o,
  output logic [2:0]  funct3_o,
  output logic [4:0]  rs1_o,
  output logic [4:0]  rd_o,
  output logic [31:0] imm_i_o,
  output logic [31:0] wb_data_o,
  output logic [31:0] x1_o,
  output logic [31:0] x2_o,
  output logic [31:0] x3_o
);
  // FETCH
  logic [31:0] pc_q, next_pc;
  assign next_pc = pc_q + 32'd4;
  pc        u_pc   (.clk, .rst_n, .next_pc(next_pc), .pc_q(pc_q));
  instr_mem u_imem (.addr(pc_q), .instr(instr_o));
  assign pc_o = pc_q;

  // DECODE
  logic [6:0] opcode, funct7;
  logic [2:0] funct3;
  logic [4:0] rs1, rs2, rd;
  logic       reg_we, alu_src_imm;
  logic [2:0] alu_op;
  logic       mem_read, mem_write, mem_to_reg;

  control u_ctrl(
    .instr   (instr_o),
    .opcode  (opcode),
    .funct3  (funct3),
    .funct7  (funct7),
    .rs1     (rs1),
    .rs2     (rs2),
    .rd      (rd),
    .reg_we,
    .alu_src_imm,
    .alu_op,
    .mem_read,
    .mem_write,
    .mem_to_reg
  );

  // IMMEDIATES
  logic [31:0] imm_i, imm_s, imm_b;
  imm_gen u_imm(.instr(instr_o), .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b));

  // REGISTER FILE
  logic [31:0] rd1, rd2;
  regfile u_rf(
    .clk, .we(reg_we),
    .rs1, .rs2, .rd,
    .wd (wb_data_o),
    .rd1, .rd2,
    .x1_val(x1_o),
    .x2_val(x2_o),
    .x3_val(x3_o)
  );

  // EXECUTE (ALU addr calc)
  logic [31:0] op_a, op_b, alu_y;
  assign op_a = rd1;
  // address immediate: I-type for LW, S-type for SW
  wire [31:0] addr_imm = (mem_write) ? imm_s : imm_i;
  assign op_b = (alu_src_imm) ? addr_imm : rd2;

  alu u_alu(.a(op_a), .b(op_b), .op(alu_op), .y(alu_y));

  // DATA MEMORY
  logic [31:0] dmem_rdata;
  data_mem u_dmem(
    .clk    (clk),
    .we     (mem_write),
    .addr   (alu_y),
    .wdata  (rd2),        // store data comes from rs2
    .rdata  (dmem_rdata)  // load data returns here
  );

  // WRITEBACK MUX
  assign wb_data_o = (mem_to_reg) ? dmem_rdata : alu_y;

  // expose
  assign opcode_o = opcode;
  assign funct3_o = funct3;
  assign rs1_o    = rs1;
  assign rd_o     = rd;
  assign imm_i_o  = imm_i;
endmodule
