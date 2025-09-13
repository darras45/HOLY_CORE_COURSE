module control (
  input  logic [6:0] opcode,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,

  output logic       reg_write,
  output logic       alu_src_imm,
  output logic       mem_read,
  output logic       mem_write,
  output logic       mem_to_reg,
  output logic       is_branch
);

  always_comb begin
    reg_write   = 1'b0;
    alu_src_imm = 1'b0;
    mem_read    = 1'b0;
    mem_write   = 1'b0;
    mem_to_reg  = 1'b0;
    is_branch   = 1'b0;

    unique case (opcode)
      7'b0010011: begin // OP-IMM (ADDI)
        reg_write   = 1'b1;
        alu_src_imm = 1'b1;
      end
      7'b0000011: begin // LOAD (LW)
        reg_write   = 1'b1;
        alu_src_imm = 1'b1;
        mem_read    = 1'b1;
        mem_to_reg  = 1'b1;
      end
      7'b0100011: begin // STORE (SW)
        alu_src_imm = 1'b1;
        mem_write   = 1'b1;
      end
      7'b1100011: begin // BRANCH (BEQ/BNE)
        is_branch   = 1'b1;
      end
      7'b1101111: begin // JAL
        reg_write   = 1'b1; // write link (PC+4) to rd
      end
      default: ;
    endcase
  end

endmodule
