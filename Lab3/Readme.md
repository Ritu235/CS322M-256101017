# RISC-V Single-Cycle with RVX10 Extensions

## Files (what to submit)
- `src/riscvsingle.sv`     — modified SystemVerilog CPU (CUSTOM-0 / RVX10 decode + ALU)
- `docs/ENCODINGS.md`     — bitfields and worked encodings
- `docs/TESTPLAN.md`      — per-op inputs and expected results
- `tests/rvx10.hex`       — $readmemh image (or save as `riscvtest.txt`)
- `README.md`             — this file

## Build & Run (from the folder containing `src` or adjust path)
1. Change to the folder that contains `riscvsingle.sv` and the instruction memory file:
   - If you put `riscvtest.txt` next to `riscvsingle.sv`:
     ```bash
     cd riscv_single/src
     iverilog -g2012 -o cpu_tb riscvsingle.sv
     vvp cpu_tb
     ```
   - If you kept `tests/rvx10.hex` under `../tests`, update the `$readmemh` path in `imem` or copy the hex into `riscvtest.txt` next to the SV file.

2. Expected console output:
Simulation succeeded


## Notes
- I implemented the 10 RVX10 ALU operations as combinational extensions in the `alu` module and decode the custom `{funct7, funct3}` in the datapath.
- Register x0 is protected from writes.
- `imem` and `dmem` declare memories as `RAM[0:63]` to avoid `$readmemh` range warnings.

## If you hit warnings
- `$readmemh` may warn about too few lines if your hex file has fewer than 64 words — that is harmless (remaining memory entries will be zero).
- If you see other errors, paste the simulator output here and I'll help debug.
