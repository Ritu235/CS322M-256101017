module wb_stage(
    input  logic [31:0] alu_result,
    input  logic [31:0] mem_data,
    input  logic mem_to_reg,
    output logic [31:0] wb_data
);

  mux2 #(32) wb_mux(
    .d0(alu_result),
    .d1(mem_data),
    .s(mem_to_reg),
    .y(wb_data)
  );

endmodule
