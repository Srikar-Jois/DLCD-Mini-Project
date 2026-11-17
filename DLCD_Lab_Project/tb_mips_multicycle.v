`timescale 1ns/1ps
module tb_mips_multicycle;
    reg clk = 0;
    reg reset = 1;
    integer i;

    mips_multicycle dut(.clk(clk), .reset(reset));

    always #5 clk = ~clk; // 100 MHz clock (10 ns period)

    initial begin
        $dumpfile("mips_multicycle.vcd");
        $dumpvars(0, tb_mips_multicycle);

        // Release reset after two clock edges
        repeat (2) @(posedge clk);
        #1 reset = 0;

        // Wait until the demonstration program has completed.
        // 11 instructions; the skipped ADDI is not executed.
        wait (dut.instr_count == 10);
        @(posedge clk);
        #1;

        $display("\\n===== DEMO RESULTS =====");
        for (i=0; i<32; i=i+1)
            if (dut.regs[i] !== 0)
                $display("R[%0d] = %0d (0x%08h)", i, dut.regs[i], dut.regs[i]);
        $display("dmem[0] = %0d", dut.dmem[0]);
        $display("Completed instructions = %0d", dut.instr_count);
        $display("Clock cycles since reset = %0d", dut.cycle_count);
        $display("========================\\n");
        $finish;
    end

    initial begin
        #2000;
        $display("ERROR: timeout waiting for program completion");
        $finish;
    end
endmodule
