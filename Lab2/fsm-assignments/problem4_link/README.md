# Problem 4 — 4-Phase Handshake (Master–Slave Link)

## Summary
Implement two synchronous FSMs that transfer **4 bytes** over a **4-phase req/ack** handshake.  
For each byte: Master drives `data` and raises `req`; Slave latches `data` and asserts `ack` for **2 cycles**; Master drops `req`; Slave drops `ack`. After 4 bytes, Master pulses `done=1` for one cycle.

## Why two FSMs and a 4-phase protocol?
- Separates concerns (producer vs. consumer) and avoids data races.
- 4-phase (req↑ → ack↑ → req↓ → ack↓) is unambiguous and easy to verify in waves.

## Modules
- `master_fsm.v` — sends 4 bytes (A0..A3) using states:
  `IDLE → LOAD → ASSERT_REQ → WAIT_ACK_H → DROP_REQ → WAIT_ACK_L → NEXT → DONE`.
- `slave_fsm.v` — on `req=1`, latches `data_in`, asserts `ack` and **holds it high 2 cycles**, then waits for `req=0` to drop `ack`.
- `link_top.v` — wires Master ↔ Slave.
- `tb_link_top.v` — drives `clk/rst`, stops after `done`.

## State Diagrams (what to label)
- **Master** circles: the states named above.
  - Arrows:
    - `ASSERT_REQ → WAIT_ACK_H` labeled `req=1`
    - `WAIT_ACK_H → DROP_REQ` labeled `ack=1`
    - `DROP_REQ → WAIT_ACK_L` labeled `req=0`
    - `WAIT_ACK_L → NEXT/DONE` labeled `ack=0`
- **Slave** circles: `WAIT_REQ → ASSERT_ACK → HOLD_ACK(2) → WAIT_REQ_LOW`.
  - Arrows:
    - on `req=1` latch data; `ASSERT_ACK` sets `ack=1`
    - `HOLD_ACK` counts 2 cycles
    - drop `ack` only after `req=0`

## How to Run (Icarus Verilog + GTKWave)
```bash
iverilog -o sim.out tb_link_top.v link_top.v master_fsm.v slave_fsm.v
vvp sim.out
gtkwave dump.vcd
