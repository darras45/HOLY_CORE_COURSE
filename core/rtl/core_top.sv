module core_top (
  input  logic        clk,
  input  logic        rst_n,

  // debug/visibility
  output logic [31:0] pc,
  output logic [31:0] instr_o,
  output logic [31:0] wb_data_o,
  output logic [31:0] x1_o,
  output logic [31:0] x2_o,
  output logic [31:0] x3_o
);

  // -------------------------
  // PC
  // -------------------------
  logic [31:0] pc_q, next_pc;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc_q <= 32'd0;
    else        pc_q <= next_pc;
  end
  assign pc = pc_q;
  wire [31:0] pc_plus4 = pc_q + 32'd4;

  // -------------------------
  // Fetch
  // -------------------------
  logic [31:0] instr;
  instr_mem u_imem (
    .addr (pc_q),
    .instr(instr)
  );
  assign instr_o = instr;

  // fields
  wire [6:0]  opcode = instr[6:0];
  wire [2:0]  funct3 = instr[14:12];
  wire [6:0]  funct7 = instr[31:25];
  wire [4:0]  rs1    = instr[19:15];
  wire [4:0]  rs2    = instr[24:20];
  wire [4:0]  rd     = instr[11:7];

  // -------------------------
  // Decode
  // -------------------------
  logic reg_write, alu_src_imm, mem_read, mem_write, mem_to_reg, is_branch;
  control u_ctrl(
    .opcode     (opcode),
    .funct3     (funct3),
    .funct7     (funct7),
    .reg_write  (reg_write),
    .alu_src_imm(alu_src_imm),
    .mem_read   (mem_read),
    .mem_write  (mem_write),
    .mem_to_reg (mem_to_reg),
    .is_branch  (is_branch)
  );
  wire is_jal = (opcode == 7'b1101111);

  // -------------------------
  // Immediates
  // -------------------------
  logic [31:0] imm_i, imm_s, imm_b, imm_j;
  imm_gen u_imm(
    .instr (instr),
    .imm_i (imm_i),
    .imm_s (imm_s),
    .imm_b (imm_b),
    .imm_j (imm_j)
  );

  // -------------------------
  // Register file
  // -------------------------
  logic [31:0] rs1_data, rs2_data;
  logic [31:0] wb_data;
  regfile u_regfile (
    .clk    (clk),
    .we     (reg_write),
    .rs1    (rs1),
    .rs2    (rs2),
    .rd     (rd),
    .wd     (wb_data),
    .rd1    (rs1_data),
    .rd2    (rs2_data),
    .x1_val (x1_o),
    .x2_val (x2_o),
    .x3_val (x3_o)
  );

  // -------------------------
  // ALU (add/datapath base)
  // -------------------------
  logic [31:0] alu_a, alu_b, alu_y;
  assign alu_a = rs1_data;
  assign alu_b = alu_src_imm ? (mem_write ? imm_s : imm_i) : rs2_data;
  assign alu_y = alu_a + alu_b;

  // -------------------------
  // Data memory
  // -------------------------
  logic [31:0] mem_data;
  data_mem u_dmem (
    .clk   (clk),
    .addr  (alu_y),
    .we    (mem_write),
    .wdata (rs2_data),
    .rdata (mem_data)
  );

  // Writeback mux: JAL writes PC+4 to rd
  assign wb_data   = is_jal ? pc_plus4 : (mem_to_reg ? mem_data : alu_y);
  assign wb_data_o = wb_data;

  // -------------------------
  // Branch/JAL PC selection
  // -------------------------
  logic take_branch;
  always_comb begin
    take_branch = 1'b0;
    if (is_branch) begin
      unique case (funct3)
        3'b000: take_branch = (rs1_data == rs2_data); // BEQ
        3'b001: take_branch = (rs1_data != rs2_data); // BNE
        default: take_branch = 1'b0;
      endcase
    end
  end

  assign next_pc = is_jal         ? (pc_q + imm_j) :
                   (take_branch)  ? (pc_q + imm_b) :
                                     (pc_plus4);

endmodule
