# 1-Bit Comparator

## Overview
This module implements a 1-bit digital comparator using Verilog. It compares two 1-bit binary inputs (`A` and `B`) and produces three output signals:
- `o1` (A > B)
- `o2` (A == B)
- `o3` (A < B)

The outputs are mutually exclusive, meaning only one will be high (`1`) based on the comparison result.

## Files Included
- `comp1.v` - Verilog code for the 1-bit comparator
- `tb1.v` - Testbench file for simulating the comparator behavior

## How to Simulate
Use the following commands in your terminal:
```bash
iverilog -o comp1_test comp1.v tb1.v
vvp comp1_test


