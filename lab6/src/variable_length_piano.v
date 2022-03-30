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
    reg [1:0] state = 0;
    reg [7:0] curr_note;
    assign address = curr_note;
    assign fcw = (state < 2)? 0 : data;
    assign leds = 1'b1 << state;
    assign ua_tx_din = ua_rx_dout;
    assign ua_tx_wr_en = wr_en_reg;
    assign ua_rx_rd_en = ~ua_tx_full;
    always @(posedge clk) begin
        wr_en_reg <= ~ua_rx_empty & ~ua_tx_full;
        if (rst) begin
            wr_en_reg <= 0;
            curr_note <= 0;
            state <= 0;
        end
        else begin
            if (state == 0 && wr_en_reg && ua_rx_dout == 8'h80) begin
                state <= 1;
            end
            if (state == 1 && wr_en_reg) begin
                curr_note <= ua_rx_dout;
                state <= 2;
            end
            if (state == 2 && wr_en_reg && ua_rx_dout == 8'h81) begin
                state <= 3;
            end
            if (state == 3 && wr_en_reg && ua_rx_dout == curr_note) begin
                state <= 0;
            end
        end
    end
    piano_scale_rom piano (
        .address(address),
        .data(data),
        .last_address(last_address)
    );
endmodule
