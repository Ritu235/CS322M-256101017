
module comp1 (
    input A,
    input B,
    output o1,  // A > B
    output o2,  // A == B
    output o3   // A < B
);

assign o1 = A & ~B;     // A > B
assign o2 = ~(A ^ B);   // A == B
assign o3 = ~A & B;     // A < B

endmodule
