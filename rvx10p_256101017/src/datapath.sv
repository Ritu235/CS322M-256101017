module datapath(
    input  logic clk,
    input  logic reset,
    // Control signals (from controller)
    input  logic alusrc_d,
    input  logic memtoreg_d,
    input  logic regwrite_d,
    input  logic memread_d,
    input  logic memwrite_d,
    input  logic branch_d,
    input  logic [3:0] alucontrol_d,
    // Outputs for testing
    output logic [31:0] pc_out,
    output logic [31:0] alu_result_w,
    output logic [31:0] write_data_w
);

  // =========================
  // IF Stage
  // =========================
  logic [31:0] instr_f, pc_f, pcplus4_f;

  // For now, no branch or hazard logic
  logic pc_sel_f = 0;
  logic [31:0] pc_src_f = 0;

if_stage if_stage_inst (
    .clk(clk),
    .reset(reset),
    .pcSrc(pc_sel_f),          // ✅ 1-bit control signal
    .branchTarget(pc_src_f),   // ✅ 32-bit branch target address
    .stall(1'b0),              // (optional if you have stall input)
    .pc(pc_f),
    .instr(instr_f)
);


  // =========================
  // IF/ID Pipeline Register
  // =========================
  logic [31:0] instr_d, pc_d;

  always_ff @(posedge clk or posedge reset)
    if (reset) begin
      instr_d <= 32'b0;
      pc_d    <= 32'b0;
    end else begin
      instr_d <= instr_f;
      pc_d    <= pc_f;
    end

  // =========================
  // ID Stage
  // =========================
  logic [31:0] rd1_d, rd2_d, imm_d;
  logic [4:0] rs1_d, rs2_d, rd_d;

  id_stage id_stage_inst (
      .clk(clk),
      .reset(reset),
      .instr(instr_d),
      .wd_wb(write_data_w),
      .rd_wb(rd_d),
      .regwrite_wb(regwrite_d),   // placeholder until WB connected
      .rd1(rd1_d),
      .rd2(rd2_d),
      .imm_ext(imm_d),
      .rs1(rs1_d),
      .rs2(rs2_d),
      .rd(rd_d)
  );

  // =========================
  // ID/EX Pipeline Register
  // =========================
  logic [31:0] rd1_e, rd2_e, imm_e, pc_e;
  logic [4:0] rs1_e, rs2_e, rd_e;
  logic alusrc_e, memtoreg_e, regwrite_e, memread_e, memwrite_e, branch_e;
  logic [3:0] alucontrol_e;

  always_ff @(posedge clk or posedge reset)
    if (reset) begin
      rd1_e <= 0; rd2_e <= 0; imm_e <= 0; pc_e <= 0;
      rs1_e <= 0; rs2_e <= 0; rd_e <= 0;
      alusrc_e <= 0; memtoreg_e <= 0; regwrite_e <= 0;
      memread_e <= 0; memwrite_e <= 0; branch_e <= 0; alucontrol_e <= 0;
    end else begin
      rd1_e <= rd1_d; rd2_e <= rd2_d; imm_e <= imm_d; pc_e <= pc_d;
      rs1_e <= rs1_d; rs2_e <= rs2_d; rd_e <= rd_d;
      alusrc_e <= alusrc_d; memtoreg_e <= memtoreg_d; regwrite_e <= regwrite_d;
      memread_e <= memread_d; memwrite_e <= memwrite_d; branch_e <= branch_d;
      alucontrol_e <= alucontrol_d;
    end

  // =========================
  // EX Stage
  // =========================
  logic [31:0] alu_result_e, branch_target_e;
  logic zero_e;

  ex_stage ex_stage_inst (
      .rd1(rd1_e),
      .rd2(rd2_e),
      .imm_ext(imm_e),
      .pc_in(pc_e),
      .alu_control(alucontrol_e),
      .alusrc(alusrc_e),
      .branch(branch_e),
      .alu_result(alu_result_e),
      .zero(zero_e),
      .branch_target(branch_target_e)
  );

  // =========================
  // EX/MEM Pipeline Register
  // =========================
  logic [31:0] alu_result_m, write_data_m;
  logic [4:0] rd_m;
  logic memtoreg_m, regwrite_m, memread_m, memwrite_m;

  always_ff @(posedge clk or posedge reset)
    if (reset) begin
      alu_result_m <= 0; write_data_m <= 0; rd_m <= 0;
      memtoreg_m <= 0; regwrite_m <= 0; memread_m <= 0; memwrite_m <= 0;
    end else begin
      alu_result_m <= alu_result_e; write_data_m <= rd2_e; rd_m <= rd_e;
      memtoreg_m <= memtoreg_e; regwrite_m <= regwrite_e;
      memread_m <= memread_e; memwrite_m <= memwrite_e;
    end

  // =========================
  // MEM Stage
  // =========================
  logic [31:0] mem_data_m;

  mem_stage mem_stage_inst (
      .clk(clk),
      .memread(memread_m),
      .memwrite(memwrite_m),
      .alu_result(alu_result_m),
      .rd2(write_data_m),
      .mem_data_out(mem_data_m)
  );

  // =========================
  // MEM/WB Pipeline Register
  // =========================
  logic [31:0] alu_result_wb, mem_data_wb;
  logic [4:0] rd_wb;
  logic memtoreg_wb, regwrite_wb;

  always_ff @(posedge clk or posedge reset)
    if (reset) begin
      alu_result_wb <= 0; mem_data_wb <= 0; rd_wb <= 0;
      memtoreg_wb <= 0; regwrite_wb <= 0;
    end else begin
      alu_result_wb <= alu_result_m; mem_data_wb <= mem_data_m; rd_wb <= rd_m;
      memtoreg_wb <= memtoreg_m; regwrite_wb <= regwrite_m;
    end

  // =========================
  // WB Stage
  // =========================
  logic [31:0] write_data_final;

  wb_stage wb_stage_inst (
      .alu_result(alu_result_wb),
      .mem_data(mem_data_wb),
      .mem_to_reg(memtoreg_wb),
      .wb_data(write_data_final)
  );

  assign write_data_w = write_data_final;
  assign alu_result_w = alu_result_wb;
  assign pc_out = pc_f;

endmodule
