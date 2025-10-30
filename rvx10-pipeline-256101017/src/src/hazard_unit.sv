//===========================================================
// hazard_unit.sv – Hazard Detection Unit for RVX10-P
// Handles load-use stalls and control hazard flushes
//===========================================================

module hazard_unit (
    input  logic [4:0] rs1D, rs2D,      // Source registers in Decode stage
    input  logic [4:0] rs1E, rs2E,      // Source registers in Execute stage
    input  logic [4:0] rdE, rdM,        // Destination registers in Execute and MEM stages
    input  logic       memToRegE,       // 1 if instruction in EX is a load (LW)
    input  logic       branchTakenE,    // 1 if branch or jump is taken
    output logic       stallF,          // Stall Fetch stage
    output logic       stallD,          // Stall Decode stage
    output logic       flushE,          // Flush Execute stage
    output logic       flushD           // Flush Decode stage (for branches)
);

    // Default signals
    always_comb begin
        stallF = 0;
        stallD = 0;
        flushE = 0;
        flushD = 0;

        //==========================
        // Load-Use Data Hazard
        //==========================
        if (memToRegE && ((rdE == rs1D) || (rdE == rs2D))) begin
            stallF = 1;     // Freeze PC
            stallD = 1;     // Freeze IF/ID
            flushE = 1;     // Insert bubble into ID/EX
        end

        //==========================
        // Control Hazard (Branch/Jump)
        //==========================
        if (branchTakenE) begin
            flushD = 1;     // Flush IF/ID
            flushE = 1;     // Flush ID/EX
        end
    end

endmodule
