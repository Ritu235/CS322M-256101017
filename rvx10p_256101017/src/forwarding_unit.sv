//===========================================================
// forwarding_unit.sv – Forwarding Unit for RVX10-P
// Handles data hazards by forwarding values from MEM/WB or EX/MEM
//===========================================================

module forwarding_unit (
    input  logic [4:0] rs1E, rs2E,       // Source registers in EX stage
    input  logic [4:0] rdM, rdW,          // Destination registers in MEM and WB stages
    input  logic       regWriteM,         // RegWrite signal from MEM stage
    input  logic       regWriteW,         // RegWrite signal from WB stage
    output logic [1:0] forwardAE,         // Forward control for ALU input A
    output logic [1:0] forwardBE          // Forward control for ALU input B
);

    // Default (no forwarding)
    always_comb begin
        forwardAE = 2'b00;
        forwardBE = 2'b00;

        // ---------- Forwarding for Source A ----------
        if (regWriteM && (rdM != 0) && (rdM == rs1E))
            forwardAE = 2'b10;           // From EX/MEM stage
        else if (regWriteW && (rdW != 0) && (rdW == rs1E))
            forwardAE = 2'b01;           // From MEM/WB stage

        // ---------- Forwarding for Source B ----------
        if (regWriteM && (rdM != 0) && (rdM == rs2E))
            forwardBE = 2'b10;           // From EX/MEM stage
        else if (regWriteW && (rdW != 0) && (rdW == rs2E))
            forwardBE = 2'b01;           // From MEM/WB stage
    end

endmodule
