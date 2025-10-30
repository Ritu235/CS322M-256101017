//=====================================================
// File: alu.sv
// Description: Arithmetic Logic Unit for RVX10-P
// Supports RV32I + 10 Custom Instructions (RVX10)
// Author: Ritu
//=====================================================

module alu(
    input  logic [31:0] a, b,          // ALU inputs
    input  logic [4:0]  aluControl,    // ALU control (5 bits for more ops)
    output logic [31:0] result,        // ALU output
    output logic        zero           // Zero flag for branches
);

    always_comb begin
        case (aluControl)
            // ------------------- RV32I -------------------
            5'b00000: result = a + b;                              // ADD
            5'b00001: result = a - b;                              // SUB
            5'b00010: result = a & b;                              // AND
            5'b00011: result = a | b;                              // OR
            5'b00100: result = a ^ b;                              // XOR
            5'b00101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            5'b00110: result = a << b[4:0];                        // SLL
            5'b00111: result = a >> b[4:0];                        // SRL
            5'b01000: result = $signed(a) >>> b[4:0];              // SRA

            // ------------------- RVX10 Custom -------------------
            5'b01001: result = a & ~b;                             // ANDN
            5'b01010: result = a | ~b;                             // ORN
            5'b01011: result = ~(a ^ b);                           // XNOR
            5'b01100: result = ($signed(a) < $signed(b)) ? a : b;  // MIN
            5'b01101: result = ($signed(a) > $signed(b)) ? a : b;  // MAX
            5'b01110: result = (a < b) ? a : b;                    // MINU
            5'b01111: result = (a > b) ? a : b;                    // MAXU
            5'b10000: result = (a << b[4:0]) | (a >> (32 - b[4:0])); // ROL
            5'b10001: result = (a >> b[4:0]) | (a << (32 - b[4:0])); // ROR
            5'b10010: result = ($signed(a) < 0) ? -$signed(a) : a;   // ABS

            default: result = 32'd0;                                // NOP / Undefined
        endcase
    end

    assign zero = (result == 32'd0);

endmodule
