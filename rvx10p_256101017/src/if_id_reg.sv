//=====================================================
// File: if_id_reg.sv
// Description: IF/ID Pipeline Register for RVX10-P
// Holds PC and instruction between IF and ID stages
// Supports stall and flush signals
// Author: Ritu
//=====================================================

module if_id_reg (
    input  logic        clk,           // Clock
    input  logic        reset,         // Reset signal
    input  logic        stall,         // Stall signal (from hazard unit)
    input  logic        flush,         // Flush signal (on branch taken)
    input  logic [31:0] pc_in,         // PC from IF stage
    input  logic [31:0] instr_in,      // Instruction from IF stage
    output logic [31:0] pc_out,        // PC to ID stage
    output logic [31:0] instr_out      // Instruction to ID stage
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out    <= 32'd0;
            instr_out <= 32'd0;          // On reset, set to NOP
        end
        else if (flush) begin
            pc_out    <= 32'd0;
            instr_out <= 32'd0;          // Flush = insert NOP
        end
        else if (!stall) begin
            pc_out    <= pc_in;          // Normal pipeline flow
            instr_out <= instr_in;
        end
        // If stall = 1 → hold current values
    end

endmodule
