module variable_length_piano (
    input clk,
    input rst,

    input [2:0] buttons,
    output [5:0] leds,

    output [7:0] ua_tx_din,
    output ua_tx_wr_en,
    input ua_tx_full,

    input [7:0] ua_rx_dout,
    input ua_rx_empty,
    output ua_rx_rd_en,

    output [23:0] fcw
);
    wire [23:0] data;
    wire [7:0] last_address;
    wire [7:0] address;
    reg wr_en_reg = 0;
    reg [7:0] curr_chars [0:1];
    reg [7:0] curr_note = 0;
    reg playing = 0;
    assign address = curr_note;
    assign fcw = data;
    assign leds = 0;
    assign ua_tx_din = ua_rx_dout;
    assign ua_tx_wr_en = wr_en_reg;
    assign ua_rx_rd_en = ~ua_tx_full;
    always @(posedge clk) begin
        wr_en_reg <= ~ua_rx_empty & ~ua_tx_full;
        if (rst) begin
            wr_en_reg <= 0;
            curr_note <= 0;
            playing <= 0;
            curr_chars[0] <= 0;
            curr_chars[1] <= 0;
        end
        else begin
            if (wr_en_reg) begin
                curr_chars[0] <= ua_rx_dout;
                curr_chars[1] <= curr_chars[0];
            end
            if (curr_chars[1] == 8'h80 && ~playing) begin
                curr_note <= curr_chars[0];
                playing <= 1;
                curr_chars[0] <= 0;
                curr_chars[1] <= 0;
            end
            if (curr_chars[1] == 8'h81 && curr_chars[0] == curr_note && playing) begin
                playing <= 0;
                curr_note <= 0;
                curr_chars[0] <= 0;
                curr_chars[1] <= 0;
            end
        end
    end
    piano_scale_rom piano (
        .address(address),
        .data(data),
        .last_address(last_address)
    );
endmodule
