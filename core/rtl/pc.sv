module pc(
  input  logic        clk,
  input  logic        rst_n,
  input  logic [31:0] next_pc,
  output logic [31:0] pc_q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc_q <= 32'h0000_0000;
    else        pc_q <= next_pc;
  end
endmodule
