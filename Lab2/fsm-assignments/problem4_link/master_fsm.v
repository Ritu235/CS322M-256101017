// master_fsm.v
// Implements the master side of the req/ack handshake protocol.
// It sends a burst of 4 bytes of data.
module master_fsm(
    input wire       clk,
    input wire       rst, // sync active-high
    input wire       ack,
    output wire      req,
    output wire [7:0] data,
    output wire      done // 1-cycle when burst completes
);

    // State encoding
    localparam S_IDLE        = 3'd0;
    localparam S_DRIVE_DATA  = 3'd1;
    localparam S_WAIT_ACK    = 3'd2;
    localparam S_WAIT_NO_ACK = 3'd3;
    localparam S_DONE        = 3'd4;

    // Registers
    reg [2:0] state_reg, state_next;
    reg [1:0] byte_count_reg, byte_count_next;
    reg [7:0] data_reg;

    // Sequential logic for state and byte counter
    always @(posedge clk) begin
        if (rst) begin
            state_reg      <= S_IDLE;
            byte_count_reg <= 2'd0;
        end else begin
            state_reg      <= state_next;
            byte_count_reg <= byte_count_next;
        end
    end

    // Example data to send (A0, A1, A2, A3)
    assign data = data_reg;

    // Next-state and output combinational logic
    always @(*) begin
        // Default assignments
        state_next      = state_reg;
        byte_count_next = byte_count_reg;
        data_reg        = 8'hA0 + byte_count_reg; // Default data
        
        case (state_reg)
            S_IDLE: begin
                // Start the transfer
                state_next = S_DRIVE_DATA;
            end
            
            S_DRIVE_DATA: begin
                // Move to wait for slave's acknowledgement
                state_next = S_WAIT_ACK;
            end

            S_WAIT_ACK: begin
                if (ack) begin
                    // Slave acknowledged, check if we are done
                    if (byte_count_reg == 2'd3) begin
                        state_next = S_DONE;
                    end else begin
                        state_next      = S_WAIT_NO_ACK;
                        byte_count_next = byte_count_reg + 1;
                    end
                end
            end

            S_WAIT_NO_ACK: begin
                if (!ack) begin
                    // Handshake complete for this byte, start next one
                    state_next = S_DRIVE_DATA;
                end
            end

            S_DONE: begin
                // Pulse done for one cycle and return to idle
                state_next = S_IDLE;
            end
            
            default: begin
                state_next = S_IDLE;
            end
        endcase
    end

    // Output logic
    assign req  = (state_reg == S_DRIVE_DATA) || (state_reg == S_WAIT_ACK);
    assign done = (state_reg == S_DONE);

endmodule