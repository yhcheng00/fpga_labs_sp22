module fixed_length_piano #(
    parameter CYCLES_PER_SECOND = 125_000_000
) (
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
    wire [7:0] din;
    wire [7:0] dout;
    wire [23:0] data;
    wire [7:0] last_address;
    wire [7:0] address;
    reg [$clog2(CYCLES_PER_SECOND):0] note_length = CYCLES_PER_SECOND/5;
    reg [$clog2(CYCLES_PER_SECOND):0] counter;
    reg wr_en_reg = 0;
    reg playing = 0;
    assign fcw = ~playing? 0 : data;
    assign leds = 'd0;
    assign ua_tx_din = ua_rx_dout;
    assign din = ua_rx_dout;
    assign wr_en = wr_en_reg;
    assign ua_tx_wr_en = wr_en_reg;
    assign ua_rx_rd_en = ~ua_tx_full;
    assign rd_en = ~empty && counter == 0;
    assign address = dout;
    always @(posedge clk) begin
        wr_en_reg <= ~ua_rx_empty;
        if (rst) begin
            note_length <= CYCLES_PER_SECOND/5;
            counter <= 0;
            wr_en_reg <= 0;
            playing <= 0;
        end
        else begin
            if (rd_en) begin
                playing <= 1;
            end
            if (counter == note_length-1) begin
                counter <= 0;
                if (empty) begin
                    playing <= 0;
                end
            end
            else begin
                if (playing) begin
                    counter <= counter + 1;
                end
            end
        end
    end
    fifo #(.DEPTH(1000)) note_buffer (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        .rd_en(rd_en),
        .dout(dout),
        .empty(empty)
    );
    piano_scale_rom piano (
        .address(address),
        .data(data),
        .last_address(last_address)
    );
endmodule
