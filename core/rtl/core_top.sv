module core_top (
    input  logic        clk,
    input  logic        rst_n,

    // test visibility / debug taps
    output logic [31:0] pc_q,
    output logic [31:0] instr_o,
    output logic [31:0] wb_data_o,
    output logic [31:0] x1_o,
    output logic [31:0] x2_o,
    output logic [31:0] x3_o
);
    // === Fetch ===
    logic        branch_taken;
    logic [31:0] branch_target;

    pc u_pc (
        .clk          (clk),
        .rst_n        (rst_n),
        .branch_taken (branch_taken),
        .branch_target(branch_target),
        .pc_q         (pc_q)
    );

    instr_mem u_imem (
        .addr  (pc_q),
        .instr (instr_o)
    );

    // === Decode fields ===
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [4:0]  rs1, rs2, rd;

    assign opcode = instr_o[6:0];
    assign rd     = instr_o[11:7];
    assign funct3 = instr_o[14:12];
    assign rs1    = instr_o[19:15];
    assign rs2    = instr_o[24:20];

    // === Immediates ===
    logic [31:0] imm_i, imm_s, imm_b;
    imm_gen u_imm (
        .instr (instr_o),
        .imm_i (imm_i),
        .imm_s (imm_s),
        .imm_b (imm_b)
    );

    // === Control ===
    logic        reg_we;
    logic        alu_src_imm;
    logic [2:0]  alu_op;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        is_branch;

    control u_ctrl (
        .opcode     (opcode),
        .reg_we     (reg_we),
        .alu_src_imm(alu_src_imm),
        .alu_op     (alu_op),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .is_branch  (is_branch)
    );

    // === Register file ===
    logic [31:0] rd1, rd2, wb_data;
    regfile u_rf (
        .clk   (clk),
        .we    (reg_we),
        .rs1   (rs1),
        .rs2   (rs2),
        .rd    (rd),
        .wd    (wb_data),
        .rd1   (rd1),
        .rd2   (rd2),
        .x1_val(x1_o),
        .x2_val(x2_o),
        .x3_val(x3_o)
    );

    // === ALU ===
    logic [31:0] alu_b, alu_y;
    always_comb begin
        // choose immediate kind for ALU b:
        // - SW uses S-imm (store offset)
        // - otherwise immediate operations use I-imm
        if (alu_src_imm) begin
            if (mem_write)
                alu_b = imm_s;
            else
                alu_b = imm_i;
        end else begin
            alu_b = rd2;
        end
    end

    alu u_alu (
        .a  (rd1),
        .b  (alu_b),
        .op (alu_op),
        .y  (alu_y)
    );

    // === Data memory ===
    logic [31:0] mem_data;
    data_mem u_dmem (
        .clk   (clk),
        .addr  (alu_y),
        .we    (mem_write),
        .wdata (rd2),
        .rdata (mem_data)
    );

    // === Write-back mux ===
    assign wb_data   = mem_to_reg ? mem_data : alu_y;
    assign wb_data_o = wb_data;

    // === Branch decision (BEQ only: funct3==3'b000) ===
    assign branch_taken  = is_branch && (funct3 == 3'b000) && (rd1 == rd2);
    assign branch_target = pc_q + imm_b;
endmodule
