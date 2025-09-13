module data_mem #(
  parameter int DEPTH_WORDS = 256
)(
  input  logic        clk,
  input  logic        we,          // write enable
  input  logic [31:0] addr,        // byte address
  input  logic [31:0] wdata,       // write data
  output logic [31:0] rdata        // read data
);

  localparam int ADDR_W = $clog2(DEPTH_WORDS);

  logic [31:0] mem [0:DEPTH_WORDS-1];

  // Initialize memory to zeros so loads don't read garbage
  initial begin : init
    integer i;
    for (i = 0; i < DEPTH_WORDS; i++) mem[i] = 32'b0;
  end

  wire [ADDR_W-1:0] word_idx = addr[ADDR_W+1:2];

  always_ff @(posedge clk) begin
    if (we) begin
      mem[word_idx] <= wdata;
    end
  end

  assign rdata = mem[word_idx];

endmodule
