// src/id_ex_reg.sv
// ID/EX pipeline register with stall input (bubble insertion)
// Matches instantiation used in riscvpipeline.sv:
// id_ex_reg idex(.clk(clk), .reset(reset), .stall(/*wired*/0),
//                .pc_in(PC_D), .rd1_in(RD1_D), .rd2_in(RD2_D), .imm_in(Imm_D),
//                .rs1_in(rs1_D), .rs2_in(rs2_D), .rd_in(rd_D), .ctrl_in(ctrl_idex),
//                .pc_out(PC_E), .rd1_out(RD1_E), .rd2_out(RD2_E), .imm_out(Imm_E),
//                .rs1_out(RS1_E), .rs2_out(RS2_E), .rd_out(RD_E), .ctrl_out(CTRL_E));

module id_ex_reg (
  input  logic         clk,
  input  logic         reset,
  input  logic         stall,     // when 1, insert bubble (clear control) and hold values
  input  logic [31:0]  pc_in,
  input  logic [31:0]  rd1_in,
  input  logic [31:0]  rd2_in,
  input  logic [31:0]  imm_in,
  input  logic [4:0]   rs1_in,
  input  logic [4:0]   rs2_in,
  input  logic [4:0]   rd_in,
  input  logic [12:0]  ctrl_in,   // packed control bus (13 bits) as used in top-level
  output logic [31:0]  pc_out,
  output logic [31:0]  rd1_out,
  output logic [31:0]  rd2_out,
  output logic [31:0]  imm_out,
  output logic [4:0]   rs1_out,
  output logic [4:0]   rs2_out,
  output logic [4:0]   rd_out,
  output logic [12:0]  ctrl_out
);

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      pc_out   <= 32'd0;
      rd1_out  <= 32'd0;
      rd2_out  <= 32'd0;
      imm_out  <= 32'd0;
      rs1_out  <= 5'd0;
      rs2_out  <= 5'd0;
      rd_out   <= 5'd0;
      ctrl_out <= 13'd0;
    end else begin
      if (stall) begin
        // Insert bubble: clear control bits, hold other pipeline state if desired.
        // Many designs zero control signals and keep data (or clear data). We'll zero controls here.
        ctrl_out <= 13'd0;
        // Keep data values as-is (hold) so next stage doesn't advance prematurely.
        pc_out <= pc_out;
        rd1_out <= rd1_out;
        rd2_out <= rd2_out;
        imm_out <= imm_out;
        rs1_out <= rs1_out;
        rs2_out <= rs2_out;
        rd_out  <= rd_out;
      end else begin
        // Normal pipeline advance
        pc_out   <= pc_in;
        rd1_out  <= rd1_in;
        rd2_out  <= rd2_in;
        imm_out  <= imm_in;
        rs1_out  <= rs1_in;
        rs2_out  <= rs2_in;
        rd_out   <= rd_in;
        ctrl_out <= ctrl_in;
      end
    end
  end

endmodule
