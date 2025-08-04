// tb_comparator_4bit.v
`timescale 1ns/1ps
module test;

reg [3:0] A, B;
wire equal;

comparator_4bit uut (
    .A(A),
    .B(B),
    .equal(equal)
);

initial begin
    $display("  A     B   | Equal");
    $monitor("%b %b |   %b", A, B, equal);

    A = 4'b0000; B = 4'b0000; #10;
    A = 4'b0001; B = 4'b0001; #10;
    A = 4'b1010; B = 4'b1010; #10;
    A = 4'b1111; B = 4'b0000; #10;
    A = 4'b1100; B = 4'b1010; #10;

    $finish;
end

endmodule
