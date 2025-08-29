module alu(
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [2:0]  op,
  output logic [31:0] y
);
  always_comb begin
    unique case (op)
      3'd0: y = a + b;  // ADD / ADDI
      default: y = 32'hx;
    endcase
  end
endmodule
