module Forward(
    input RegWriteMEM,
    input [4:0] WriteRegMEM,
    input [4:0] Rs1,
    input [4:0] Rs2,
    output FwdA,
    output FwdB
    );
    assign FwdA = (Rs1 == WriteRegMEM) & RegWriteMEM;
    assign FwdB = (Rs2 == WriteRegMEM) & RegWriteMEM;
endmodule

