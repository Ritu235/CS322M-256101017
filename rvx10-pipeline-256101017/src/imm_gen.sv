//===========================================================
// File: imm_gen.sv
// Description: Immediate Generator for RVX10-P
// Extracts and sign-extends immediate values based on opcode
//===========================================================

module imm_gen(
    input  logic [31:0] instr,   // 32-bit instruction
    output logic [31:0] immOut   // 32-bit sign-extended immediate
);

    logic [6:0] opcode;

    assign opcode = instr[6:0];

    always_comb begin
        unique case (opcode)
            //====================
            // I-type: LW, ADDI, ANDI, ORI, XORI, JALR, etc.
            // imm[11:0] = instr[31:20]
            //====================
            7'b0000011,   // LW
            7'b0010011,   // ADDI/ANDI/ORI/XORI
            7'b1100111:   // JALR
                immOut = {{20{instr[31]}}, instr[31:20]};

            //====================
            // S-type: SW
            // imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            //====================
            7'b0100011:
                immOut = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            //====================
            // B-type: BEQ, BNE, BLT, BGE, etc.
            // imm[12|10:5|4:1|11|0] = instr bits rearranged
            //====================
            7'b1100011:
                immOut = {{19{instr[31]}}, instr[31], instr[7],
                          instr[30:25], instr[11:8], 1'b0};

            //====================
            // U-type: LUI, AUIPC
            // imm[31:12] = instr[31:12], imm[11:0] = 0
            //====================
            7'b0110111,  // LUI
            7'b0010111:  // AUIPC
                immOut = {instr[31:12], 12'b0};

            //====================
            // J-type: JAL
            // imm[20|10:1|11|19:12|0] = instr bits rearranged
            //====================
            7'b1101111:
                immOut = {{11{instr[31]}}, instr[31], instr[19:12],
                          instr[20], instr[30:21], 1'b0};

            //====================
            // RVX10 custom immediate (example opcode 7'b1011011)
            // Extend or modify this section if your custom instructions
            // use their own immediate formats.
            //====================
            7'b1011011: // RVX10 custom-type immediate (example)
                immOut = {{27{instr[31]}}, instr[24:20]}; // 5-bit imm sign-extended

            //====================
            // Default
            //====================
            default:
                immOut = 32'd0;
        endcase
    end

endmodule
