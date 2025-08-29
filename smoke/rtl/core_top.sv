module core_top(input clk, input rst_n,
                input  [31:0] a,
                output reg [31:0] y);
  always @(posedge clk or negedge rst_n)
    if (!rst_n) y <= 32'h0;
    else        y <= a + 32'h1;
endmodule
