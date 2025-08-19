module seq_detect_mealy(
    input clk, reset, din,
    output wire y
);
    reg [2:0] state, next_state;
    parameter S0=0, S1=1, S2=2, S3=3;

    reg y_reg;  // internal reg for output
    assign y = y_reg; // drive wire output

    always @(posedge clk or posedge reset) begin
        if (reset) state <= S0;
        else state <= next_state;
    end

    always @(*) begin
        y_reg = 0; // default
        case (state)
            S0: if (din) next_state = S1; else next_state = S0;
            S1: if (din) next_state = S2; else next_state = S0;
            S2: if (~din) next_state = S3; else next_state = S2;
            S3: if (din) begin
                    next_state = S1; 
                    y_reg = 1; // Mealy output
                end
                else next_state = S0;
        endcase
    end
endmodule
