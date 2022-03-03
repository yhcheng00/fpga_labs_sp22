module sq_wave_gen (
    input clk,
    input next_sample,
    output [9:0] code
);
    reg [9:0] current_code = 0;
    reg [18:0] count = 0;
    assign code = current_code;
    always @(posedge clk) begin
    //Previously 2204
    if (count != 284090-1)
        count <= count + 1;
    else
        count <= 1;
    if (next_sample) begin
        if (count <= 142045-1)
            current_code <= 562;
        else
            current_code <= 462;
    end
    end
endmodule
