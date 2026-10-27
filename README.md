# ALU Verification Starter

![Language](https://img.shields.io/badge/HDL-SystemVerilog-blue)
![Simulator](https://img.shields.io/badge/sim-Icarus%20Verilog-green)
![Width](https://img.shields.io/badge/datapath-32--bit-informational)
![UVM](https://img.shields.io/badge/UVM-needs%20Questa%2FVCS%2FXcelium-orange)

A starter project for a 32-bit combinational ALU, built for **VS Code + Icarus Verilog**. It includes the RTL and a self-checking testbench that runs in one command.

> **UVM note:** Icarus Verilog does not support the full class-based UVM environment. This starter runs the RTL and a self-checking testbench first. A UVM-capable simulator (Questa, VCS, or Xcelium) is needed for the complete UVM phase.

---

## Table of Contents
1. [Features](#features)
2. [Repository Layout](#repository-layout)
3. [Operations](#operations)
4. [Flag Semantics](#flag-semantics)
5. [Quick Start](#quick-start)
6. [Verification Plan](#verification-plan)
7. [Project Phases](#project-phases)
8. [Troubleshooting](#troubleshooting)
9. [Limitations](#limitations)
10. [Roadmap](#roadmap)
11. [Status](#status)

---

## Features
- 32-bit combinational ALU with 10 defined operations (arithmetic, logic, shifts, comparisons)
- Status flags: `zero`, `carry`, `overflow`
- Icarus-compatible self-checking testbench with a PASS/FAIL summary line
- One-command run script (`scripts/run.sh`)
- Directory structure already reserved for UVM, assertions, and extra tests

## Repository Layout

| Path             | Purpose                                         | Phase    |
|------------------|-------------------------------------------------|----------|
| `rtl/alu.sv`     | ALU RTL                                         | Active   |
| `tb/tb_alu.sv`   | Icarus-compatible self-checking testbench       | Active   |
| `scripts/run.sh` | Compile and execute                             | Active   |
| `uvm/`           | UVM environment (needs Questa/VCS/Xcelium)      | Reserved |
| `assertions/`    | SVA properties / bind files                     | Reserved |
| `tests/`         | Additional directed and regression tests        | Reserved |

```text
rtl/
  alu.sv
tb/
  tb_alu.sv
scripts/
  run.sh
uvm/          # reserved
assertions/   # reserved
tests/        # reserved
```

## Operations
<<<<<<< HEAD
=======

- `0`: ADD
- `1`: SUB
- `2`: AND
- `3`: OR
- `4`: XOR
- `5`: SLL
- `6`: SRL
- `7`: SRA
- `8`: SLT (signed)
- `9`: SLTU (unsigned)
- Other opcodes return zero.
>>>>>>> 7f20f60 (Update ALU verification documentation)

| Opcode | Mnemonic | Description                          |
|:------:|----------|--------------------------------------|
| `0`    | ADD      | Addition                             |
| `1`    | SUB      | Subtraction                          |
| `2`    | AND      | Bitwise AND                          |
| `3`    | OR       | Bitwise OR                           |
| `4`    | XOR      | Bitwise XOR                          |
| `5`    | SLL      | Shift left logical                   |
| `6`    | SRL      | Shift right logical                  |
| `7`    | SRA      | Shift right arithmetic               |
| `8`    | SLT      | Set if less than (signed)            |
| `9`    | SLTU     | Set if less than (unsigned)          |
| other  | n/a      | Returns zero                         |

<<<<<<< HEAD
> Port names, opcode width, and the shift-amount source (commonly `b[4:0]`) are not stated in the original README. Document them here after confirming against `rtl/alu.sv`.

## Flag Semantics

| Flag       | Meaning                                                                          |
|------------|----------------------------------------------------------------------------------|
| `zero`     | Result is zero                                                                   |
| `carry`    | **ADD:** carry-out. **SUB:** `1` when there is no unsigned borrow. **Other ops:** cleared |
| `overflow` | Signed overflow on ADD/SUB. **Other ops:** cleared                               |

Per-operation behavior:

| Operation        | `zero`        | `carry`   | `overflow`      |
|------------------|---------------|-----------|-----------------|
| ADD              | `result == 0` | carry-out | signed overflow |
| SUB              | `result == 0` | no borrow | signed overflow |
| Logic ops        | `result == 0` | 0         | 0               |
| Shifts           | `result == 0` | 0         | 0               |
| SLT / SLTU       | `result == 0` | 0         | 0               |
| Undefined opcode | 1             | 0         | 0               |

## Quick Start

**Prerequisite:** Icarus Verilog with SystemVerilog support (`-g2012`).

```bash
# macOS (Homebrew)
brew install icarus-verilog
```

**Run manually:**
=======
## Run on macOS

>>>>>>> 7f20f60 (Update ALU verification documentation)
```bash
iverilog -g2012 -s tb_alu -o /tmp/alu_sim rtl/alu.sv tb/tb_alu.sv
vvp /tmp/alu_sim
```
<<<<<<< HEAD
=======

Or run `./scripts/run.sh`.
>>>>>>> 7f20f60 (Update ALU verification documentation)

**Or use the helper script:**
```bash
./scripts/run.sh
```

<<<<<<< HEAD
**Expected final line:**
```text
PASS: all ALU tests passed
```

If the final line is anything else, treat the run as a failure, even if the process exits cleanly.

## Verification Plan

Corner cases worth covering:

| Area        | Case                                                                         |
|-------------|------------------------------------------------------------------------------|
| ADD         | `0x7FFFFFFF + 1` (overflow), `0xFFFFFFFF + 1` (carry, zero result)           |
| SUB         | `0x80000000 - 1` (overflow), `0 - 1` (borrow, carry = 0), `a - a` (carry = 1) |
| Shifts      | Shift by 0, 1, 31; SRA vs SRL on a negative value                            |
| SLT vs SLTU | `0xFFFFFFFF` vs `1` differs between signed and unsigned                      |
| Logic       | All-zeros, all-ones, `0xAAAAAAAA`, `0x55555555`                              |
| Flags       | Carry/overflow cleared on every non-ADD/SUB op                               |
| Opcodes     | Every opcode above `9` returns zero with flags cleared                       |

## Project Phases

| Phase | Scope                                              | Location       | Tooling                     | State        |
|:-----:|----------------------------------------------------|----------------|-----------------------------|--------------|
| 1     | RTL + self-checking testbench                      | `rtl/`, `tb/`  | Icarus Verilog              | Active       |
| 2     | Assertions on ALU behavior and flags               | `assertions/`  | Simulator with SVA support  | Reserved     |
| 3     | Extended directed and regression tests             | `tests/`       | Icarus Verilog              | Reserved     |
| 4     | Class-based UVM environment                        | `uvm/`         | Questa, VCS, or Xcelium     | Reserved     |

UVM progression: interface, then transaction/sequencer/driver/monitor, then scoreboard (reuse the testbench reference model), then constrained-random sequences and functional coverage.

## Troubleshooting

| Symptom                                 | Likely cause / fix                                         |
|-----------------------------------------|------------------------------------------------------------|
| `iverilog: command not found`           | Install Icarus Verilog                                     |
| Errors on `logic` / `always_comb`       | Missing `-g2012` flag                                      |
| Top-level module not found              | Check `-s tb_alu` matches the testbench module name        |
| `vvp` prints nothing                    | Confirm the testbench calls `$display` and reaches `$finish` |
| `Permission denied` on script           | `chmod +x scripts/run.sh`                                  |
| SV feature unsupported                  | Icarus supports a subset of SV; keep RTL/TB constructs simple |

## Limitations
- Combinational design only; no clocking or timing is verified.
- Icarus Verilog cannot run class-based UVM, so `uvm/` is not runnable in this starter.
- Only the 10 listed operations are defined; all other opcodes return zero.
- Passing simulation shows the tested vectors pass; it does not prove correctness for all inputs.

## Roadmap
- [ ] Populate `assertions/` with flag and opcode properties
- [ ] Populate `tests/` with directed corner cases and a seeded random regression
- [ ] Exhaustive check on a reduced-width parameterization (e.g. 8-bit)
- [ ] Build the UVM environment in `uvm/` for Questa/VCS/Xcelium
- [ ] Add functional coverage (opcodes, flags, operand sign combinations)
- [ ] CI job running `./scripts/run.sh`

## Status
Phase 1 is active: the RTL and self-checking testbench run under Icarus Verilog and should end with `PASS: all ALU tests passed`. `uvm/`, `assertions/`, and `tests/` are reserved for later phases.
=======
## Layout

- `rtl/alu.sv`: ALU RTL
- `tb/tb_alu.sv`: Icarus-compatible self-checking testbench
- `uvm/`, `assertions/`, `tests/`: reserved for next phases
- `scripts/run.sh`: compile and execute

## Verification Results

### Test environment

- RTL and testbench: SystemVerilog
- Simulator: Icarus Verilog
- Regression command: `./scripts/run.sh`
- Bug-injection command: `./scripts/run_bug_test.sh`

### Normal regression

- Transactions checked: 1,020
- Scoreboard errors: 0
- Valid ALU opcodes exercised: 10/10
- Invalid opcodes exercised: 6/6
- Result and arithmetic-flag checks included

### Bug-injection test

An intentional XOR implementation defect was introduced in a separate ALU variant by replacing XOR with OR. The dedicated test detected the mismatch and passed the bug-detection check.

### Key verification concepts demonstrated

- Reference-model-based checking
- Self-checking testbench and scoreboard
- Directed and randomized stimulus
- Opcode and result/flag coverage counters
- Bug injection and regression automation

### Limitations and future work

This project currently uses a procedural SystemVerilog testbench. It is not yet a class-based UVM environment and does not currently report standards-based functional coverage percentages. Future work includes SystemVerilog assertions, improved constrained-random stimulus, and a UVM environment using a compatible simulator.
>>>>>>> 7f20f60 (Update ALU verification documentation)
