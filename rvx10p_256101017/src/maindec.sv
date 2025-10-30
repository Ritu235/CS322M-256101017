// src/maindec.sv
// Main decoder that produces the packed 11-bit control bus used in riscvpipeline.sv
// Instantiation expected: maindec maindec_i(.op(opcode_D), .controls(ctrlbus_D));
//
// Packing used in top-level:
// assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;
// That implies controls is 11 bits: [10]RegWrite, [9:8]ImmSrc(2), [7]ALUSrc, [6]MemWrite, [5:4]ResultSrc(2), [3]Branch, [2:1]ALUOp(2), [0]Jump
// BUT earlier code used: controls = 11'bRegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
// We'll match the exact pattern used earlier in the conversation:
// controls bits layout (left to right, MSB..LSB): RegWrite (1), ImmSrc (2), ALUSrc (1), MemWrite (1), ResultSrc (2), Branch (1), ALUOp (2), Jump (1) = 11 bits.

module maindec(
  input  logic [6:0] op,
  output logic [1:0] ResultSrc,
  output logic       MemWrite,
  output logic       Branch, ALUSrc,
  output logic       RegWrite, Jump,
  output logic [1:0] ImmSrc,
  output logic [1:0] ALUOp
);

  // Internal wire to hold all control signals
  logic [10:0] controls;

  // Assign bits from the 'controls' wire to the respective output ports
  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  // Combinational logic to decode the opcode
  always_comb
    case(op)
    //         RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type 
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_xx_0_0_00_0_11_0; // R-type_newly_added_instructions (RVX10)
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // non-implemented instruction
    endcase
endmodule

