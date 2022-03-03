module arithmetic_logic_unit(
    input [31:0] in1, [31:0] in2,
    output [31:0] alu);
    wire signed [31:0] in1s, in2s;  
    assign in1s = in1;
    assign in2s = in2;
    always @(*) begin
        case (ALUSel)
            ADD: alu = in1 + in2;//Used by AUIPC, BLT, LW
            SUB: alu = in1 - in2;
            SHIFT_LEFT: alu = in1 << in2[4:0];
            LESS_THAN_S: alu = (in1s < in2s) ? 32'b1 : 32'b0;//Used by SLT
            SHIFT_RIGHT: alu = in1 >> in2[4:0];//Used by SRL
            OR: alu = in1 | in2;
            AND: alu = in1 & in2;
            PASS: alu = in2; //Used by LUI
            SHIFT_RIGHT_ARITHMETIC: alu = in1 >>> in2[4:0];//Used by SRA
            LESS_THAN_S_UNSIGNED: alu = (in1 < in2) ? 32'b1 : 32'b0;//Used by SLTU
        endcase
    end
endmodule
