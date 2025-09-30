# Test Plan (TESTPLAN.md)

This test plan documents the input register values and expected outputs for each RVX10 operation used in the test image.

## Common initial registers
- After `addi x1, x0, 5`  -> x1 = 5  (0x00000005)
- After `addi x2, x0, 3`  -> x2 = 3  (0x00000003)

We then run each custom instruction and record expected rd values.

---

### ANDN x3, x1, x2
- Operation: rd = rs1 & ~rs2
- Inputs: x1 = 5, x2 = 3
- Calculation: ~3 = 0xFFFFFFFC; 5 & 0xFFFFFFFC = 4
- Expected: x3 = 4 (0x00000004)

### ORN x4, x1, x2
- Operation: rd = rs1 | ~rs2
- Inputs: x1 = 5, x2 = 3
- Calculation: 5 | 0xFFFFFFFC = 0xFFFFFFFD
- Expected: x4 = 0xFFFFFFFD (signed: -3)

### XNOR x6, x1, x2
- Operation: rd = ~(rs1 ^ rs2)
- Inputs: x1 = 5, x2 = 3 -> 5 ^ 3 = 6 -> ~6 = 0xFFFFFFF9
- Expected: x6 = 0xFFFFFFF9

### MIN x7, x1, x2 (signed)
- Inputs: 5 and 3
- Expected: x7 = 3

### MAX x8, x2, x1 (signed)
- Inputs (note order): rs1 = x2 = 3, rs2 = x1 = 5
- Expected: x8 = 5

### MINU x9, x2, x1 (unsigned)
- Inputs: 3 and 5 => unsigned min = 3
- Expected: x9 = 3

### MAXU x10, x2, x1 (unsigned)
- Expected: x10 = 5

### ROL x11, x1, x2
- Operation: rotate-left a by b[4:0]
- Inputs: a = 5 (0x5), shift = 3
- Expected: 0x5 rol 3 = 0x28 (40)

### ROR x12, x1, x2
- Operation: rotate-right a by b[4:0]
- Inputs: a = 5, shift = 3
- Expected: (5 >> 3) | (5 << 29) = 0xA0000000

### ABS x14, x1, x0  (rs2 = x0)
- Operation: absolute value of x1 (signed)
- Input: x1 = 5
- Expected: x14 = 5

---

## Final store to signal success
- `addi x5, x0, 25` sets x5 = 25
- `sw x5, 100(x0)` stores 25 into memory address 100.
- Testbench checks for DataAdr === 100 and WriteData === 25 and prints "Simulation succeeded".

---

## Edge cases (to test if you expand tests later)
- ROL/ROR with shamt = 0 -> should return operand unchanged.
- ABS on INT_MIN (0x80000000) -> result should remain 0x80000000 (wrap-around)
- Signed vs unsigned MIN/MAX where values cross sign boundary
