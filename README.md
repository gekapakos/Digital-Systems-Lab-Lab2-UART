# Lab02: Universal Asynchronous Receiver-Transmitter (UART)

## Overview
This lab implements a UART (Universal Asynchronous Receiver-Transmitter) protocol for serial communication using Verilog on the Nexys A7-100T FPGA board. The goal is to design and verify a Transmitter (Tx) and Receiver (Rx) to transfer four 8-bit symbols (AA, 55, CC, 89) asynchronously. The system uses a 100 MHz clock, adjustable baud rates (300–115200 bps), and includes start, stop, and parity bits for data integrity.

## Hardware
- **Board**: Nexys A7-100T
- **Clock**: 100 MHz (10 ns period)
- **Protocol**: UART (8-bit data, no flow control)

## Parts

### Part A: Baud Rate Controller
- **Description**: Implements a controller to set a common baud rate for Tx and Rx, ensuring synchronized communication despite independent clocks.
- **Implementation**: Uses a 3-bit `baud_select` input to choose rates (300–115200 bps). Calculates clock cycles (`max_cycles = f_clk / (16 * Baud_Rate)`) with a 15-bit counter and outputs `sample_ENABLE` signal when the counter hits the target size.
- **Verification**: Testbench checks `sample_ENABLE` toggles correctly for different `baud_select` values, resetting before each change. Waveforms confirm periodic activation aligned with baud rates.

### Part B: UART Transmitter (Tx)
- **Description**: Serializes 8-bit symbols with start, parity, and stop bits for transmission.
- **Implementation**: Top module `uart_transmitter` uses a baud controller and FSM (`Tx_FSM`) with states: idle, start, trans, parity, stop. Inputs include `Tx_DATA` (8-bit symbol), `Tx_EN`, and `Tx_WR`; outputs are `TxD` (serial data) and `Tx_BUSY` (transmission status).
- **Verification**: Testbench sets `baud_select = 111` (115200 bps) and `Tx_DATA = 10101010`. Waveforms show state transitions (idle to stop), correct bit shifting, even parity (0), and return to idle after reset.

### Part C: UART Receiver (Rx)
- **Description**: Samples serial data, validates it, and stores correct 8-bit symbols.
- **Implementation**: Top module `uart_receiver` integrates the baud controller and FSM (`Rx_FSM`) with states: idle, start, trans, parity, stop. Inputs include `RxD` (from TxD); outputs are `Rx_DATA` (8-bit symbol), `Rx_VALID`, `Rx_PERROR` (parity error), and `Rx_FERROR` (framing error). Samples at 16x baud rate.
- **Verification**: Testbench verifies center sampling, error detection (PERROR/FERROR), and `Rx_DATA` stability. Waveforms show successful data receipt when error-free, and error signals active with parity or framing issues.

### Part D: Full UART Tx-Rx System
- **Description**: Combines Tx and Rx for end-to-end serial transfer of four symbols.
- **Implementation**: Integrates `uart_transmitter` and `uart_receiver` modules, connecting `TxD` to `RxD`.
- **Verification**: Testbench sends four symbols (AA, 55, CC, 89) using a simple FSM to trigger `Tx_WR` when `Tx_BUSY = 0`. Waveforms confirm `Rx_DATA` matches `Tx_DATA` with a delay, and no errors occur, validating the system.

## Setup
1. Clone this repository.
2. Open in Vivado.
3. Synthesize, implement, and generate bitstreams for each part.
4. Program the Nexys A7-100T and verify with testbenches.
