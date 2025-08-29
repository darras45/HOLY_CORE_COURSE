module data_mem #(
  parameter int DEPTH_WORDS = 256
)(
  input  logic        clk,
  input  logic        we,           // write enable (store)
  input  logic [31:0] addr,         // byte address
  input  logic [31:0] wdata,        // store data
  output logic [31:0] rdata         // load data
);
  localparam int ADDR_W = $clog2(DEPTH_WORDS);

  logic [31:0] mem [0:DEPTH_WORDS-1];

  // async read (single-cycle core convenience)
  wire [ADDR_W-1:0] word_idx = addr[ADDR_W+1:2];
  assign rdata = mem[word_idx];

  // sync write on posedge
  always_ff @(posedge clk) begin
    if (we) mem[word_idx] <= wdata;
  end
endmodule
