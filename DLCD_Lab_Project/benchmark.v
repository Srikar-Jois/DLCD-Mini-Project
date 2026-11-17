`timescale 1ns/1ps
module tb_mips_benchmark;
    reg clk = 0;
    reg reset = 1;
    integer i;
    integer start_cycle, end_cycle, start_instr, end_instr;
    integer elapsed_cycles, elapsed_instr;
    real cpi, ipc, avg_latency_ns, throughput_mips;

    mips_multicycle dut(.clk(clk), .reset(reset));
    always #5 clk = ~clk; // 100 MHz => 10 ns clock period

    initial begin
        $dumpfile("benchmark.vcd");
        $dumpvars(0, tb_mips_benchmark);

        // Clear memory and registers after module initialization.
        for (i=0; i<64; i=i+1) begin
            dut.imem[i] = 32'h00000000;
            dut.dmem[i] = 32'h00000000;
        end

        // Build a benchmark program: initialize values, then repeat
        // a mix of arithmetic, memory, and branch instructions.
        dut.imem[0] = 32'h20080001; // addi $t0,$zero,1
        dut.imem[1] = 32'h20090002; // addi $t1,$zero,2
        dut.imem[2] = 32'hAC080000; // sw $t0,0($zero)
        dut.imem[3] = 32'h8C0A0000; // lw $t2,0($zero)
        dut.imem[4] = 32'h01095020; // add $t2,$t0,$t1
        dut.imem[5] = 32'h01285822; // sub $t3,$t1,$t0
        dut.imem[6] = 32'h01097024; // and $t6,$t0,$t1
        dut.imem[7] = 32'h01097825; // or $t7,$t0,$t1
        dut.imem[8] = 32'h0109802A; // slt $s0,$t0,$t1
        dut.imem[9] = 32'h118A0001; // beq $t4,$t2,+1
        dut.imem[10] = 32'h200D0063; // addi $t5,$zero,99 (may be skipped)
        // Fill remaining memory with ADD $t2,$t0,$t1.
        for (i=11; i<64; i=i+1)
            dut.imem[i] = 32'h01095020;

        // Release reset cleanly and establish counter baseline.
        repeat (2) @(posedge clk);
        #1 reset = 0;
        @(posedge clk);
        #1;
        start_cycle = dut.cycle_count;
        start_instr = dut.instr_count;

        // Run a fixed measurement interval.
        repeat (300) @(posedge clk);
        #1;
        end_cycle = dut.cycle_count;
        end_instr = dut.instr_count;

        elapsed_cycles = end_cycle - start_cycle;
        elapsed_instr = end_instr - start_instr;

        cpi = (elapsed_instr > 0) ? real'(elapsed_cycles) / real'(elapsed_instr) : 0.0;
        ipc = (elapsed_cycles > 0) ? real'(elapsed_instr) / real'(elapsed_cycles) : 0.0;
        avg_latency_ns = cpi * 10.0;
        throughput_mips = ipc * 100.0; // 100 MHz clock

        $display("\\n======= MULTICYCLE MIPS BENCHMARK =======");
        $display("Clock frequency       : 100 MHz");
        $display("Measurement cycles    : %0d", elapsed_cycles);
        $display("Instructions completed: %0d", elapsed_instr);
        $display("CPI                   : %0.3f", cpi);
        $display("IPC                   : %0.3f", ipc);
        $display("Avg completion latency: %0.2f ns/instruction", avg_latency_ns);
        $display("Throughput             : %0.3f MIPS", throughput_mips);
        $display("=========================================\\n");
        $finish;
    end

    initial begin
        #5000;
        $display("ERROR: benchmark timeout");
        $finish;
    end
endmodule
