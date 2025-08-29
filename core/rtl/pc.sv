module pc (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        branch_taken,
    input  logic [31:0] branch_target,
    output logic [31:0] pc_q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      pc_q <= 32'b0;
    else if (branch_taken)
      pc_q <= branch_target;
    else
      pc_q <= pc_q + 32'd4;
  end
endmodule
