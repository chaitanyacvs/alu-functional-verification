# ALU Functional Verification using SystemVerilog

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-orange)
![Verification](https://img.shields.io/badge/Verification-Assertions%20%7C%20UVM-purple)

A hardware verification project focused on validating an Arithmetic Logic Unit (ALU) using SystemVerilog, simulation-based testing, assertions, scoreboard checking, functional coverage, and bug-injection testing.

## Overview

This project provides a verification environment for an ALU implementation. It checks supported operations, arithmetic corner cases, status flags, and invalid opcodes.

The environment includes self-checking testbenches, a reference model and scoreboard, assertion-related files, a separate bug-detection flow, and a UVM component structure for further development.

The goal is to improve confidence in RTL functionality through reproducible tests, automated execution, and inspectable verification results.

## Key Features

- **Self-checking verification:** Compares actual ALU outputs with expected results.
- **Reference model and scoreboard:** Detects functional mismatches.
- **Assertion-based verification:** Uses SystemVerilog assertion-related source files to check design properties.
- **Functional coverage tracking:** Records opcode execution and selected result and flag conditions.
- **Arithmetic corner cases:** Exercises carry, overflow, borrow, and zero-result behavior.
- **Invalid opcode testing:** Tests unsupported opcode values.
- **Bug-injection testing:** Evaluates whether the testbench detects an intentionally introduced functional error.
- **UVM components:** Includes driver, monitor, sequence, sequencer, transaction, environment, and scoreboard-related files.
- **Simulation automation:** Uses shell scripts to compile and run tests.
- **Result preservation:** Organizes simulation logs and reports.

## Verification Architecture

```text
              SystemVerilog Testbench
                        |
                Stimulus Generation
                        |
                        v
                    ALU DUT
                        |
                        v
                  Actual Outputs
                        |
                        v
              Reference Model / Scoreboard
                        |
                        v
               Comparison and Assertions
                        |
                        v
                Coverage and Results
                        |
                        v
                   PASS / FAIL
```

A separate bug-injection flow evaluates the ability of the verification environment to detect functional errors.

## Repository Structure

```text
uvm-alu-verification/
├── rtl/
│   ├── alu.sv
│   └── alu_buggy.sv
├── tb/
│   ├── tb_alu.sv
│   └── tb_bug_detection.sv
├── tests/
│   ├── tb_alu.sv
│   └── tb_bug_detection.sv
├── assertions/
│   ├── alu_assertions.sv
│   └── tb_alu_sva.sv
├── uvm/
│   ├── agent/
│   ├── env/
│   ├── sequences/
│   ├── tests/
│   ├── alu_driver.sv
│   ├── alu_if.sv
│   ├── alu_monitor.sv
│   ├── alu_scoreboard.sv
│   ├── alu_sequence.sv
│   ├── alu_sequencer.sv
│   └── alu_transaction.sv
├── scripts/
│   ├── run.sh
│   └── run_bug_test.sh
├── reports/
│   └── last_run.log
├── results/
│   ├── README.md
│   ├── alu_simulation.log
│   ├── alu_sva.log
│   └── bug_detection.log
└── README.md
```

_The tree summarizes the structure shown in the repository. Confirm exact filenames and directory contents before relying on this list; the `agent/`, `env/`, `sequences/`, and `tests/` subdirectories may contain additional files._

## Tools and Technologies

| Tool                           | Purpose                                               |
| ------------------------------ | ----------------------------------------------------- |
| SystemVerilog                  | RTL and verification development                      |
| Icarus Verilog                 | Compilation and simulation                            |
| VVP                            | Execution of compiled simulations                     |
| SystemVerilog Assertions (SVA) | Checking specified design properties                  |
| UVM                            | Reusable, transaction-based verification architecture |
| Bash                           | Regression automation                                 |
| Git and GitHub                 | Version control and project hosting                   |

## Getting Started

### Prerequisites

Install Icarus Verilog and ensure `iverilog` and `vvp` are available.

```bash
iverilog -V
vvp -V
```

### Clone the Repository

```bash
git clone <your-repository-url>
cd uvm-alu-verification
```

Replace `<your-repository-url>` with the actual GitHub URL.

## Running Simulation Tests

Run the primary ALU simulation regression:

```bash
chmod +x scripts/run.sh
./scripts/run.sh
```

The script should compile the configured RTL and testbench files, execute the simulation, and report the test outcome.

## Running Bug-Detection Tests

Run the separate bug-injection flow:

```bash
chmod +x scripts/run_bug_test.sh
./scripts/run_bug_test.sh
```

Review the output to determine whether the injected fault was detected. A valid bug-detection result should demonstrate that the testbench identifies the intended error, rather than merely reporting a compilation or runtime failure.

## Inspecting Assertion and Simulation Results

The repository includes the following result files, as shown in the project structure:

```bash
cat results/alu_simulation.log
cat results/alu_sva.log
cat results/bug_detection.log
```

These files can be used to inspect the recorded simulation, assertion, and bug-detection outcomes. Confirm their contents before reporting a passing result.

## Assertion-Based Verification

The `assertions/` directory contains assertion-related source files.

Assertions can check properties such as:

- Correct ALU output for supported operations.
- Expected status-flag behavior.
- Consistency between inputs, opcode, and outputs.
- Defined behavior for invalid opcodes.

The actual properties and their pass/fail status depend on the assertions implemented and the simulation or formal flow used to evaluate them.

## UVM Verification Environment

The `uvm/` directory contains components associated with a transaction-based verification environment, including a driver, monitor, sequencer, sequence, transaction, interface, and scoreboard.

These components provide a foundation for a reusable UVM testbench. UVM execution requires a compatible SystemVerilog simulator and an appropriate UVM library and test configuration. Icarus Verilog alone should not be assumed to support the complete UVM environment.

## Functional Coverage and Recorded Results

The supplied project description reports the following observations from a recorded scoreboard run:

| Metric                       | Recorded count |
| ---------------------------- | -------------: |
| Total opcode observations    |          1,020 |
| Zero-result observations     |            451 |
| Non-zero-result observations |            569 |
| ADD carry observations       |             35 |
| ADD overflow observations    |             16 |
| SUB borrow observations      |             32 |
| SUB overflow observations    |             12 |

The recorded scoreboard message was:

```text
PASS: ALU scoreboard verification passed
```

These values are observations from the supplied run, not proof of exhaustive input coverage. Re-run the regression and check the current logs before treating these numbers as the latest results.

Evaluate the bug-detection outcome and assertion results independently from the main scoreboard regression.

## Engineering Practices

- Keep RTL, testbenches, assertions, and UVM components organized separately.
- Automate repeatable verification runs.
- Preserve logs that support reported outcomes.
- Add regression tests when bugs are discovered.
- Document unsupported behaviors and verification limitations.
- Distinguish simulation success from formal proof and UVM execution.

## Future Improvements

- Expand directed and constrained-random testing.
- Add assertions for additional functional properties.
- Improve coverage tracking and coverage closure.
- Complete and run the UVM environment using a compatible simulator.
- Add continuous integration for automated regression testing.
- Expand fault injection and measure fault-detection effectiveness.
- Archive simulation and assertion reports for reproducibility.

## Conclusion

This project demonstrates practical ALU verification using SystemVerilog, self-checking testbenches, scoreboard-based checking, assertions, and simulation automation. Its bug-injection flow provides an additional way to evaluate verification effectiveness, while the UVM structure supports further development toward reusable, transaction-based
