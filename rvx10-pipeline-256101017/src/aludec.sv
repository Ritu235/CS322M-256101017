// src/aludec.sv
// ALU decoder: converts ALUOp + funct3/funct7 into 5-bit ALU control for RVX10

module aludec(
  input  logic [6:0] op,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  input  logic [1:0] ALUOp,
  output logic [4:0] ALUControl
);
  always_comb begin
    ALUControl = 5'b00000;
    case (ALUOp)
      2'b00: ALUControl = 5'b00000;          // add
      2'b01: ALUControl = 5'b00001;          // sub (branch)
      2'b10: begin                           // R-type or custom
        case ({funct7,funct3})
          10'b0000000_000: ALUControl = 5'b00000; // ADD
          10'b0100000_000: ALUControl = 5'b00001; // SUB
          10'b0000000_111: ALUControl = 5'b00010; // AND
          10'b0000000_110: ALUControl = 5'b00011; // OR
          10'b0000000_100: ALUControl = 5'b00100; // XOR
          10'b0000000_010: ALUControl = 5'b00101; // SLT
          // --- custom RVX10 opcodes ---
          10'b0000001_000: ALUControl = 5'b10000; // CUSTOM1
          10'b0000001_001: ALUControl = 5'b10001; // CUSTOM2
          default:          ALUControl = 5'b00000;
        endcase
      end
      default: ALUControl = 5'b00000;
    endcase
  end
endmodule
