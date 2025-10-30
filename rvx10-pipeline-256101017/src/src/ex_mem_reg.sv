// src/ex_mem_reg.sv
module ex_mem_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] alu_result_in,
    input  logic [31:0] write_data_in,
    input  logic [4:0]  rd_in,
    input  logic        regwrite_in,
    input  logic        memwrite_in,
    input  logic        memtoreg_in,
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0]  rd_out,
    output logic        regwrite_out,
    output logic        memwrite_out,
    output logic        memtoreg_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 0;
            write_data_out <= 0;
            rd_out         <= 0;
            regwrite_out   <= 0;
            memwrite_out   <= 0;
            memtoreg_out   <= 0;
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out         <= rd_in;
            regwrite_out   <= regwrite_in;
            memwrite_out   <= memwrite_in;
            memtoreg_out   <= memtoreg_in;
        end
    end
endmodule
