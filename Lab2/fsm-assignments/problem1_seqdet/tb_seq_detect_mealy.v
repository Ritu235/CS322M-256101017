`timescale 1ns/1ps
module tb_seq_detect_mealy;
    reg clk, rst, din;
    wire y;

    // DUT instantiation
    seq_detect_mealy dut (
        .clk(clk),
        .reset(rst),
        .din(din),
        .y(y)
    );

    // 1) Clock generation (100 MHz -> 10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5 ns
    end

    // 2) Reset and drive a bitstream with overlaps
    initial begin
        // Dump for waveform
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        // Apply reset
        rst = 1; din = 0;
        #12 rst = 0;

        // Drive sequence: 11011011101
        din = 1; #10;
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;
        din = 1; #10;
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;

        #20 $finish;
    end

    // 3) Log time, din, y
    initial begin
        $monitor("Time=%0t | din=%b | y=%b", $time, din, y);
    end
endmodule
