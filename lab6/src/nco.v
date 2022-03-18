module nco(
    input clk,
    input rst,
    input [23:0] fcw,
    input next_sample,
    output [9:0] code
);
    reg [9:0] sine_lut [0:255];
    reg [9:0] current_code = 0;
    reg [23:0] index = 0;
    assign code = current_code;
    initial begin
    $readmemb("sine.bin", sine_lut);
    end
    always @(posedge clk) begin
        if (rst) begin
            index <= 0;
            current_code = 0;
        end
        if (next_sample) begin
            index <= index + fcw;
            current_code <= sine_lut[index[23:16]];
        end
    end
endmodule
