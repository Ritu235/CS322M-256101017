//=====================================================
// File: controller.sv
// Description: Control Unit for RVX10-P
// Supports RV32I + 10 custom ALU instructions
// Author: Ritu
//=====================================================

module controller (
    input  logic [6:0] opcode,      // Instruction[6:0]
    input  logic [2:0] funct3,      // Instruction[14:12]
    input  logic [6:0] funct7,      // Instruction[31:25]
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       MemToReg,
    output logic       Branch,
    output logic       ALUSrc,
    output logic [4:0] ALUControl   // 5 bits for extended ALU ops
);

    always_comb begin
        // Default values (NOP)
        RegWrite  = 0;
        MemRead   = 0;
        MemWrite  = 0;
        MemToReg  = 0;
        Branch    = 0;
        ALUSrc    = 0;
        ALUControl = 5'b00000;

        case (opcode)
            // ------------------ R-type (RV32I + RVX10) ------------------
            7'b0110011: begin
                RegWrite = 1;
                ALUSrc   = 0;
                MemToReg = 0;

                case ({funct7, funct3})
                    // Standard RV32I
                    10'b0000000_000: ALUControl = 5'b00000; // ADD
                    10'b0100000_000: ALUControl = 5'b00001; // SUB
                    10'b0000000_111: ALUControl = 5'b00010; // AND
                    10'b0000000_110: ALUControl = 5'b00011; // OR
                    10'b0000000_100: ALUControl = 5'b00100; // XOR
                    10'b0000000_010: ALUControl = 5'b00101; // SLT
                    10'b0000000_001: ALUControl = 5'b00110; // SLL
                    10'b0000000_101: ALUControl = 5'b00111; // SRL
                    10'b0100000_101: ALUControl = 5'b01000; // SRA

                    // RVX10 Custom
                    10'b0000001_000: ALUControl = 5'b01001; // ANDN
                    10'b0000001_001: ALUControl = 5'b01010; // ORN
                    10'b0000001_010: ALUControl = 5'b01011; // XNOR
                    10'b0000001_011: ALUControl = 5'b01100; // MIN
                    10'b0000001_100: ALUControl = 5'b01101; // MAX
                    10'b0000001_101: ALUControl = 5'b01110; // MINU
                    10'b0000001_110: ALUControl = 5'b01111; // MAXU
                    10'b0000001_111: ALUControl = 5'b10000; // ROL
                    10'b0100001_000: ALUControl = 5'b10001; // ROR
                    10'b0100001_001: ALUControl = 5'b10010; // ABS

                    default: ALUControl = 5'b00000; // Default to ADD
                endcase
            end

            // ------------------ I-type (ADDI, ANDI, ORI, etc.) ------------------
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                MemToReg = 0;

                case (funct3)
                    3'b000: ALUControl = 5'b00000; // ADDI
                    3'b111: ALUControl = 5'b00010; // ANDI
                    3'b110: ALUControl = 5'b00011; // ORI
                    3'b100: ALUControl = 5'b00100; // XORI
                    3'b010: ALUControl = 5'b00101; // SLTI
                    default: ALUControl = 5'b00000;
                endcase
            end

            // ------------------ Load ------------------
            7'b0000011: begin
                RegWrite = 1;
                MemRead  = 1;
                MemToReg = 1;
                ALUSrc   = 1;
                ALUControl = 5'b00000; // ADD for address
            end

            // ------------------ Store ------------------
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc   = 1;
                ALUControl = 5'b00000; // ADD for address
            end

            // ------------------ Branch ------------------
            7'b1100011: begin
                Branch    = 1;
                ALUSrc    = 0;
                ALUControl = 5'b00001; // SUB for comparison
            end

            default: begin
                // No operation
            end
        endcase
    end

endmodule
