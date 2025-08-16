// Moore FSM Traffic Light Controller
module traffic_light(
    input clk, reset, tick,
    output reg [1:0] NS, EW  // 00=Red, 01=Green, 10=Yellow
);
    // State encoding
    localparam NS_G = 0, NS_Y = 1, EW_G = 2, EW_Y = 3;

    reg [1:0] state, next_state;
    reg [2:0] count; // count ticks for each state

    // State register and tick-based counting
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= NS_G;
            count <= 0;
        end else if (tick) begin
            if ((state == NS_G && count == 4) ||
                (state == NS_Y && count == 1) ||
                (state == EW_G && count == 4) ||
                (state == EW_Y && count == 1)) begin
                state <= next_state;
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            NS_G: next_state = NS_Y;
            NS_Y: next_state = EW_G;
            EW_G: next_state = EW_Y;
            EW_Y: next_state = NS_G;
            default: next_state = NS_G;
        endcase
    end

    // Output logic (Moore)
    always @(*) begin
        case (state)
            NS_G: begin NS = 2'b01; EW = 2'b00; end // NS green, EW red
            NS_Y: begin NS = 2'b10; EW = 2'b00; end // NS yellow, EW red
            EW_G: begin NS = 2'b00; EW = 2'b01; end // NS red, EW green
            EW_Y: begin NS = 2'b00; EW = 2'b10; end // NS red, EW yellow
            default: begin NS = 2'b00; EW = 2'b00; end
        endcase
    end
endmodule
