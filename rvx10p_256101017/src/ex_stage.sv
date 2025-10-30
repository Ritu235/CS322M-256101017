module ex_stage(
    input  logic [31:0] rd1, rd2, imm_ext,
    input  logic [31:0] pc_in,
    input  logic [3:0] alu_control,
    input  logic alusrc, branch,
    output logic [31:0] alu_result,
    output logic zero,
    output logic [31:0] branch_target
);

  logic [31:0] src_b;

  mux2 #(32) alu_src_mux(.d0(rd2), .d1(imm_ext), .s(alusrc), .y(src_b));
  alu alu_inst(.a(rd1), .b(src_b), .alu_ctrl(alu_control), .y(alu_result), .zero(zero));

  adder branch_adder(.a(pc_in), .b(imm_ext), .y(branch_target));

endmodule
