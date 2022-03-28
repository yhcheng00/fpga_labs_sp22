module z1top #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200,
    /* verilator lint_off REALCVT */
    // Sample the button signal every 500us
    parameter integer B_SAMPLE_CNT_MAX = 0.0005 * CLOCK_FREQ,
    // The button is considered 'pressed' after 100ms of continuous pressing
    parameter integer B_PULSE_CNT_MAX = 0.100 / 0.0005,
    /* lint_on */
    parameter CYCLES_PER_SECOND = 125_000_000
) (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    output AUD_PWM,
    output AUD_SD,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);
    assign AUD_SD = 1; // Enable the audio output

    wire [2:0] buttons_pressed;
    wire [1:0] switches_sync;
    wire reset;
    button_parser #(
        .WIDTH(4),
        .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
    ) bp (
        .clk(CLK_125MHZ_FPGA),
        .in(BUTTONS),
        .out({buttons_pressed, reset})
    );

    synchronizer #(.WIDTH(2)) switch_sync (
        .clk(CLK_125MHZ_FPGA),
        .async_signal(SWITCHES),
        .sync_signal(switches_sync)
    );

    wire [7:0] data_in;
    wire [7:0] data_out;
    wire data_in_valid, data_in_ready, data_out_valid, data_out_ready;
    wire ua_tx_wr_en, ua_tx_rd_en, ua_tx_full, ua_tx_empty, ua_rx_wr_en, ua_rx_rd_en, ua_rx_full, ua_rx_empty, next_sample;
    wire [7:0] ua_tx_din, ua_tx_dout, ua_rx_din, ua_rx_dout;
    wire [23:0] fcw;
    wire [9:0] code;
    assign ua_tx_rd_en = data_in_ready;
    assign data_in_valid = ~(data_in_ready && ua_tx_empty);
    assign data_in = ua_tx_dout;
    assign ua_rx_wr_en = data_out_valid;
    assign data_out_ready = ~ua_rx_full;
    assign ua_rx_din = data_out;
    // This UART is on the FPGA and communicates with your desktop
    // using the FPGA_SERIAL_TX, and FPGA_SERIAL_RX signals. The ready/valid
    // interface for this UART is used on the FPGA design.
    uart # (
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(CLK_125MHZ_FPGA),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    //// TODO: Instantiate the UART FIFOs, nco, dac, and piano
    
    fixed_length_piano #(.CYCLES_PER_SECOND(CYCLES_PER_SECOND)) test_piano (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .buttons(buttons_pressed),
        .leds(LEDS),
        .ua_tx_din(ua_tx_din),
        .ua_tx_wr_en(ua_tx_wr_en),
        .ua_tx_full(ua_tx_full),
        .ua_rx_dout(ua_rx_dout),
        .ua_rx_empty(ua_rx_empty),
        .ua_rx_rd_en(ua_rx_rd_en),
        .fcw(fcw)
    );
    fifo tx_fifo (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .wr_en(ua_tx_wr_en),
        .din(ua_tx_din),
        .full(ua_tx_full),
        .rd_en(ua_tx_rd_en),
        .dout(ua_tx_dout),
        .empty(ua_tx_empty)
    );
    fifo rx_fifo (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .wr_en(ua_rx_wr_en),
        .din(ua_rx_din),
        .full(ua_rx_full),
        .rd_en(ua_rx_rd_en),
        .dout(ua_rx_dout),
        .empty(ua_rx_empty)
    );
    nco sound_nco (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .fcw(fcw),
        .next_sample(next_sample),
        .code(code)
    );
    dac sound_dac (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .code(code),
        .next_sample(next_sample),
        .pwm(AUD_PWM)
    );
    //assign AUD_PWM = 0; // Comment this out when ready
    //assign LEDS[5:0] = 6'b11_0001; // Connect to the leds output of the piano
endmodule
