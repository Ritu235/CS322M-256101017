//=====================================================
// File: rf.sv
// Description: 32x32 Register File for RVX10-P
// Two read ports, one write port
// x0 is always hardwired to 0
// Author: Ritu
//=====================================================

module rf(
  input  logic       clk,
  input  logic       we3,      // Write enable (from WB stage)
  input  logic [4:0] a1, a2, a3, // a1,a2=Read addrs, a3=Write addr
  input  logic [31:0] wd3,    // Write data
  output logic [31:0] rd1, rd2 // Read data
);

  // The register file storage array
  logic [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally (A1/RD1, A2/RD2)
  // write third port on *NEGATIVE* edge of clock (A3/WD3/WE3)
  // register 0 hardwired to 0

  // **MODIFICATION**: Writing on negedge clk as requested
  always_ff @(negedge clk)
    if (we3 & a3 != 0) rf[a3] <= wd3; // x0 no rewrites

  // Combinational reads
  // This simple logic works *because* write is on negedge
  // and read (in ID stage) is sampled on posedge.
  assign rd1 = (a1 != 0) ? rf[a1] : 0; // Hardwire x0 to 0
  assign rd2 = (a2 != 0) ? rf[a2] : 0; // Hardwire x0 to 0
  
endmodule
