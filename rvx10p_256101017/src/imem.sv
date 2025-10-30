//===========================================================
// imem.sv – Instruction Memory for RVX10-P
// Read-only memory that stores program instructions
//===========================================================

module imem (
    input  logic [31:0] addr,          // Address (from PC)
    output logic [31:0] instr          // Output instruction
);

    // 1024 x 32-bit instruction memory (4 KB)
    logic [31:0] memory [0:1023];

    // Initialize instruction memory from external file
    initial begin
        $readmemh("tests/rvx10_pipeline.hex", memory);   // Load program into memory
    end

    // Word-aligned instruction fetch
    assign instr = memory[addr[11:2]];

endmodule
