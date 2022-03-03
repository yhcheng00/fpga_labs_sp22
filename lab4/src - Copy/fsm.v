module fsm #(
    parameter CYCLES_PER_SECOND = 125_000_000,
    parameter WIDTH = $clog2(CYCLES_PER_SECOND)
)(
    input clk,
    input rst,
    input [2:0] buttons,
    output [3:0] leds,
    output [23:0] fcw,
    output [1:0] leds_state
);
    parameter REGULAR_PLAY = 0;
    parameter REVERSE_PLAY = 1;
    parameter PAUSED = 2;
    parameter EDIT = 3;
    parameter MIN_FCW = 2749;
    parameter MAX_FCW = 1374390;
    reg [1:0] state;
    assign leds = 1 << addr;
    assign fcw = rd_en_reg? d_out : 0;
    reg [23:0] edit_reg;
    assign d_in = edit_reg;
    assign leds_state = state;
    reg rd_en_reg;
    assign rd_en = rd_en_reg;
    reg wr_en_reg;
    assign wr_en = wr_en_reg;
    reg [WIDTH-1:0] count;
    reg [1:0] addr_reg;
    assign addr = addr_reg;
    wire [1:0] addr;
    wire wr_en, rd_en;
    wire [23:0] d_in, d_out;
    always @(posedge clk) begin
        case(state)
            REGULAR_PLAY: begin
                if (buttons[0])
                    state <= PAUSED;
                if (buttons[1])
                    state <= REVERSE_PLAY;
            end
            REVERSE_PLAY: begin
                if (rst)
                    state <= REGULAR_PLAY;
                else if (buttons[0])
                    state <= PAUSED;
                else if (buttons[1])
                    state <= REGULAR_PLAY;
                
            end
            PAUSED: begin
                if (rst)
                    state <= REGULAR_PLAY;
                else if (buttons[0])
                    state <= REGULAR_PLAY;
                else if (buttons[2])
                    state <= EDIT;
            end
            EDIT: begin
                if (rst)
                    state <= REGULAR_PLAY;
                if (buttons[2])
                    state <= PAUSED;
            end
            endcase
    end
    always @(posedge clk) begin
        if (rst) begin
            rd_en_reg <= 0;
            wr_en_reg <= 0;
            edit_reg <= d_out;
            addr_reg <= 0;
            count <= 0;
        end
        else begin
            if (state == REGULAR_PLAY) begin
                rd_en_reg <= 1;
                wr_en_reg <= 0;
                if (count == CYCLES_PER_SECOND) begin
                    count <= 1;
                    addr_reg <= addr_reg + 1;
                end
                else
                    count <= count + 1;
            end
            if (state == REVERSE_PLAY) begin
                rd_en_reg <= 1;
                wr_en_reg <= 0;
                if (count == 0) begin
                    count <= CYCLES_PER_SECOND-1;
                    addr_reg <= addr_reg - 1;
                end
                else
                    count <= count - 1;
            end
            if (state == PAUSED) begin
                rd_en_reg <= 0;
                wr_en_reg <= 0;
                edit_reg <= d_out;
            end
            if (state == EDIT) begin
                rd_en_reg <= 1;
                wr_en_reg <= 1;
                if (buttons[0] && d_out >> 1 >= MIN_FCW) begin
                    edit_reg <= d_out >> 1;
                end
                if (buttons[1] && d_out << 1 <= MAX_FCW) begin
                    edit_reg <= d_out << 1;
                end
            end
        end
    end
    fcw_ram notes (
        .clk(clk),
        .rst(rst),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .addr(addr),
        .d_in(d_in),
        .d_out(d_out)
    );
endmodule
