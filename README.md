# DLCD Projects

A collection of two Digital Logic and Computer Design (DLCD) projects implemented in Verilog:

1. **Theory Mini-Project – K-map-Based Traffic Light Controller**
2. **Lab Project – Multicycle MIPS Processor and Performance Benchmark**

Both projects include synthesizable/RTL Verilog, simulation testbenches, and waveform outputs. The theory project demonstrates finite-state-machine design from Boolean minimization. The lab project demonstrates a small multicycle MIPS-like processor, instruction execution across multiple clock cycles, and basic performance measurement.

---

## Repository structure

```text
DLCD/
├── README.md
├── DLCD_Theory_Project/
│   ├── README.md
│   ├── DLCD_Mini-Project-Theory_Section_I-Team_5.pdf
│   ├── traffic_light_fsm.v
│   ├── tb_traffic_light_fsm.v
│   ├── traffic_light.vcd
│   └── traffic_light_sim
└── DLCD_Lab_Project/
    ├── README.md
    ├── multicyclemips.v
    ├── tb_mips_multicycle.v
    ├── benchmark.v
    ├── mips_multicycle.vcd
    ├── benchmark.vcd
    ├── demo.out
    └── benchmark.out
```

> The `.vcd` files are simulation waveforms. The `.out` files are compiled simulation executables, not source code. The PDF contains the theory mini-project report. The `README.md` files explain the designs and how to run them.

## Requirements

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) (`iverilog` and `vvp`) to compile and run simulations.
- [GTKWave](https://gtkwave.sourceforge.net/) to inspect waveform files (optional).
- A terminal with access to the project directories.

### Install

**Ubuntu/Debian**
```bash
sudo apt update
sudo apt install iverilog gtkwave
```

**macOS with Homebrew**
```bash
brew install icarus-verilog gtkwave
```

Check that the tools are available:
```bash
iverilog -V
vvp -V
gtkwave --version
```

---

## Project 1 – Theory: Traffic Light Controller

A three-state Moore finite-state machine cycles through:

```text
RED → GREEN → YELLOW → RED → ...
```

The state is stored in two flip-flops. Its next-state equations are derived using 2-variable Karnaugh maps and implemented directly in Verilog. The design uses a synchronous, active-high reset.

**Main source:** `DLCD_Theory_Project/traffic_light_fsm.v`  
**Testbench:** `DLCD_Theory_Project/tb_traffic_light_fsm.v`

See [`DLCD_Theory_Project/README.md`](DLCD_Theory_Project/README.md) for the full derivation, state diagram, equations, implementation walkthrough and simulation instructions.

### Run
```bash
cd DLCD_Theory_Project
iverilog -g2012 -Wall -s tb_traffic_light_fsm -o traffic_light_sim traffic_light_fsm.v tb_traffic_light_fsm.v
vvp traffic_light_sim
```

Expected result: PASS messages for reset/RED, GREEN, YELLOW and RED across two complete cycles, followed by `ALL TESTS PASSED`.

---

## Project 2 – Lab: Multicycle MIPS Processor

A teaching implementation of a multicycle MIPS-like processor. Instruction execution is divided into stages controlled by a finite-state machine. The processor supports a subset of MIPS instructions:

- Arithmetic/logical R-type: `ADD`, `SUB`, `AND`, `OR`, `SLT`
- Immediate arithmetic: `ADDI`
- Memory: `LW`, `SW`
- Control flow: `BEQ`

The processor contains 32 registers, 64 words of instruction memory, 64 words of data memory, a program counter, instruction register, temporary datapath registers, and cycle/instruction counters.

**Main source:** `DLCD_Lab_Project/multicyclemips.v`  
**Functional testbench:** `DLCD_Lab_Project/tb_mips_multicycle.v`  
**Benchmark testbench:** `DLCD_Lab_Project/benchmark.v`

See [`DLCD_Lab_Project/README.md`](DLCD_Lab_Project/README.md) for the processor architecture, state-by-state operation, instruction formats, program walkthrough, performance formulas, limitations and commands.

### Run the functional demonstration
```bash
cd DLCD_Lab_Project
iverilog -g2012 -o demo.out multicyclemips.v tb_mips_multicycle.v
vvp demo.out
```

### Run the performance benchmark
```bash
iverilog -g2012 -o benchmark.out multicyclemips.v benchmark.v
vvp benchmark.out
```

The benchmark reports elapsed cycles, completed instructions, CPI, IPC, average completion spacing and throughput. It is a custom educational benchmark, **not** an official SPEC CPU benchmark.

---

## Viewing waveforms

Run the relevant simulation first, then open the generated waveform:

```bash
# Traffic light
gtkwave traffic_light.vcd

# MIPS functional demonstration
gtkwave mips_multicycle.vcd

# MIPS benchmark
gtkwave benchmark.vcd
```

Useful signals:

| Project | Signals to inspect |
|---|---|
| Traffic light | `clk`, `reset`, `dut.state`, `red`, `green`, `yellow` |
| MIPS | `clk`, `reset`, `dut.pc`, `dut.ir`, `dut.state`, `dut.regs`, `dut.dmem`, `dut.cycle_count`, `dut.instr_count` |

---

## Concepts demonstrated

| Concept | Traffic light project | MIPS project |
|---|---|---|
| Sequential logic | 2-bit state register | PC, IR, datapath and register file |
| Combinational logic | K-map-derived next-state and output equations | ALU operations, decode and address calculations |
| FSM | Three-state Moore FSM | Multicycle control FSM |
| Reset | Synchronous, active-high | Asynchronous, active-high |
| Verification | Output sequence checking | Program execution and result inspection |
| Performance | Not measured | CPI, IPC, latency and throughput |

## Important scope notes

- The traffic-light design is a three-state controller, not a complete real-world traffic intersection controller with pedestrian phases or timing delays.
- The MIPS processor implements only the instruction subset listed above. It is an educational model, not a complete MIPS ISA implementation.
- The MIPS memories each contain 64 32-bit words. The RTL uses word-aligned indexing through address bits `[7:2]`.
- The MIPS benchmark is a fixed simulation workload designed for this processor. Its figures should not be compared directly with official processor benchmark scores.
