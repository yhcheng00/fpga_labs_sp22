module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,
    output serial_out
    //output [3:0] bit_counter
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

    // Remove these assignments when implementing this module
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;
    //reg serial_reg;
    //assign serial_out = serial_reg;
    reg transmitting;
    reg [3:0] bit_counter;
    assign data_in_ready = ~transmitting;
    wire [9:0] serial_bus;
    reg [7:0] data_reg;
    assign serial_bus = {1'b1,data_reg,1'b0};
    assign serial_out = transmitting? serial_bus[bit_counter] : 1;
    always @(posedge clk) begin
        if (reset) begin
            clock_counter <= 0;
            transmitting <= 0;
            bit_counter <= 0;
            data_reg <= 0;
        end 
        else begin
            if (transmitting) begin
                if (clock_counter != SYMBOL_EDGE_TIME)
                   clock_counter <= clock_counter + 1;
                else begin
                    if (bit_counter == 9) begin
                        transmitting <= 0;
                        clock_counter <= 0;
                        bit_counter <= 0;
                    end
                    else begin
                        bit_counter <= bit_counter + 1;
                        clock_counter <= 1;
                    end
                end
            end
            else if (data_in_valid) begin
                data_reg <= data_in;
                transmitting <= 1;
                clock_counter <= 1;
            end
        end
    end
endmodule
