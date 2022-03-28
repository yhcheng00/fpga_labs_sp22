module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH+1)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [WIDTH-1:0] dout,
    output empty
);
    reg [WIDTH-1:0] buffer[0:DEPTH];
    reg [POINTER_WIDTH-1:0]write_pointer;
    reg [POINTER_WIDTH-1:0]read_pointer;
    reg [WIDTH-1:0] read_buffer;
    assign dout = read_buffer;
    assign full = ((write_pointer + 1)%(DEPTH+1)) == read_pointer;
    assign empty = write_pointer == read_pointer;
    always @(posedge clk) begin
        if (rst) begin
            write_pointer <= 0;
            read_pointer <= 0;
        end
        else begin
            if (wr_en && ~full) begin
                buffer[write_pointer] <= din;
                write_pointer <= ((write_pointer + 1)%(DEPTH+1));
            end
            if (rd_en && ~empty) begin
                read_buffer <= buffer[read_pointer];
                read_pointer <= ((read_pointer + 1)%(DEPTH+1));
            end
        end
    end
endmodule
