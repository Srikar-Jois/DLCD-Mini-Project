MULTICYCLE MIPS VERILOG PROJECT
===============================

CONTENTS
--------
multicyclemips.v       Processor RTL (multicycle MIPS subset + counters)
tb_mips_multicycle.v  Testbench for the demonstration program
benchmark.v            Custom SPEC-inspired performance benchmark
README.txt             This file

REQUIREMENTS
------------
Install Icarus Verilog (iverilog and vvp).
Optional: GTKWave to view waveform files (.vcd).

Ubuntu/Debian:
    sudo apt update
    sudo apt install iverilog gtkwave

macOS (Homebrew):
    brew install icarus-verilog gtkwave

RUN THE FUNCTIONAL TEST
-----------------------
From this directory:

    iverilog -g2012 -o demo.out multicyclemips.v tb_mips_multicycle.v
    vvp demo.out

The testbench prints the nonzero registers, data memory value, and
instruction/cycle counters. It also creates mips_multicycle.vcd.

RUN THE PERFORMANCE BENCHMARK
----------------------------
From this directory:

    iverilog -g2012 -o benchmark.out multicyclemips.v benchmark.v
    vvp benchmark.out

The benchmark prints:
  * Measurement cycles
  * Completed instructions
  * CPI = cycles / completed instructions
  * IPC = completed instructions / cycles
  * Average completion spacing = CPI x clock period
  * Throughput in MIPS = IPC x clock frequency (in MHz)

The simulated clock is 100 MHz (10 ns period). This is a custom educational
benchmark inspired by workload-style processor benchmarking; it is NOT an
official SPEC CPU benchmark and does not produce official SPEC scores.

VIEW WAVEFORMS
--------------
After running either test:

    gtkwave mips_multicycle.vcd
or:
    gtkwave benchmark.vcd

IMPLEMENTED INSTRUCTIONS
-----------------------
ADDI, ADD, SUB, AND, OR, SLT, LW, SW, BEQ

NOTES
-----
- Instruction and data memories each contain 64 32-bit words.
- The processor is a teaching implementation, not a complete MIPS ISA.
- The benchmark uses a fixed cycle window and a repeated instruction stream.
- Counter values are 32-bit and wrap around after 2^32 increments.
