//===========================================================
// adder.sv – 32-bit Adder Module
// Used for PC increment, branch calculation, etc.
//===========================================================

module adder(
  input  [31:0] a, b, // 32-bit inputs
  output [31:0] y     // 32-bit output (a + b)
);

  assign y = a + b;
endmodule

