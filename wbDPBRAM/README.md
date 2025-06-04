# wbDPBRAM Module

This Verilog module implements a **Double Port Block RAM (DPBRAM)**. It features a dedicated synchronous write-only port (Port A) and a dedicated synchronous read-only port (Port B), both operating under a single clock. The module is highly configurable, allowing you to easily adjust its data width and address depth.

## Features

* **Configurable Parameters:** Easily set `DATA_WIDTH` (data bus size), `ADDR_WIDTH` (address bus size, determines memory depth), and `MEM_DEPTH` (total memory locations).
* **Synchronous Operation:** All memory accesses (reads and writes) are synchronized to the positive edge of the `i_clk` signal.
* **Dedicated Write Port (Port A):** Allows data to be written into the RAM. It includes enable (`i_enA`), write enable (`i_weA`), address (`i_addrA`), and data input (`i_dinA`) signals.
* **Dedicated Read Port (Port B):** Allows data to be read from the RAM. It includes enable (`i_enB`), address (`i_addrB`), and data output (`o_doutB`) signals.
* **MIT License:** Freely usable and modifiable under the terms of the MIT License.

## Usage

1.  **Instantiate the module:**

    Here's an example of how to instantiate `wbDPBRAM` in your Verilog design:

    ```verilog
    wbDPBRAM #(
        .DATA_WIDTH (32),   // Example: 32-bit wide data bus
        .ADDR_WIDTH (10)    // Example: 10-bit address bus (results in 2^10 = 1024 memory locations)
        // MEM_DEPTH is automatically calculated based on ADDR_WIDTH,
        // but can be explicitly set if needed.
    ) my_dpbram (
        .i_clk   (system_clk),      // System clock input
        .i_enA   (write_enable_A),  // Port A enable (active high)
        .i_weA   (write_data_A),    // Port A write enable (active high)
        .i_addrA (address_A),       // Port A address input
        .i_dinA  (data_input_A),    // Port A data input for writes

        .i_enB   (read_enable_B),   // Port B enable (active high)
        .i_addrB (address_B),       // Port B address input
        .o_doutB (data_output_B)    // Port B data output for reads
    );
    ```