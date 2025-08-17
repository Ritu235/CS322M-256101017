# Problem 4 — 4-Phase Handshake (Master–Slave Link)

## Summary
Implement two synchronous FSMs that transfer **4 bytes** over a **4-phase req/ack** handshake.  
For each byte: Master drives `data` and raises `req`; Slave latches `data` and asserts `ack` for **2 cycles**; Master drops `req`; Slave drops `ack`. After 4 bytes, Master pulses `done=1` for one cycle.

## Why two FSMs and a 4-phase protocol?
Separates concerns (producer vs. consumer) and avoids data races.
4-phase (req↑ → ack↑ → req↓ → ack↓) is unambiguous and easy to verify in waves.

## Modules
`master_fsm.v` — sends 4 bytes (A0..A3) using states:
`IDLE → LOAD → ASSERT_REQ → WAIT_ACK_H → DROP_REQ → WAIT_ACK_L → NEXT → DONE`.
`slave_fsm.v` — on `req=1`, latches `data_in`, asserts `ack` and **holds it high 2 cycles**, then waits for `req=0` to drop `ack`.
`link_top.v` — wires Master ↔ Slave.
`tb_link_top.v` — drives `clk/rst`, stops after `done`.

## State Diagrams 

 ## Master Transition Table

| Current State  | Input Condition                       | Next State     | Description                                           |
|----------------|---------------------------------------|----------------|-------------------------------------------------------|
| **S_IDLE**     | (Always)                              | **S_DRIVE_DATA** | Start the transfer.                                  |
| **S_DRIVE_DATA** | (Always)                            | **S_WAIT_ACK**   | Wait for the slave's reply.                          |
| **S_WAIT_ACK** | `ack == 0`                           | **S_WAIT_ACK**   | Keep waiting.                                        |
| **S_WAIT_ACK** | `ack == 1 AND byte_count < 3`        | **S_WAIT_NO_ACK**| Got the reply, prepare for the next byte.            |
| **S_WAIT_ACK** | `ack == 1 AND byte_count == 3`       | **S_DONE**       | Got the reply for the last byte, finish up.          |
| **S_WAIT_NO_ACK** | `ack == 1`                        | **S_WAIT_NO_ACK**| Wait for the slave to end the handshake.             |
| **S_WAIT_NO_ACK** | `ack == 0`                        | **S_DRIVE_DATA** | Handshake over, send the next byte.                  |
| **S_DONE**     | (Always)                              | **S_IDLE**       | Job is done, go back to the start.                   |


## Slave Transition Table

| Current State    | Input Condition | Next State       | Description                                            |
|------------------|-----------------|------------------|--------------------------------------------------------|
| **S_IDLE**       | `req == 0`     | **S_IDLE**       | Keep waiting for a request.                           |
| **S_IDLE**       | `req == 1`     | **S_LATCH_ACK**  | Got a request, start acknowledging.                   |
| **S_LATCH_ACK**  | (Always)       | **S_HOLD_ACK**   | Hold `ack` high for the 2nd cycle.                    |
| **S_HOLD_ACK**   | (Always)       | **S_WAIT_NO_REQ**| `ack` held for 2 cycles, now wait for `req` to go low.|
| **S_WAIT_NO_REQ**| `req == 1`     | **S_WAIT_NO_REQ**| Keep waiting for the master to end the request.       |
| **S_WAIT_NO_REQ**| `req == 0`     | **S_IDLE**       | Master ended the request, handshake is over.          |

## How to Run (Icarus Verilog + GTKWave)
```bash
iverilog -o sim.out tb_link_top.v link_top.v master_fsm.v slave_fsm.v
vvp sim.out
gtkwave dump.vcd

