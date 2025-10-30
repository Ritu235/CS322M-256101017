module c_ID_IEx (
  input  logic       clk, reset, clear,
  input  logic       RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
  input  logic [1:0] ResultSrcD, 
  input  logic [3:0] ALUControlD,  
  output logic       RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
  output logic [1:0] ResultSrcE,
  output logic [3:0] ALUControlE
);

  always_ff @( posedge clk, posedge reset ) begin
    if (reset) begin // Asynchronous reset
      RegWriteE   <= 0;
      MemWriteE   <= 0;
      JumpE       <= 0;
      BranchE     <= 0; 
      ALUSrcE     <= 0;
      ResultSrcE  <= 0;
      ALUControlE <= 0;
    end
    else if (clear) begin // Synchronous clear (flushes to 0)
      RegWriteE   <= 0;
      MemWriteE   <= 0;
      JumpE       <= 0;
      BranchE     <= 0; 
      ALUSrcE     <= 0;
      ResultSrcE  <= 0;
      ALUControlE <= 0;
    end
    else begin // Normal operation: latch inputs
      RegWriteE   <= RegWriteD;
      MemWriteE   <= MemWriteD;
      JumpE       <= JumpD;
      BranchE     <= BranchD; 
      ALUSrcE     <= ALUSrcD;
      ResultSrcE  <= ResultSrcD;
      ALUControlE <= ALUControlD; 
    end
  end
  
endmodule
