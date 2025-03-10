module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like
    reg [WIDTH-1:0] signal_1 = 0;
    reg [WIDTH-1:0] signal_2 = 0;
    // Remove this line once you create your edge detector
    //assign edge_detect_pulse = 0;
    always @(posedge clk) begin
    signal_1 <= signal_in;
    signal_2 <= signal_1;
    end
    assign edge_detect_pulse = signal_1 & ~signal_2;
endmodule
