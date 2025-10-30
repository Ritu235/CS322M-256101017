
# ⚙️ RVX10-P: Design and Verification Report

---

## 🧩 1. Design Description

The **RVX10-P** is a **five-stage pipelined** version of the single-cycle **RVX10** processor core.
It implements the complete **RV32I** base instruction set along with **10 custom RVX10 ALU operations**:

`ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS`

The datapath is divided into five stages:
**IF → ID → EX → MEM → WB**, with appropriate pipeline registers and separate hazard and forwarding units.

---

### 🧠 High-Level Architecture

![Full Pipelined Datapath](\[LINK])
*Figure 1 — High-Level Block Diagram of the RVX10-P Core*

---

### 🔹 Pipeline Stages and Registers

**IF (Instruction Fetch)**
![IF Stage Datapath](\[LINK])
**IF/ID Register:**
![IF/ID Register Code](\[LINK])

**ID (Instruction Decode)**
![ID/EX Datapath Register Code (Part 1)](\[LINK])
![ID/EX Datapath Register Code (Part 2)](\[LINK])
**Control Registers for ID/EX:**
![ID/EX Control Register Code (Part 1)](\[LINK])
![ID/EX Control Register Code (Part 2)](\[LINK])

**EX (Execute)**
![EX/MEM Datapath Register Code](\[LINK])
![EX/MEM Control Register Code](\[LINK])

**MEM (Memory Access)**
![MEM/WB Datapath Register Code](\[LINK])
![MEM/WB Control Register Code](\[LINK])

**WB (Write Back)**
![WB Stage Datapath](\[LINK])

---

## ⚠️ 2. Hazard Handling

Two dedicated units are used for handling hazards: the **Forwarding Unit** and the **Hazard Detection Unit**.

### 🔁 Forwarding Unit

![Forwarding Unit Code (Part 1)](\[LINK])
![Forwarding Unit Code (Part 2)](\[LINK])
![Forwarding Unit Pseudocode](\[LINK])

---

### 🚧 Hazard Detection Unit

![Hazard Unit Code](\[LINK])
![Hazard Unit Pseudocode](\[LINK])

---

## 🧪 3. Verification and Waveforms

### Test 1: Primary Test Program

The main test program executes a sequence of instructions and concludes by storing **25** at memory address **100**.
Successful simulation output confirms correct execution.

<details>
<summary><b>Click to expand Test Program Details</b></summary>

The test program verifies both standard **RISC-V** and custom **RVX10** instructions.

![RVX10 Instruction Set](\[LINK])
![Encoding Table](\[LINK])

**Instruction Format (R-type for RVX10):**

```
31 25 | 24 20 | 19 15 | 14 12 | 11 7 | 6 0
 func7 |  rs2  |  rs1  | func3 |  rd  | op
```

All custom instructions use the 7-bit opcode `0001011`.

**Example Program (`risctest.mem`):**
![risctest.mem (Part 1)](\[LINK])
![risctest.mem (Part 2)](\[LINK])

</details>  

---

### Test 2: `x0` Register Integrity

The `x0` register is permanently tied to zero. A write attempt (`add x0,x2,x9`) verifies that it cannot be modified.
Waveforms show that while the signal propagates through EX, MEM, and WB stages, the register file blocks the write.

![x0 Test Waveforms](\[LINK])

---

### Test 3: Data Hazard (ALU Forwarding)

Back-to-back ALU operations confirm correct forwarding behavior.

Example:

* `addi x3,x0,12` followed by `addi x7,x3,-9`
  → Forwarded result from **EX/MEM** ensures correctness.

![Forwarding Waveforms](\[LINK])

---

### Test 4: Data Hazard (Load-Use Stall)

Example:

* `lw x2,96(x0)` followed by `add x9,x2,x5`
  → Hazard unit detects dependency and inserts a stall by asserting `StallF` and `StallD`.

![Load-Use Stall Waveform](\[LINK])

---

### Test 5: Control Hazard (Branch Flush)

Example:

* `beq x4,x0,around`
  → Branch taken; pipeline flushes incorrect instructions.

![Branch Hazard Waveforms](\[LINK])

---

### Test 6: Pipeline Concurrency

Snapshots show multiple instructions executing simultaneously across pipeline stages.

![Pipeline Snapshots](\[LINK])

---

## ⚡ 4. Performance Analysis

### 🧮 Performance Counters

Cycle and instruction counters were implemented within the testbench to analyze CPI.

![Performance Counter Logic](\[LINK])

---

### 📊 Results and Comparison

**Final Register and Memory Comparison (Single-Cycle vs Pipelined):**

![Register File Comparison](\[LINK])
![Memory Comparison](\[LINK])

**CPI Visualization:**
![CPI Comparison](\[LINK])

|      Core Type     | Cycles | Instructions |  CPI  |
| :----------------: | :----: | :----------: | :---: |
| Single-Cycle RVX10 |   29   |      29      |  1.00 |
|  Pipelined RVX10-P |   39   |      31      | 1.256 |

> The theoretical cycle count for 31 instructions with 5 stages is `(n-1 + k) = 35`.
> The additional 4 cycles come from branch and jump penalties.
> Despite CPI > 1, the pipelined version achieves higher performance due to reduced clock cycle per stage.

---

## 🏁 5. Simulation Output

The self-checking testbench prints success when `memory[100] == 25`.

![Simulation Success](\[LINK])

---

## 📊 Instruction Distribution

The benchmark executed **33 instructions**, categorized as:

| **Type** | **Count** | **Percentage** |
| :------- | :-------: | :------------: |
| R-type   |     21    |     63.64%     |
| I-type   |     5     |     15.15%     |
| Branch   |     3     |      9.09%     |
| Store    |     2     |      6.06%     |
| Load     |     1     |      3.03%     |

---

## 🔧 Improvements & Future Work

![Benchmark Placeholder](\[LINK])

In the current evaluation, the **RVX10-P** achieved **39 cycles for 31 instructions**, with an average **CPI ≈ 1.26**.
By designing a larger testbench with **51 instructions** (only 2 successful branches), the expected theoretical CPI becomes **59/51 ≈ 1.156**.
Thus, keeping branch and jump counts constant while increasing other instruction types can further reduce the CPI, approaching the ideal value of 1.

### 💡 Proposed Enhancements

* Develop a **benchmark-driven testbench** with realistic instruction mixes (ALU, memory, and control).
* Analyze both **theoretical vs. simulated CPI** values.
* Optimize **forwarding and hazard control** to minimize bubbles and stalls.

### 🧩 Outcome

These enhancements would make the performance study more reliable and realistic, enabling future versions of **RVX10-P** to:

* Achieve **benchmark-consistent CPI results**
* Validate **throughput efficiency**
* Strengthen the design’s overall credibility

---

## 📚 References

* *Digital Design and Computer Architecture (RISC-V Edition)* — David Harris & Sarah Harris


---

## 🏫 Acknowledgment

Developed under the guidance of
**Dr. Satyajit Das**
*Assistant Professor*
Department of **Computer Science and Engineering**
**Indian Institute of Technology, Guwahati**
