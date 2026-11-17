DLCD LEVEL-2 — PROBLEM 1
Traffic Light Controller Built from K-map-Derived Flip-Flop Equations
=====================================================================

Files
-----
traffic_light_fsm.v      Synthesizable FSM module
tb_traffic_light_fsm.v   Simulation testbench

State encoding
-------------
RED    = 00
GREEN  = 01
YELLOW = 10
11     = unused (K-map don't-care)

K-map minimized next-state equations
-----------------------------------
D1 = S0
D0 = ~S1 & ~S0

Moore output equations
---------------------
red    = ~S1 & ~S0
green  = ~S1 & S0
yellow = S1 & ~S0

The FSM uses a plain 2-bit state register and these equations. There is no
case statement. Reset is synchronous and active-high.

Compile and run (Icarus Verilog)
--------------------------------
Run these commands in this directory:

    iverilog -g2012 -Wall -s tb_traffic_light_fsm -o traffic_light_sim traffic_light_fsm.v tb_traffic_light_fsm.v
    vvp traffic_light_sim

Expected: PASS messages for reset/RED, GREEN, YELLOW, and RED across two
complete cycles, followed by "ALL TESTS PASSED".

View waveform
-------------
The simulation creates traffic_light.vcd. Open it with GTKWave:

    gtkwave traffic_light.vcd

Suggested signals: clk, reset, dut.state, red, green, yellow.

Compile design only (no testbench)
---------------------------------
    iverilog -g2012 -Wall -s traffic_light_fsm -o traffic_light_design traffic_light_fsm.v

Note: The testbench is for simulation and is not part of the synthesizable design.
