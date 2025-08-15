`timescale 1ns/1ps
module tb_seq_detect_mealy;
    reg clk, reset, x;
    wire y;

    seq_detect_mealy dut(clk, reset, x, y);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        reset = 1; x = 0;
        #12 reset = 0;

        // Pattern: 11011011101
        #10 x=1; #10 x=1; #10 x=0; #10 x=1;
        #10 x=1; #10 x=0; #10 x=1; #10 x=1;
        #10 x=1; #10 x=0; #10 x=1;
        #20 $finish;
    end
endmodule
