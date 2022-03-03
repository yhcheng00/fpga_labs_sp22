module sq_wave_gen #(
    parameter STEP = 10
)(
    input clk,
    input rst,
    input next_sample,
    input [2:0] buttons,
    output [9:0] code,
    output [3:0] leds
);
    parameter DEFAULT_PERIOD = 284090;
    parameter MIN_PERIOD = 12500;
    parameter MAX_PERIOD = 6250000;
    reg [9:0] current_code;
    reg [$clog2(MAX_PERIOD):0] count;
    reg [$clog2(MAX_PERIOD):0] period;
    reg [$clog2(MAX_PERIOD):0] zero = 0;
    reg mode; //0 is linear, 1 is exponential
    assign leds[0] = mode;
    assign code = current_code;
    always @(posedge clk) begin
    //Previously 2204
        if (rst) begin
            count <= 0;
            period <= DEFAULT_PERIOD;
            mode <= 0;
        end
        if (buttons[2])
            mode <= ~mode;
        if (mode) begin
            if (buttons[0] && ((period >> 1) >= MIN_PERIOD))
                period <= period >> 1;
            if (buttons[1] && ((period << 1) <= MAX_PERIOD))
                period <= period << 1;
        end
        if (~mode) begin
            if (buttons[0] && ((period - STEP * 1024) >= MIN_PERIOD) && (period > STEP * 1024))
                period <= period - STEP * 1024;
            if (buttons[1] && ((period + STEP * 1024) <= MAX_PERIOD) && (((zero - 1) - STEP * 1024) >= period))
                period <= period + STEP * 1024;
        end
        if (count != period-1)
            count <= count + 1;
        else
            count <= 1;
        if (next_sample) begin
            if (count <= period/2-1)
                current_code <= 562;
            else
                current_code <= 462;
        end
    end
endmodule
