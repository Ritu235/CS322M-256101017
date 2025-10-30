// File: src/mux2.sv
// 2-to-1 Multiplexer

module mux2 #(
    parameter WIDTH = 32    // Parameterized width (default 32-bit)
)(
    input  logic [WIDTH-1:0] d0,  // Input 0
    input  logic [WIDTH-1:0] d1,  // Input 1
    input  logic             s,   // Select signal
    output logic [WIDTH-1:0] y    // Output
);

    // If s=0, select d0; if s=1, select d1
    assign y = s ? d1 : d0;

endmodule
