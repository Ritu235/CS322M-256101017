//===========================================================
// flopr.sv – Flip-Flop with Reset
// Used to implement pipeline registers (IF/ID, ID/EX, etc.)
//===========================================================

module flopr #(
    parameter WIDTH = 32                // Data width (default 32 bits)
) (
    input  logic              clk,      // Clock signal
    input  logic              reset,    // Active-high reset
    input  logic [WIDTH-1:0]  d,        // Input data
    output logic [WIDTH-1:0]  q         // Output data (registered)
);

    // Sequential logic: store d into q on rising edge of clock
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= '0;                    // On reset, clear register
        else
            q <= d;                     // On clock edge, latch new data
    end

endmodule
