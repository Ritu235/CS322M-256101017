//============================================================
// File: tb/tb_pipeline.sv
// Description: Testbench for RVX10-P Five-Stage Pipelined CPU
//============================================================
`timescale 1ns/1ps

module tb_pipeline;

  // ------------------------------------------
  // Clock and Reset
  // ------------------------------------------
  reg clk;
  reg reset;

  // ------------------------------------------
  // Instantiate the top-level RVX10 pipeline CPU
  // ------------------------------------------
  riscvpipeline uut (
    .clk(clk),
    .reset(reset)
  );

  // ------------------------------------------
  // Clock Generation (10ns period)
  // ------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // ------------------------------------------
  // Reset Sequence
  // ------------------------------------------
  initial begin
    reset = 1;
    #20;
    reset = 0;
  end

  // ------------------------------------------
  // Simulation Control
  // ------------------------------------------
  initial begin
    // Run for a fixed time if not auto-terminated
    #10000;
    $display("TIMEOUT ❌ — Program did not finish within limit.");
    $finish;
  end

  // ------------------------------------------
  // Monitor Memory for Success Condition
  // ------------------------------------------
  // The reference test program writes 25 to mem[100] on success
  always @(posedge clk) begin
    if (!reset && uut.datapath.dmem.mem[100] === 32'd25) begin
      $display("✅ TEST PASSED: mem[100] = %0d", uut.datapath.dmem.mem[100]);
      $display("Cycle count: %0d", uut.datapath.cycle_count);
      $display("Instructions retired: %0d", uut.datapath.instr_retired);
      $finish;
    end
  end

  // ------------------------------------------
  // Optional Waveform Dump (GTKWave)
  // ------------------------------------------
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_pipeline);
  end

  // ------------------------------------------
  // Optional Logging
  // ------------------------------------------
  always @(posedge clk) begin
    if (!reset) begin
      $display("PC: %h | Instruction: %h | RegWrite: %b | ALUResult: %h",
               uut.datapath.pc,
               uut.datapath.imem.instr,
               uut.datapath.RegWriteW,
               uut.datapath.alu_result);
    end
  end

endmodule
