// link_top.v
// Top-level module connecting the master and slave FSMs.
module link_top(
    input wire  clk,
    input wire  rst,
    output wire done
);
    // Internal wires for handshake
    wire        req;
    wire        ack;
    wire [7:0]  data;

    // Instantiate master FSM
    master_fsm u_master (
        .clk(clk),
        .rst(rst),
        .ack(ack),
        .req(req),
        .data(data),
        .done(done)
    );

    // Instantiate slave FSM
    slave_fsm u_slave (
        .clk(clk),
        .rst(rst),
        .req(req),
        .data_in(data),
        .ack(ack),
        .last_byte() // Not used in top, but observable in TB
    );

endmodule