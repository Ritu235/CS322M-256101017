// slave_fsm.v
// Implements the slave side of the req/ack handshake.
// It latches data and asserts ack for exactly 2 cycles.
module slave_fsm(
    input wire        clk,
    input wire        rst,       // sync active-high
    input wire        req,
    input wire  [7:0] data_in,
    output wire       ack,
    output reg  [7:0] last_byte  // observable for TB
);

    // State encoding
    localparam S_IDLE        = 2'd0;
    localparam S_LATCH_ACK   = 2'd1;
    localparam S_HOLD_ACK    = 2'd2;
    localparam S_WAIT_NO_REQ = 2'd3;
    
    // Registers
    reg [1:0] state_reg, state_next;

    // Sequential logic for state and data latching
    always @(posedge clk) begin
        if (rst) begin
            state_reg <= S_IDLE;
            last_byte <= 8'h00;
        end else begin
            state_reg <= state_next;
            // Latch data only when transitioning to S_LATCH_ACK
            if (state_next == S_LATCH_ACK) begin
                last_byte <= data_in;
            end
        end
    end

    // Next-state combinational logic
    always @(*) begin
        state_next = state_reg;
        case (state_reg)
            S_IDLE: begin
                if (req) begin
                    state_next = S_LATCH_ACK;
                end
            end
            
            S_LATCH_ACK: begin
                // First cycle of ack, hold for one more
                state_next = S_HOLD_ACK;
            end

            S_HOLD_ACK: begin
                // Second cycle of ack done, wait for req to drop
                state_next = S_WAIT_NO_REQ;
            end

            S_WAIT_NO_REQ: begin
                if (!req) begin
                    // Master has seen ack, return to idle
                    state_next = S_IDLE;
                end
            end
            
            default: begin
                state_next = S_IDLE;
            end
        endcase
    end
    
    // Output logic for ack
    assign ack = (state_reg == S_LATCH_ACK) || (state_reg == S_HOLD_ACK) || (state_reg == S_WAIT_NO_REQ);

endmodule