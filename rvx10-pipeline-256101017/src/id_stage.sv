//===========================================================
// File: id_stage.sv
// Description: Instruction Decode (ID) stage for RVX10-P
// Extracts register fields, reads from register file, 
// and generates sign-extended immediate.
//===========================================================

module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr,         // Instruction from IF/ID pipeline register
    input  logic [31:0] wd_wb,         // Data to write back (from WB stage)
    input  logic [4:0]  rd_wb,         // Destination register (from WB)
    input  logic        regwrite_wb,   // Write enable (from WB)
    output logic [31:0] rd1, rd2,      // Register read values
    output logic [31:0] imm_ext,       // Sign-extended immediate
    output logic [4:0]  rs1, rs2, rd   // Register numbers
);

    // Extract register fields from instruction
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    //=======================================================
    // Register File
    //=======================================================
    rf rf (
        .clk(clk),
        .regWrite(regwrite_wb),  // ✅ corrected port name
        .readReg1(rs1),
        .readReg2(rs2),
        .writeReg(rd_wb),
        .writeData(wd_wb),
        .readData1(rd1),
        .readData2(rd2)
    );

    //=======================================================
    // Immediate Generator
    //=======================================================
    imm_gen imm_generator (
        .instr(instr),
        .immOut(imm_ext)          // ✅ corrected port name
    );

endmodule
