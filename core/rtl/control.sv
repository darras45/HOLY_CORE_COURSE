module control (
    input  logic [6:0]  opcode,
    output logic        reg_we,
    output logic        alu_src_imm,
    output logic [2:0]  alu_op,
    output logic        mem_read,
    output logic        mem_write,
    output logic        mem_to_reg,
    output logic        is_branch
);
  always_comb begin
    // defaults = NOP
    reg_we      = 0;
    alu_src_imm = 0;
    alu_op      = 3'b000; // ADD by default
    mem_read    = 0;
    mem_write   = 0;
    mem_to_reg  = 0;
    is_branch   = 0;

    unique case (opcode)
      7'b0010011: begin // ADDI
        reg_we      = 1;
        alu_src_imm = 1;      // use imm_i
        alu_op      = 3'b000; // ADD
      end
      7'b0000011: begin // LW
        reg_we      = 1;
        alu_src_imm = 1;      // base + imm_i
        mem_read    = 1;
        mem_to_reg  = 1;      // writeback from memory
        alu_op      = 3'b000; // ADD
      end
      7'b0100011: begin // SW
        alu_src_imm = 1;      // base + imm_s
        mem_write   = 1;
        alu_op      = 3'b000; // ADD
      end
      7'b1100011: begin // BRANCH (we use BEQ via funct3 in top)
        is_branch   = 1;
        alu_op      = 3'b000; // not used for equality compare
      end
      default: ; // keep defaults
    endcase
  end
endmodule
