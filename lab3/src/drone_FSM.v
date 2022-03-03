`define DISARMED 3'd0
`define ARMED 3'd1
`define TAKEOFF 3'd2
`define NAVIGATE 3'd3
`define LAND 3'd4
module droneFSM(
    input reset, clk, armCmd, disarmCmd, takeoffCmd, taskComplete, sensorError,
    output motor, [1:0] led
    );
    // Internal state variables
    reg [2:0] state;
    reg [2:0] nextState;
    // Combinational assignments for output logic
    assign motor = |state;
    assign led = {state>2,(state == `TAKEOFF | state == `LAND)};
    // Combinational block for next-state logic
    always @(*) begin
        case (state)
            `DISARMED: begin
                if (armCmd && !sensorError)
                    nextState = `ARMED;
                else
                    nextState = `DISARMED;
            end
            `ARMED: begin
                if (takeoffCmd)
                    nextState = `TAKEOFF;
                else
                    nextState = `ARMED;
            end
            `TAKEOFF: begin
                if (taskComplete)
                    nextState = `NAVIGATE;
                else
                    nextState = `TAKEOFF;
            end
            `NAVIGATE: begin
                if (taskComplete || sensorError)
                    nextState = `LAND;
                else
                    nextState = `NAVIGATE;
            end
            `LAND: begin
                if (taskComplete) begin
                    if (sensorError)
                        nextState = `DISARMED;
                    else
                        nextState = `ARMED;
                end
                else
                    nextState = `LAND;
            end
            default: nextState = state;
        endcase
    end
// Sequential block for state transitions
always @(posedge clk) begin
if (reset) begin
state <= `DISARMED;
end else begin
state <= nextState;
end
end
endmodule