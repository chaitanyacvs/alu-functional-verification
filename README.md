# ALU Functional Verification using SystemVerilog

A simulation-driven RTL verification project for an Arithmetic Logic Unit (ALU), built using SystemVerilog and Icarus Verilog. The project focuses on functional correctness, self-checking testbenches, coverage tracking, bug detection, and reproducible simulation results.

## Overview

This repository contains an ALU RTL implementation and a verification environment designed to check its behavior across supported operations, arithmetic corner cases, status flags, and invalid opcodes.

The testbench compares the DUT output against expected behavior using a reference model and scoreboard. A separate bug-detection testbench exercises a deliberately modified ALU implementation to demonstrate the ability of the verification environment to identify functional errors.

## Key Features

- **Self-checking verification:** Compares DUT outputs against expected results.
- **Scoreboard-based checking:** Detects mismatches between expected and actual outputs.
- **Functional coverage tracking:** Records opcode execution and selected result and flag conditions.
- **Arithmetic corner-case testing:** Checks carry, overflow, borrow, and zero-result behavior.
- **Invalid opcode testing:** Exercises unsupported opcode values.
- **Bug-injection testing:** Uses a modified ALU implementation to evaluate whether the testbench detects injected functional errors.
- **Automated simulation:** Shell scripts compile and run tests using Icarus Verilog.
- **Saved verification evidence:** Simulation logs and result summaries are maintained in the repository.

## Verification Architecture

```text
        SystemVerilog Testbench
                  |
          Stimulus Generation
                  |
                  v
          ALU RTL (DUT)
                  |
                  v
           Actual Outputs
                  |
                  v
       Reference Model / Scoreboard
                  |
                  v
       Checks + Coverage Counters
                  |
                  v
         PASS / FAIL + Logs
```

A separate bug-detection flow runs the modified ALU against the verification testbench to check whether injected errors are detected.

## Repository Structure

```text
alu-functional-verification/
├── rtl/
│   ├── alu.sv
│   └── alu_buggy.sv
├── tb/
│   ├── tb_alu.sv
│   └── tb_bug_detection.sv
├── tests/
│   ├── tb_alu.sv
│   └── tb_bug_detection.sv
├── scripts/
│   ├── run.sh
│   └── run_bug_test.sh
├── results/
│   ├── README.md
│   ├── alu_simulation.log
│   └── bug_detection.log
├── assertions/
├── uvm/
└── README.md
```

The `tb/` directory contains the primary testbenches, while `tests/` contains the test files organized for the verification workflow. The `assertions/` and `uvm/` directories are reserved for further development unless additional implementations are added.

## Tools and Technologies

| Tool / Technology           | Purpose                             |
| --------------------------- | ----------------------------------- |
| SystemVerilog               | RTL and testbench implementation    |
| Icarus Verilog (`iverilog`) | Compilation and simulation          |
| `vvp`                       | Simulation execution                |
| Bash                        | Automated test execution            |
| Git and GitHub              | Version control and project hosting |

## How to Run

### Prerequisites

Install Icarus Verilog and ensure that both `iverilog` and `vvp` are available in your terminal.

Verify the installation:

```bash
iverilog -V
vvp -V
```

### 1. Run the ALU functional regression

From the repository root:

```bash
chmod +x scripts/run.sh
./scripts/run.sh
```

The script compiles the design and testbench, executes the simulation, and reports verification results.

A successful scoreboard run should end with:

```text
PASS: ALU scoreboard verification passed
```

### 2. Run the bug-detection test

```bash
chmod +x scripts/run_bug_test.sh
./scripts/run_bug_test.sh
```

Inspect the output to confirm that the injected fault is detected. The exact expected message depends on the behavior implemented in the script and testbench.

### 3. Inspect saved results

```bash
cat results/alu_simulation.log
cat results/bug_detection.log
```

These logs provide evidence of the recorded simulation outcomes.

## Functional Coverage and Results

The main ALU regression tracks opcode counts and selected result and arithmetic-flag conditions.

In the recorded scoreboard run:

| Metric                       | Recorded count |
| ---------------------------- | -------------: |
| Total opcode observations    |          1,020 |
| Zero-result observations     |            451 |
| Non-zero-result observations |            569 |
| ADD carry observations       |             35 |
| ADD overflow observations    |             16 |
| SUB borrow observations      |             32 |
| SUB overflow observations    |             12 |

The scoreboard reported:

```text
PASS: ALU scoreboard verification passed
```

The opcode counters include valid and invalid opcode values. The counts above represent observations from the recorded run, not percentages of exhaustive input-space coverage.

See [`results/alu_simulation.log`](results/alu_simulation.log) for the recorded simulation output. The bug-detection outcome should be evaluated separately using [`results/bug_detection.log`](results/bug_detection.log).

## Engineering Highlights

- Developed a self-checking SystemVerilog testbench with reference-model comparison.
- Used scoreboard checks to detect functional mismatches.
- Tracked opcode execution and arithmetic status conditions.
- Exercised invalid opcode inputs and arithmetic corner cases.
- Created a separate bug-injection regression to evaluate fault detection.
- Automated compilation and simulation through shell scripts.
- Preserved test logs for repeatability and debugging.

## Future Improvements

- Expand directed and constrained-random testing.
- Add SystemVerilog Assertions (SVA) for important functional properties.
- Integrate functional coverage into a more comprehensive coverage model.
- Develop a reusable UVM environment with sequencer, driver, monitor, agent, and scoreboard components.
- Add CI automation to execute regressions on every push.
- Extend fault injection and measure detection effectiveness.

## Conclusion

This project demonstrates practical RTL functional verification using SystemVerilog, self-checking testbenches, scoreboard-based checking, coverage counters, and simulation automation. It also explores verification quality through a separate bug-injection test flow and preserves simulation logs to make results inspectable and reproducible.
