module mem_stage(
    input  logic clk,
    input  logic memread,
    input  logic memwrite,
    input  logic [31:0] alu_result,
    input  logic [31:0] rd2,
    output logic [31:0] mem_data_out
);

  dmem dmem_inst(
    .clk(clk),
    .MemRead(memread),
    .MemWrite(memwrite),
    .addr(alu_result),
    .wd(rd2),
    .rd(mem_data_out)
  );

endmodule
