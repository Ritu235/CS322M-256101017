//===========================================================
// adder.sv – 32-bit Adder Module
// Used for PC increment, branch calculation, etc.
//===========================================================

module adder(
    input  logic [31:0] a,      // First operand
    input  logic [31:0] b,      // Second operand
    output logic [31:0] sum     // Output sum
);

    // Simple combinational addition
    assign sum = a + b;

endmodule
