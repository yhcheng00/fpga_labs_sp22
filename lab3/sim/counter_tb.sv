`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000

module counter_tb();
    reg clock = 0;
    reg ce = 1;
    wire [3:0] LEDS;
    reg [3:0] buttons = 0;
    counter ctr (
        .clk(clock),
        .ce(ce),
        .buttons(buttons),
        .leds(LEDS)
    );

    // Notice that this code causes the `clock` signal to constantly
    // switch up and down every 4 time steps.
    always #(4) clock <= ~clock;

    initial begin
        //`ifdef IVERILOG
            //$dumpfile("counter_testbench.fst");
            //$dumpvars(0, counter_testbench);
        //`endif
        //`ifndef IVERILOG
            //$vcdpluson;
        //`endif
        repeat (200000) @(posedge clock);
        assert(LEDS == 0) else $error("Expected LEDS to be 0, actual value: %d", LEDS);
        buttons[0] = 1;
        @(posedge clock);
        buttons[0] = 0;
        assert(LEDS == 1) else $error("Expected LEDS to be 1, actual value: %d", LEDS);
        buttons[1] = 1;
        @(posedge clock);
        buttons[1] = 0;
        assert(LEDS == 0) else $error("Expected LEDS to be 0, actual value: %d", LEDS);
        buttons[1] = 1;
        @(posedge clock);
        buttons[1] = 0;
        buttons[1] = 1;
        @(posedge clock);
        buttons[1] = 0;
        assert(LEDS == 14) else $error("Expected LEDS to be 14, actual value: %d", LEDS);
        buttons[3] = 1;
        @(posedge clock);
        buttons[3] = 0;
        assert(LEDS == 0) else $error("Expected LEDS to be 0, actual value: %d", LEDS);
        buttons[2] = 1;
        @(posedge clock);
        buttons[2] = 0;
        repeat (200000)@(posedge clock);
        assert(LEDS == 1) else $error("Expected LEDS to be 1, actual value: %d", LEDS);
        buttons[2] = 1;
        @(posedge clock);
        buttons[2] = 0;
        buttons[0] = 1;
        @(posedge clock);
        buttons[0] = 0;
        assert(LEDS == 2) else $error("Expected LEDS to be 2, actual value: %d", LEDS);
        buttons[2] = 1;
        @(posedge clock);
        buttons[2] = 0;
        repeat (90000)@(posedge clock);
        assert(LEDS == 3) else $error("Expected LEDS to be 3, actual value: %d", LEDS);
        // TODO: Change input values and step forward in time to test
        // your counter and its clock enable/disable functionality.
        

        //`ifndef IVERILOG
            //$vcdplusoff;
        //`endif
        $finish();
    end
endmodule