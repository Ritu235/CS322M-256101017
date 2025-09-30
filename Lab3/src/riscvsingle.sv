// riscvsingle.sv - full SystemVerilog implementation with RVX10 custom instructions
// Supports 10 custom single-cycle ALU ops: ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS
// Assumes instruction memory file "riscvtest.txt" is in the simulator working directory.

module testbench();

  logic        clk;
  logic        reset;

  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // instantiate device to be tested
  top dut(clk, reset, WriteData, DataAdr, MemWrite);
  
  // initialize test
  initial begin
    reset <= 1; #22; reset <= 0;
  end

  // generate clock to sequence tests
  always begin
    clk <= 1; #5; clk <= 0; #5;
  end

  // check results
  always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 100 & WriteData === 25) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed");
        $stop;
      end
    end
  end
endmodule

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  
  // instantiate processor and memories
  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(input  logic        clk, reset,
                   output logic [31:0] PC,
                   input  logic [31:0] Instr,
                   output logic        MemWrite,
                   output logic [31:0] ALUResult, WriteData,
                   input  logic [31:0] ReadData);

  logic       ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc;
  // widen ALUControl to 5 bits to support RVX10 opcodes
  logic [4:0] ALUControl;
  logic       PCSrc; // <- declare PCSrc here

  controller c(Instr[6:0], Instr[14:12], Instr[30], Zero,
               ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump,
               ImmSrc, ALUControl);
  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite,
              ImmSrc, ALUControl,
              Zero, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule

module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [4:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  // aludec maps standard opcodes to 5-bit ALUControl (custom decoding handled in datapath)
  aludec  ad(op, funct3, funct7b5, ALUOp, ALUControl);

  assign PCSrc = Branch & Zero | Jump;
endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
      // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type 
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      // CUSTOM-0 (RVX10) treat as R-type controlling ALU; actual funct7/funct3 decode done in datapath
      7'b0001011: controls = 11'b1_xx_0_0_00_0_10_0; // CUSTOM-0 = R-type-like
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // non-implemented instruction
    endcase
endmodule

module aludec(input  logic [6:0] op,
              input  logic [2:0] funct3,
              input  logic       funct7b5, 
              input  logic [1:0] ALUOp,
              output logic [4:0] ALUControl);

  // For standard instructions: map into low 5-bit encodings
  // We will not attempt to decode full CUSTOM-0 here (datapath handles it).
  logic RtypeSub;
  assign RtypeSub = funct7b5 & op[5];

  always_comb begin
    if (op == 7'b0001011) begin
      // CUSTOM-0 - datapath will override ALUControl (return default)
      ALUControl = 5'd0;
    end else begin
      case(ALUOp)
        2'b00: ALUControl = 5'd0; // add
        2'b01: ALUControl = 5'd1; // subtract
        default: case(funct3) // R-type or I-type ALU
                   3'b000: if (RtypeSub) ALUControl = 5'd1; else ALUControl = 5'd0; // sub/add
                   3'b010: ALUControl = 5'd5; // slt
                   3'b110: ALUControl = 5'd3; // or
                   3'b111: ALUControl = 5'd2; // and
                   default: ALUControl = 5'd0;
                 endcase
      endcase
    end
  end
endmodule

module datapath(input  logic        clk, reset,
                input  logic [1:0]  ResultSrc, 
                input  logic        PCSrc, ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [4:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

  // next PC logic
  flopr #(32) pcreg(clk, reset, PCNext, PC); 
  adder       pcadd4(PC, 32'd4, PCPlus4);
  adder       pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
 
  // register file logic
  regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  // ALU logic
  mux2 #(32)  srcbmux(WriteData, ImmExt, ALUSrc, SrcB);

  // CUSTOM-0 detection and mapping to ALUControl (create extended control)
  logic [4:0] alu_ctrl_ext;

  always_comb begin
    // default: pass-through ALUControl from controller (standard ops)
    alu_ctrl_ext = ALUControl;

    // If opcode is CUSTOM-0 (RVX10), decode {funct7, funct3} to new alu_ctrl codes
    if (Instr[6:0] == 7'b0001011) begin
      unique case ({Instr[31:25], Instr[14:12]})
        {7'b0000000, 3'b000}: alu_ctrl_ext = 5'd16; // ANDN
        {7'b0000000, 3'b001}: alu_ctrl_ext = 5'd17; // ORN
        {7'b0000000, 3'b010}: alu_ctrl_ext = 5'd18; // XNOR

        {7'b0000001, 3'b000}: alu_ctrl_ext = 5'd19; // MIN (signed)
        {7'b0000001, 3'b001}: alu_ctrl_ext = 5'd20; // MAX (signed)
        {7'b0000001, 3'b010}: alu_ctrl_ext = 5'd21; // MINU (unsigned)
        {7'b0000001, 3'b011}: alu_ctrl_ext = 5'd22; // MAXU (unsigned)

        {7'b0000010, 3'b000}: alu_ctrl_ext = 5'd23; // ROL
        {7'b0000010, 3'b001}: alu_ctrl_ext = 5'd24; // ROR

        {7'b0000011, 3'b000}: alu_ctrl_ext = 5'd25; // ABS (rs2 = x0)

        default: alu_ctrl_ext = 5'd0; // defensively default to add (or safe op)
      endcase
    end
  end

  alu alu_inst(SrcA, SrcB, alu_ctrl_ext, ALUResult, Zero);
  mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule

module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [ 4:0] a1, a2, a3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  // three ported register file (read combinational, write on rising clock)
  always_ff @(posedge clk)
    if (we3 && a3 != 0) rf[a3] <= wd3; // protect x0

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);
  assign y = a + b;
endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
 
  always_comb
    case(immsrc) 
      2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  // I-type 
      2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
      2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
      2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
      default: immext = 32'bx; // undefined
    endcase             
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  // use mem[0:63] to avoid $readmemh ambiguity warning
  logic [31:0] RAM[0:63];

  initial
      $readmemh("riscvtest.txt", RAM);

  assign rd = RAM[a[31:2]]; // word aligned
endmodule

module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[0:63];

  assign rd = RAM[a[31:2]]; // word aligned

  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule

module alu(input  logic [31:0] a, b,
           input  logic [4:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  // local wires for operations
  logic [31:0] sum;
  logic signed [31:0] sa, sb;

  // add/sub helper: if alucontrol[0]==1 it's subtract (use two's complement of b)
  assign sum = a + (alucontrol[0] ? ~b : b) + alucontrol[0];

  always_comb begin
    case (alucontrol)
      // standard operations encoded in low values
      5'd0:  result = sum;         // add
      5'd1:  result = sum;         // subtract
      5'd2:  result = a & b;       // and
      5'd3:  result = a | b;       // or
      5'd4:  result = a ^ b;       // xor
      5'd5:  begin // slt (signed less-than) -> return 1 or 0
               sa = $signed(a);
               sb = $signed(b);
               result = (sa < sb) ? 32'd1 : 32'd0;
             end
      5'd6:  result = a << b[4:0]; // sll
      5'd7:  result = a >> b[4:0]; // srl

      // RVX10 custom operations (16..25)
      5'd16: result = a & ~b;                  // ANDN
      5'd17: result = a | ~b;                  // ORN
      5'd18: result = ~(a ^ b);                // XNOR

      5'd19: begin // MIN (signed)
               sa = $signed(a);
               sb = $signed(b);
               result = (sa < sb) ? a : b;
             end
      5'd20: begin // MAX (signed)
               sa = $signed(a);
               sb = $signed(b);
               result = (sa > sb) ? a : b;
             end
      5'd21: result = (a < b) ? a : b;         // MINU (unsigned)
      5'd22: result = (a > b) ? a : b;         // MAXU (unsigned)

      5'd23: begin // ROL - rotate left by b[4:0]
               logic [4:0] sh = b[4:0];
               result = (sh == 0) ? a : ((a << sh) | (a >> (32-sh)));
             end
      5'd24: begin // ROR - rotate right by b[4:0]
               logic [4:0] sh = b[4:0];
               result = (sh == 0) ? a : ((a >> sh) | (a << (32-sh)));
             end
      5'd25: begin // ABS - absolute value of signed a
               sa = $signed(a);
               result = (sa >= 0) ? a : (~a) + 1; // two's complement negation; wraps on INT_MIN
             end

      default: result = 32'bx;
    endcase
  end

  assign zero = (result == 32'b0);
endmodule
