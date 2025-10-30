//===========================================================
// dmem.sv – Data Memory Module
// Used in MEM stage of RVX10-P pipeline
// Supports LW (load word) and SW (store word)
//===========================================================

module dmem(
  input  logic       clk, we,
  input  logic [31:0] a, wd,
  output logic [31:0] rd
);
    
  // Memory array (64 entries, 32-bits wide)
  logic [31:0] RAM [63:0];
    
  // Combinational read (word-aligned)
  assign rd = RAM[a[31:2]]; 
    
  // Synchronous write (on positive clock edge)
  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
    
endmodule
