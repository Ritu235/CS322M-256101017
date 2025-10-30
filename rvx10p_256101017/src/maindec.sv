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

module maindec (
  input  logic [6:0] op,
  output logic [10:0] controls
);

  // Default: unknown instruction -> all x's would be less helpful in sim; use zeros
  always_comb begin
    unique case (op)
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw : RegWrite=1, ImmSrc=00(I), ALUSrc=1, MemWrite=0, ResultSrc=01(MEM), Branch=0, ALUOp=00(add), Jump=0
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw : RegWrite=0, ImmSrc=01(S), ALUSrc=1, MemWrite=1, ResultSrc=00, Branch=0, ALUOp=00
      7'b0110011: controls = 11'b1_00_0_0_00_0_10_0; // R-type : RegWrite=1, ALUSrc=0, ALUOp=10
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq : RegWrite=0, ImmSrc=10(B), Branch=1, ALUOp=01
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU (addi): RegWrite=1, ALUSrc=1, ALUOp=10 (treat as R-type for decode)
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal : RegWrite=1, ImmSrc=11(J), ResultSrc=10(PC+4), Jump=1
      // CUSTOM-0 opcode (RVX10) - treat like R-type, ALUOp=10 to route to ALU-decoder
      7'b0001011: controls = 11'b1_00_0_0_00_0_10_0; // CUSTOM-0 treated as R-type (RegWrite=1, ALUOp=10)
      default:    controls = 11'b0_00_0_0_00_0_00_0; // default: no-op
    endcase
  end

endmodule
