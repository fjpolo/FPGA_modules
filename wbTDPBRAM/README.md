# wbTDPBRAM Module - True Double Port Block RAM

This Verilog module implements a **True Dual Port Block RAM** with **Port A write priority on collision**. It allows independent read and write operations to happen concurrently on two separate ports.

## Features

* **True Dual-Port Operation:** Independent read and write access is provided via two distinct ports (Port A and Port B), each with its own clock, enable, write enable, address, and data I/O lines.

* **Parameterized Configuration:** The `DATA_WIDTH` (data bus width) and `ADDR_WIDTH` (address bus width, which determines memory depth) are configurable through parameters, offering flexibility in memory size.

* **Synchronous Access:** All read and write operations are synchronous, occurring on the positive edge of their respective clock signals (`i_clkA` for Port A and `i_clkB` for Port B).

* **Port A Write Priority:** In cases where both Port A and Port B attempt to write to the *same memory address* simultaneously, Port A's write operation will successfully complete, while Port B's write to that colliding address will be ignored.

* **Block RAM Implementation:** The memory core is modeled using a simple Verilog `reg` array, suitable for synthesis into dedicated Block RAM resources in FPGAs.

## Usage

1.  **Instantiate the module:**

    ```verilog
    module wbTDPBRAM#(
                        parameter DATA_WIDTH = 32,
                        parameter ADDR_WIDTH = 10,
                        parameter MEM_DEPTH   = (1 << ADDR_WIDTH) // Calculate memory depth from address width
                     )(
                        input   wire    [0:0]               i_clkA,
                        input   wire    [0:0]               i_clkB,
                        input   wire    [0:0]               i_enA,
                        input   wire    [0:0]               i_enB,
                        input   wire    [0:0]               i_weA,
                        input   wire    [0:0]               i_weB,
                        input   wire    [(ADDR_WIDTH-1):0]  i_addrA,
                        input   wire    [(ADDR_WIDTH-1):0]  i_addrB,
                        input   wire    [(DATA_WIDTH-1):0]  i_dinA,
                        input   wire    [(DATA_WIDTH-1):0]  i_dinB,
                        output  reg     [(DATA_WIDTH-1):0]  o_doutA,
                        output  reg     [(DATA_WIDTH-1):0]  o_doutB
                    ) ;
    );
    ```

    You can instantiate it in your top-level design or another module, specifying the `DATA_WIDTH` and `ADDR_WIDTH` as needed:

    ```verilog
    // Example instantiation in another module
    wbTDPBRAM #(
        .DATA_WIDTH(32), // e.g., 32-bit data
        .ADDR_WIDTH(10)  // e.g., 10-bit address (1024 locations)
    ) your_bram_instance (
        .i_clkA(clk_a),
        .i_enA(en_a),
        .i_weA(we_a),
        .i_addrA(addr_a),
        .i_dinA(data_in_a),
        .o_doutA(data_out_a),

        .i_clkB(clk_b),
        .i_enB(en_b),
        .i_weB(we_b),
        .i_addrB(addr_b),
        .i_dinB(data_in_b),
        .o_doutB(data_out_b)
    );
    ```