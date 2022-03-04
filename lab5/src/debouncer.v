module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec
    // Remove this line once you have created your debouncer

    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];
    reg [WIDTH-1:0] equality_counter;
    integer k;
    initial begin
        for (k = 0; k < WIDTH; k = k + 1) begin
        saturating_counter[k] = 0;
        equality_counter[k] = 0;
        end
    end
    reg [WRAPPING_CNT_WIDTH-1:0] sample_pulse_counter = 0;
    reg sample_pulse = 0;
    always @(posedge clk) begin
    if (sample_pulse_counter != SAMPLE_CNT_MAX) begin
    sample_pulse_counter <= sample_pulse_counter + 1;
    sample_pulse <= 0;
    end
    if (sample_pulse_counter == SAMPLE_CNT_MAX) begin
    sample_pulse_counter <= 1;
    sample_pulse <= 1;
    end
    end
    always @(posedge sample_pulse) begin
    for (k = 0; k < WIDTH; k= k + 1) begin
    if (glitchy_signal[k]) begin
    if (saturating_counter[k] < PULSE_CNT_MAX)
        saturating_counter[k] <= saturating_counter[k] + 1;
    else
        equality_counter[k] <= 1;
    end
    else begin
    saturating_counter[k] <= 0;
    equality_counter[k] <= 0;
    end 
    end
    end
    assign debounced_signal = equality_counter;
endmodule
