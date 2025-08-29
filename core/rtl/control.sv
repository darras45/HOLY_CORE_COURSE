module control(
  input  logic [31:0] instr,
  // raw fields
  output logic [6:0]  opcode,
  output logic [2:0]  funct3,
  output logic [6:0]  funct7,
  output logic [4:0]  rs1, rs2, rd,
  // controls
  output logic        reg_we,
  output logic        alu_src_imm,
  output logic [2:0]  alu_op,
  output logic        mem_read,
  output logic        mem_write,
  output logic        mem_to_reg
);
  assign opcode = instr[6:0];
  assign rd     = instr[11:7];
  assign funct3 = instr[14:12];
  assign rs1    = instr[19:15];
  assign rs2    = instr[24:20];
  assign funct7 = instr[31:25];

  always_comb begin
    // defaults
    reg_we      = 1'b0;
    alu_src_imm = 1'b0;
    alu_op      = 3'd0;  // 0 = ADD
    mem_read    = 1'b0;
    mem_write   = 1'b0;
    mem_to_reg  = 1'b0;

    unique case (opcode)
      7'b0010011: begin // OP-IMM (ADDI)
        if (funct3 == 3'b000) begin
          reg_we      = 1'b1;
          alu_src_imm = 1'b1;
          alu_op      = 3'd0;  // ADD
        end
      end
      7'b0000011: begin // LOAD (LW)
        if (funct3 == 3'b010) begin
          reg_we      = 1'b1;  // write loaded data to rd
          alu_src_imm = 1'b1;  // base + imm
          alu_op      = 3'd0;  // ADD
          mem_read    = 1'b1;
          mem_to_reg  = 1'b1;  // select DMEM read for WB
        end
      end
      7'b0100011: begin // STORE (SW)
        if (funct3 == 3'b010) begin
          reg_we      = 1'b0;  // no reg write
          alu_src_imm = 1'b1;  // base + imm
          alu_op      = 3'd0;  // ADD
          mem_write   = 1'b1;
        end
      end
      default: /* NOP */;
    endcase
  end
endmodule
