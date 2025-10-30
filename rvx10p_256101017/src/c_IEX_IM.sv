module c_IEx_IM (
  input  logic       clk, reset,
  input  logic       RegWriteE, MemWriteE,
  input  logic [1:0] ResultSrcE,  
  output logic       RegWriteM, MemWriteM,
  output logic [1:0] ResultSrcM
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous reset
      RegWriteM  <= 0;
      MemWriteM  <= 0;
      ResultSrcM <= 0;
    end
    else begin // Normal operation: latch inputs
      RegWriteM  <= RegWriteE;
      MemWriteM  <= MemWriteE;
      ResultSrcM <= ResultSrcE; 
    end
  end

endmodule
