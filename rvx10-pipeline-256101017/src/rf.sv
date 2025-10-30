//=====================================================
// File: rf.sv
// Description: 32x32 Register File for RVX10-P
// Two read ports, one write port
// x0 is always hardwired to 0
// Author: Ritu
//=====================================================

module rf (
    input  logic        clk,      // Clock
    input  logic        we3,      // Write enable (RegWrite)
    input  logic [4:0]  ra1,      // Read address 1 (rs1)
    input  logic [4:0]  ra2,      // Read address 2 (rs2)
    input  logic [4:0]  wa3,      // Write address (rd)
    input  logic [31:0] wd3,      // Write data
    output logic [31:0] rd1,      // Read data 1
    output logic [31:0] rd2       // Read data 2
);

    // 32 registers of 32 bits each
    logic [31:0] regFile [31:0];

    // Initialize registers to zero (for simulation)
    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1)
            regFile[i] = 32'd0;
    end

    // Combinational read
    assign rd1 = regFile[ra1];
    assign rd2 = regFile[ra2];

    // Sequential write
    always_ff @(posedge clk) begin
        if (we3 && (wa3 != 5'd0))
            regFile[wa3] <= wd3;  // x0 is not writable
        regFile[0] <= 32'd0;      // Ensure x0 remains zero
    end

endmodule
