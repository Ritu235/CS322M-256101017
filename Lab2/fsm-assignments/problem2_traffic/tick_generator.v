// Tick Generator: Produces a single-cycle pulse every COUNT_MAX clock cycles
module tick_generator #(parameter COUNT_MAX = 20)(
    input clk, reset,
    output reg tick
);
    reg [$clog2(COUNT_MAX)-1:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            tick <= 0;
        end else if (count == COUNT_MAX-1) begin
            count <= 0;
            tick <= 1; // pulse for 1 clock cycle
        end else begin
            count <= count + 1;
            tick <= 0;
        end
    end
endmodule
