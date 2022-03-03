module full_adder (
    input a,
    input b,
    input carry_in,
    output sum,
    output carry_out
);
    // Insert your RTL here to calculate the sum and carry out bits
    // Remove these assign statements once you write your own RTL

    assign sum = (a ^ b) ^ carry_in;
    assign carry_out = (a & b) | (b & carry_in) | (carry_in & a);
endmodule
