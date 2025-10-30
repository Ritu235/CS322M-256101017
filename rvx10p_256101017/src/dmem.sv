//===========================================================
// dmem.sv – Data Memory Module
// Used in MEM stage of RVX10-P pipeline
// Supports LW (load word) and SW (store word)
//===========================================================

module dmem (
    input  logic         clk,         // Clock
    input  logic         memRead,     // Control signal: read from memory
    input  logic         memWrite,    // Control signal: write to memory
    input  logic [31:0]  addr,        // Memory address
    input  logic [31:0]  writeData,   // Data to be written
    output logic [31:0]  readData     // Data read from memory
);

    // Define 1024 x 32-bit memory (4 KB)
    logic [31:0] memory [0:1023];

    // Memory Read (combinational)
    always_comb begin
        if (memRead)
            readData = memory[addr[11:2]];   // Word-aligned address
        else
            readData = 32'd0;
    end

    // Memory Write (synchronous)
    always_ff @(posedge clk) begin
        if (memWrite)
            memory[addr[11:2]] <= writeData; // Store data
    end

endmodule
