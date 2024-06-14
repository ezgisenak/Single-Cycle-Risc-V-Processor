# Single-Cycle RISC-V Processor

## Overview

This project implements a Single-Cycle 32-bit RISC-V Processor as part of the EE446 Computer Architecture II Laboratory course at Middle East Technical University (METU). The processor is designed to execute a subset of the RISC-V instruction set, with an additional custom instruction, and is implemented on an FPGA.

## Table of Contents

1. [Introduction](#introduction)
2. [Datapath Design](#datapath-design)
3. [Controller Design](#controller-design)
4. [Testbench](#testbench)
5. [RISC-V Program](#risc-v-program)
6. [Project Demonstration](#project-demonstration)
7. [Conclusion](#conclusion)
8. [Usage](#usage)
9. [Contributors](#contributors)

## Introduction

RISC-V is an innovative instruction-set architecture (ISA) initially developed to support research and education in computer architecture. Its open and modular nature makes it suitable for a wide range of hardware implementations. This project aims to explore RISC-V by constructing the datapath and control unit of a single-cycle 32-bit RISC-V processor and embedding it into an FPGA.

## Datapath Design

The datapath is designed to support all the instructions listed in the project requirements. Key features include:

- A shifter for SLL, SRL, and SRA instructions.
- Multiple multiplexers for selecting between various inputs.
- An extended Result selection multiplexer.
- A 3-bit MemControl signal for different memory operations.

### Read Operations

- **Word (32-bit):** Reads four consecutive bytes.
- **Halfword Unsigned (16-bit):** Reads two bytes with zero extension.
- **Halfword (16-bit):** Reads two bytes with sign extension.
- **Byte Unsigned (8-bit):** Reads a single byte with zero extension.
- **Byte (8-bit):** Reads a single byte with sign extension.

### Write Operations

- **Word (32-bit):** Writes four consecutive bytes.
- **Halfword (16-bit):** Writes two bytes.
- **Byte (8-bit):** Writes a single byte.

## Controller Design

The controller generates the necessary control signals for the datapath. Key control signals include ShamtControl, ShiftControl, and ExtendedMuxControl. The controller handles various instruction types:

- **R-Type Instructions:** ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- **I-Type Instructions:** ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, JALR
- **J-Type Instructions:** JAL
- **B-Type Instructions:** BEQ, BNE, BLT, BGE, BLTU, BGEU
- **L-Type Instructions:** LB, LBU, LH, LHU, LW
- **S-Type Instructions:** SB, SH, SW
- **U-Type Instructions:** AUIPC, LUI

## Testbench

The testbench simulates and validates the processor's behavior using Cocotb. Key components include:

- **Single_Cycle_Test.py:** Initializes and logs the state of the processor, compares expected and actual results, and executes instructions.
- **Helper_lib.py:** Contains helper functions for instruction handling and memory simulation.

The testbench verifies the processor against a reference model by simulating various RISC-V instructions and comparing the results.

## RISC-V Program

A comprehensive RISC-V program is used to test the processor. The program includes:

- Arithmetic and logical instructions.
- Custom instructions.
- Memory access operations.
- Shift operations.
- Conditional branches and jumps.

## Project Demonstration

In the demonstration, the processor is loaded onto the DE1-SoC FPGA board and tested with a given code segment. The processor's functionality is validated through this hands-on demonstration.

## Conclusion

This project successfully demonstrates the design and implementation of a Single-Cycle 32-bit RISC-V Processor. It showcases the capabilities of the RISC-V ISA and provides hands-on experience in hardware design and FPGA implementation.

## Usage

To run this project:

1. Clone the repository.
2. Synthesize the Verilog code using FPGA design software (e.g., Quartus).
3. Load the synthesized design onto the DE1-SoC FPGA board.
4. Run the provided testbench to verify the processor's functionality.

## Contributors

- Ezgi Sena Karabacak - 2375178
- Merve Nur Zembil - 2376242

This project was completed as part of the EE446 Computer Architecture II course at METU.
