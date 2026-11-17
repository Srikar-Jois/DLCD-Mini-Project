`timescale 1ns/1ps

module traffic_light_fsm (
    input  wire clk,
    input  wire reset,       // synchronous, active high
    output wire red,
    output wire green,
    output wire yellow
);
    reg [1:0] state;
    wire S1 = state[1];
    wire S0 = state[0];

    wire D1 = S0;
    wire D0 = ~S1 & ~S0;

    always @(posedge clk) begin
        if (reset)
            state <= 2'b00;
        else
            state <= {D1, D0};
    end

    assign red    = ~S1 & ~S0;
    assign green  = ~S1 &  S0;
    assign yellow =  S1 & ~S0;
endmodule
