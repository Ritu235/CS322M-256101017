// Vending Machine (Mealy FSM) — price = 20, coins = 5 and 10
module vending_mealy(
    input        clk,
    input        reset,      // active-high, synchronous
    input  [1:0] coin,       // 00=none, 01=5, 10=10, 11=ignored
    output wire  dispense,   // 1-cycle pulse when vend
    output wire  chg5        // 1-cycle pulse when vend + give 5 back
);

    // State encoding (represents running total)
    parameter S0  = 2'd0; // 0
    parameter S5  = 2'd1; // 5
    parameter S10 = 2'd2; // 10
    parameter S15 = 2'd3; // 15

    reg [1:0] state, next_state;

    // Coin decode
    wire coin5  = (coin == 2'b01);
    wire coin10 = (coin == 2'b10);
    wire noCoin = (coin == 2'b00);

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Next state + output logic
    reg dispense_r, chg5_r;
    always @(*) begin
        // defaults
        next_state = state;
        dispense_r = 0;
        chg5_r     = 0;

        case (state)
            S0: begin
                if (coin5)       next_state = S5;
                else if (coin10) next_state = S10;
            end

            S5: begin
                if (coin5)       next_state = S10;
                else if (coin10) next_state = S15;
            end

            S10: begin
                if (coin5)       next_state = S15;
                else if (coin10) begin
                    dispense_r = 1;
                    next_state = S0;
                end
            end

            S15: begin
                if (coin5) begin
                    dispense_r = 1;
                    next_state = S0;
                end else if (coin10) begin
                    dispense_r = 1;
                    chg5_r     = 1;
                    next_state = S0;
                end
            end
        endcase

        if (noCoin) next_state = state; // stay if no coin
    end

    // Outputs as wires
    assign dispense = dispense_r;
    assign chg5     = chg5_r;

endmodule
