`timescale 1ns/1ps
module tb_traffic_light;
    reg clk, reset;
    wire tick;
    wire [1:0] NS, EW;

    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns period
    end

    // Instantiate tick generator (scaled down for sim)
    tick_generator #(.COUNT_MAX(20)) tg(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // Instantiate traffic light FSM
    traffic_light tl(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .NS(NS),
        .EW(EW)
    );

    // Stimulus
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        reset = 1;
        #12 reset = 0;

        // Run long enough for two full cycles
        #800 $finish;
    end
endmodule
