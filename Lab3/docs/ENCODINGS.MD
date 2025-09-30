# RVX10 Instruction Encodings (ENCODINGS.md)

This file documents the R-type bitfields and provides a worked example for each RVX10 instruction.

## R-type format (bit positions)
instr[31:25] = funct7 (7 bits)
instr[24:20] = rs2 (5 bits)
instr[19:15] = rs1 (5 bits)
instr[14:12] = funct3 (3 bits)
instr[11:7] = rd (5 bits)
instr[6:0] = opcode (7 bits)
For RVX10 custom instructions:
- `opcode = 7'b0001011` (0x0B) — CUSTOM-0
- The mapping of `funct7` and `funct3` is as follows:

| Instruction | funct7    | funct3 |
|-------------|-----------|--------|
| ANDN        | 0000000   | 000    |
| ORN         | 0000000   | 001    |
| XNOR        | 0000000   | 010    |
| MIN         | 0000001   | 000    |
| MAX         | 0000001   | 001    |
| MINU        | 0000001   | 010    |
| MAXU        | 0000001   | 011    |
| ROL         | 0000010   | 000    |
| ROR         | 0000010   | 001    |
| ABS         | 0000011   | 000    | (rs2 = x0 for ABS)

---

## Worked example (one example per instruction)

**Field explanation example:** `ANDN x3, x1, x2`

- funct7 = `0000000`
- rs2 = `00010` (x2)
- rs1 = `00001` (x1)
- funct3 = `000`
- rd = `00011` (x3)
- opcode = `0001011` (CUSTOM-0)

Binary layout:
0000000 00010 00001 000 00011 0001011

markdown
Copy code

Concatenate and convert to 32-bit hex: **`0x0020818B`**

(Full hex encodings used in the test program are in `tests/rvx10.hex` — one hex word per line.)

---

## Encodings used in tests (examples)

Below are the example instruction encodings used in the provided test:

- `addi x1, x0, 5`       → `0x00500093`
- `addi x2, x0, 3`       → `0x00300113`
- `ANDN x3,x1,x2`        → `0x0020818b`
- `ORN x4,x1,x2`         → `0x0020920b`
- `XNOR x6,x1,x2`        → `0x0020a30b`
- `MIN x7,x1,x2`         → `0x0220838b`
- `MAX x8,x2,x1`         → `0x0211140b`
- `MINU x9,x2,x1`        → `0x0211248b`
- `MAXU x10,x2,x1`       → `0x0211350b`
- `ROL x11,x1,x2`        → `0x0420858b`
- `ROR x12,x1,x2`        → `0x0420960b`
- `ABS x14,x1,x0`        → `0x0600870b`
- `addi x5, x0, 25`      → `0x01900293`
- `sw x5, 100(x0)`       → `0x06502223`
(One line per 32-bit hex word — used directly in `tests/rvx10.hex`.)
