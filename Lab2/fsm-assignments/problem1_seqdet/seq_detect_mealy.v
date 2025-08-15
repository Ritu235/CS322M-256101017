module seq_detect_mealy(
    input clk, reset, x,
    output reg y
);
    reg [2:0] state, next_state;
    parameter S0=0, S1=1, S2=2, S3=3;

    always @(posedge clk or posedge reset) begin
        if (reset) state <= S0;
        else state <= next_state;
    end

    always @(*) begin
        y = 0;
        case (state)
            S0: if (x) next_state = S1; else next_state = S0;
            S1: if (x) next_state = S2; else next_state = S0;
            S2: if (~x) next_state = S3; else next_state = S2;
            S3: if (x) begin
                    next_state = S1; 
                    y = 1; // Mealy output
                end
                else next_state = S0;
        endcase
    end
endmodule
