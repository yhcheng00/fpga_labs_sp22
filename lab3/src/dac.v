module dac #(
    parameter CYCLES_PER_WINDOW = 1024,
    parameter CODE_WIDTH = $clog2(CYCLES_PER_WINDOW)
)(
    input clk,
    input [CODE_WIDTH-1:0] code,
    output next_sample,
    output pwm
);
    reg sample = 0;
    reg [CODE_WIDTH-1:0] count = 0;
    assign pwm = (count <= code);
    always @(posedge clk) begin
        if (count != CYCLES_PER_WINDOW-1) begin
        count <= count + 1;
        end
        else begin
        count <= 0;
        end
        if (count == CYCLES_PER_WINDOW-2)
            sample <= 1;
        else
            sample <= 0;
    end
    assign next_sample = sample;
endmodule
