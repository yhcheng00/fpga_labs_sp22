module counter (
  input clk,
  input ce,
  output [3:0] LEDS
);
    // Some initial code has been provided for you
    // You can change this code if needed
    reg [3:0] led_cnt_value = 0;
    assign LEDS = led_cnt_value;

    // TODO: Instantiate a reg net to count the number of cycles
    // required to reach one second. Note that our clock period is 8ns.
    // Think about how many bits are needed for your reg.
    reg [26:0] cycle_count = 0;
    always @(posedge clk) begin
        // TODO: update the reg if clock is enabled (ce is 1).
        // Once the requisite number of cycles is reached, increment the count.
        if (ce && cycle_count != 125000000)
            cycle_count <= cycle_count + 1;
        if (ce && cycle_count == 125000000) begin
            cycle_count <= 1;
            led_cnt_value <= led_cnt_value + 1;
        end
    end
endmodule

