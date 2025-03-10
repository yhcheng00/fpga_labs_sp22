`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000

module counter_testbench();
    reg clock = 0;
    reg ce = 1;
    wire [3:0] LEDS;

    counter ctr (
        .clk(clock),
        .ce(ce),
        .LEDS(LEDS)
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
        repeat (1000000010) @(posedge clock);
        assert(LEDS == 8) else $display("ERROR: Expected LEDS to be 8, actual value: %d", LEDS);
        // TODO: Change input values and step forward in time to test
        // your counter and its clock enable/disable functionality.
        

        //`ifndef IVERILOG
            //$vcdplusoff;
        //`endif
        $finish();
    end
endmodule
