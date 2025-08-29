module regfile(
  input  logic        clk,
  input  logic        we,
  input  logic [4:0]  rs1, rs2, rd,
  input  logic [31:0] wd,
  output logic [31:0] rd1, rd2,
  // observability for tests
  output logic [31:0] x1_val,
  output logic [31:0] x2_val,
  output logic [31:0] x3_val
);
  logic [31:0] rf[31:0];

  assign rd1    = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
  assign rd2    = (rs2 == 5'd0) ? 32'd0 : rf[rs2];
  assign x1_val = rf[5'd1];
  assign x2_val = rf[5'd2];
  assign x3_val = rf[5'd3];

  always_ff @(posedge clk) begin
    if (we && (rd != 5'd0)) rf[rd] <= wd;
  end
endmodule
