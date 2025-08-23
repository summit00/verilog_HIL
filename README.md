# em-fpga
This repo contains fpga based projects and build up a library with verilog modules with the longterm goal to build a HIL machine

[toc]


---

## Current Focus: Modular Verilog Library with CI

Alongside the long-term HIL motor simulation, this project is building a **growing library of foundational Verilog modules** that are:

- Modular  
- Parameterized  
- **Unit-tested** using [Icarus Verilog](http://iverilog.icarus.com/)  
- Automatically verified via **GitHub Actions CI pipeline**


### Library Modules (so far)

| Module        | Description                          | Testbench Status |
|---------------|--------------------------------------|------------------|
| `counter_sync` | N-bit up counter (sync reset) |  unit tested   |
| `counter_async`| N-bit up counter (async reset) |  unit tested   |
| `dff`         | D Flip-Flop with optional enable     |  unit tested   |
| `debouncer`   | Button debouncer                    |  unit tested   |
| `edge_detector` | Edge detector (rising/falling)       |  unit tested   |


Each module includes:
- Source in `source/`
- Testbench in `sim/`



## GitHub Actions Pipeline

This repo is equipped with a **CI pipeline** that:

- Runs testbenches on push
- Verifies simulation results
- Flags regressions immediately

You can customize the `.github/workflows/` to add waveform validation, linting, or formal checks.

---

## Why This Matters

Combining reusable HDL design with DevOps practices enables:

- Rapid FPGA learning and onboarding  
- Reliable module reuse in safety-critical systems  
- Strong test culture for simulation-heavy designs 

---

# Project Roadmap

The final goal is a **real-time FPGA-based HIL system** that emulates power electronics and motor physics for validating motor controllers.

### Phase 1: Foundation & Library  
- [x] Build modular `counter`
- [x] Set up VCD dumps and test macros
- [x] Configure  GitHub CI
- [x] Add `debouncer`
- [x] Add `edge_detector`
...

### Phase 2: Ethernet Communication

### Phase 3: HIL for basic MOSFET switch

### Phase 4: HIL for MOSFET and RL Circuit

### Phase 5: Full BLDC HIL




---






# Long-Term Goal

This project aims to build a real-time **Hardware-in-the-Loop (HIL) emulator** for testing **BLDC** and **Stepper motor controllers** using an **FPGA-based motor simulation**.  
It will emulate physical motor and powerstage behavior, using real-time PWM input signals from an external microcontroller or motor driver (e.g., STM32/Nucleo).

The FPGA will:
- Read real MOSFET states (PWM signals) in real time
- Simulate the motor physics (electrical + mechanical domain)
- Generate real-time feedback signals such as:
  - Quadrature Encoder (QEI: A, B, Z)
  - Analog current feedback (via filtered PWM, SPI DAC, or parallel DAC)
  - Optional fault simulation (e.g. shoot-through, dead-time violation)
- Use it in automated firmware test pipeline
  - read fpga/controller internals and compare -> test passed/fail

The system will be usable by motor control developers and test engineers as a compact, reproducible test platform or pipeline stage.

---
## Key Features

- Supports both **BLDC and stepper motor models**
- Switchable motor profiles (library of predefined motor parameters: A, B, C...)
- Output real-time internal signals: current, position, speed, torque, etc.
- Configurable via UART, USB, or Ethernet
- Output test data live or store internally and export post-test

---

## Simulation Strategy

- **Cycle-by-cycle simulation** at FPGA clock rate (e.g. 10–20 ns resolution @ 100 MHz)
  - Dont look for a full duty cycle to respond. Motor model response directly to active or inactive voltages.
- Motor model based on real MOSFET state transitions

---

## Feedback Signal Emulation

### QEI Output
- 3 channels: A, B, Z
- Configurable resolution and direction

### Analog Current Output Options:
- **PWM + RC Filter**
  - Simple and cheap
  - Requires 2 pins for 2 current channels
- **External SPI DAC**
  - 12-bit resolution possible
  - ~3–5 pins depending on LDAC/CS sharing
- **Parallel DAC**
  - Fast and low-latency
  - Needs 8–14 pins (8-bit or 12-bit DAC)

---

## FPGA I/O Requirements

| Function             | Description                            | Estimated Pins |
|----------------------|----------------------------------------|----------------|
| PWM Inputs           | Up to 8 (for full bridge stepper)      | 8              |
| QEI Outputs          | A, B, Z encoder signals                | 3              |
| Current Output       | 2 PWM channels or 2 DAC channels       | 2–14           |
| Debug / UART         | Logging or data export (optional)      | 1–2            |
| SPI DAC Interface    | MOSI, SCLK, CS, LDAC (optional)        | 3–5            |

---

## Example Workflow

1. Motor engineer plugs Nucleo into the FPGA board.
2. Selects motor model (e.g., Motor A - 14P/12S BLDC, 24 V, 1.2 Nm).
3. Controller runs Profile Velocity Ramp.
4. FPGA emulates physics and sends current + position back.
5. PC checks real-time output and validates controller behavior.
6. Engineer tests real world behavior with no overwhelming Hardware setup (cable, encoder...)

---

This project bridges the gap between offline simulation and expensive lab setups, allowing early, automated, and low-cost motor control development.

---
