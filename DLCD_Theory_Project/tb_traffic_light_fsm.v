`timescale 1ns/1ps

module tb_traffic_light_fsm;
    reg clk = 0;
    reg reset = 0;
    wire red, green, yellow;

    traffic_light_fsm dut (
        .clk(clk), .reset(reset),
        .red(red), .green(green), .yellow(yellow)
    );

    always #5 clk = ~clk;

    task check_output;
        input expected_red;
        input expected_green;
        input expected_yellow;
        input [8*16-1:0] label;
        begin
            #1;
            if ({red,green,yellow} !==
                {expected_red,expected_green,expected_yellow}) begin
                $display("FAIL at %0t: %0s expected RGY=%b%b%b got %b%b%b",
                    $time, label, expected_red,expected_green,expected_yellow,
                    red,green,yellow);
                $fatal(1);
            end
            $display("PASS at %0t: %0s RGY=%b%b%b",
                $time, label, red,green,yellow);
        end
    endtask

    integer i;
    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light_fsm);

        // Assert synchronous reset across a rising edge.
        reset = 1;
        @(posedge clk);
        check_output(1,0,0,"reset -> RED");
        @(negedge clk);
        reset = 0;

        // Two full RED-GREEN-YELLOW cycles. State advances on each posedge.
        for (i = 0; i < 2; i = i + 1) begin
            check_output(1,0,0,"RED");
            @(posedge clk); check_output(0,1,0,"GREEN");
            @(posedge clk); check_output(0,0,1,"YELLOW");
            @(posedge clk); check_output(1,0,0,"RED");
            @(negedge clk);
        end

        $display("ALL TESTS PASSED: two complete traffic-light cycles.");
        $finish;
    end
endmodule
