// tb_link_top.v
// Testbench for the master-slave link.
module tb_link_top;
    reg clk;
    reg rst;
    wire done;

    // Instantiate the design under test (DUT)
    link_top dut (
        .clk(clk),
        .rst(rst),
        .done(done)
    );

    // 1. Clock generation (100 MHz clock, 10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2. Test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("handshake_waves.vcd");
        $dumpvars(0, tb_link_top);

        // Apply reset
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;
        
        $display("Time\tReq\tAck\tData\tDone\tLastByte");
        
        // 3. Run until 'done' is high
        wait (done);
        
        @(posedge clk); // Let done pulse finish
        $display("INFO: 4-byte transfer complete. Simulation finished.");
        $finish;
    end
    
    // Monitor for logging key signals
    always @(posedge clk) begin
        if (!rst) begin
            $display("%0t\t%b\t%b\t%h\t%b\t%h",
                $time,
                dut.u_master.req,
                dut.u_slave.ack,
                dut.u_master.data,
                done,
                dut.u_slave.last_byte
            );
        end
    end

endmodule