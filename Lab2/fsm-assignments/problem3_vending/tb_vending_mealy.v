`timescale 1ns/1ps
module tb_vending_mealy;
    reg clk, reset;
    reg [1:0] coin;
    wire dispense, chg5;

    vending_mealy dut (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .dispense(dispense),
        .chg5(chg5)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns period
    end

    // helper tasks
    task put5;
    begin
        coin = 2'b01; @(posedge clk);
        coin = 2'b00; @(posedge clk);
    end
    endtask

    task put10;
    begin
        coin = 2'b10; @(posedge clk);
        coin = 2'b00; @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_vending_mealy);

        coin = 2'b00;
        reset = 1; repeat(2) @(posedge clk);
        reset = 0; @(posedge clk);

        // 1) 10 + 10
        put10(); put10(); repeat(2) @(posedge clk);

        // 2) 5 + 5 + 10
        put5(); put5(); put10(); repeat(2) @(posedge clk);

        // 3) 10 + 5 + 10
        put10(); put5(); put10(); repeat(4) @(posedge clk);

        $finish;
    end
endmodule
