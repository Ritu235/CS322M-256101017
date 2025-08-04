# 4-Bit Comparator

## Overview
This module implements a 4-bit digital comparator using Verilog. It compares two 4-bit binary numbers (`A[3:0]` and `B[3:0]`) and outputs:
- `o1`: High (`1`) if A > B
- `o2`: High (`1`) if A == B
- `o3`: High (`1`) if A < B

Only one of the outputs is active at any time based on the comparison.

## Design Approach
The comparator can be implemented in two ways:
- **Behavioral Modeling:** Using `if-else` or `case` statements
- **Structural Modeling:** Using cascading 1-bit comparator blocks

## Files Included
- `comparator_4bit.v` – Verilog code for the 4-bit comparator
- `tb_comparator_4bit.v` – Testbench for simulating the 4-bit comparator

## How to Simulate
Run the following commands in your terminal:
```bash
iverilog -o comp4_test comparator_4bit.v tb_comparator_4bit.v
vvp comp4_test
