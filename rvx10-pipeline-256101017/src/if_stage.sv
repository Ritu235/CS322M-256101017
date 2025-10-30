//=====================================================
// File: if_stage.sv
// Description: Instruction Fetch Stage for RVX10-P
// Handles PC update and instruction fetch
// Author: Ritu
//=====================================================

module if_stage (
    input  logic        clk,           // Clock
    input  logic        reset,         // Reset signal
    input  logic        pc_src,        // Control: 1 = branch taken
    input  logic [31:0] pc_sel,        // New PC when branch taken
    input  logic        stall,         // Stall signal from hazard unit
    output logic [31:0] pc_plus4,      // PC + 4 output
    output logic [31:0] pc_out,        // Current PC value
    output logic [31:0] instr          // Fetched instruction
);

    // Internal program counter register
    logic [31:0] pc_next;
    logic [31:0] pc_reg;

    // Simple instruction memory (1K words = 4KB)
    logic [31:0] imem [0:1023];

    // Load program into instruction memory
    initial begin
        $readmemh("tests/rvx10_pipeline.hex", imem); // Load hex file
    end

    // Program Counter logic
    always_comb begin
        if (pc_src)
            pc_next = pc_sel;            // Branch target if taken
        else
            pc_next = pc_reg + 4;        // Otherwise sequential
    end

    // PC update (synchronous)
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 32'd0;             // Start from address 0
        else if (!stall)
            pc_reg <= pc_next;           // Update only if no stall
    end

    // Instruction Fetch
    assign instr    = imem[pc_reg[11:2]]; // Word-aligned instruction
    assign pc_out   = pc_reg;             // Current PC
    assign pc_plus4 = pc_reg + 4;         // Next PC (for pipeline use)

endmodule
