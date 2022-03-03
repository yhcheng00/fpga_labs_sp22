module counter #(
    parameter CYCLES_PER_SECOND = 125_000
)(
    input clk,
    input ce,
    input [3:0] buttons,
    output [3:0] leds
);
    reg [3:0] counter = 0;
    assign leds = counter;
    reg [$clog2(CYCLES_PER_SECOND)-1:0] cycles = 0;
    reg mode = 0;
    always @(posedge clk) begin
        if (buttons[2])
            mode <= ~mode;
        if (mode) begin
            if (cycles == CYCLES_PER_SECOND) begin
            cycles <= 1;
            counter <= counter + 4'd1;
            end
            else
                cycles <= cycles + 1;
        end
        else begin
            if (buttons[0])
                counter <= counter + 4'd1;
            else if (buttons[1])
                counter <= counter - 4'd1;
            else if (buttons[3])
                counter <= 4'd0;
            else
                counter <= counter;
        end
    end
endmodule

