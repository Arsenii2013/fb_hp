`timescale 1ns/1ps

module fifo_wrapper 
#(
    parameter DEPTH = 1024,
    parameter WIDTH = 32
)
(
    input  logic rst,
    input  logic wr_clk,
    input  logic rd_clk,
    input  logic [WIDTH-1: 0] d_in,
    input  logic wr_en,
    input  logic rd_en,
    output logic [WIDTH-1: 0] d_out,
    output logic full,
    output logic empty
);

FIFO18E1 #(
   .DATA_WIDTH(18),                    // Sets data width to 4-36
   .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
   .EN_SYN("FALSE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
   .FIFO_MODE("FIFO18"),              // Sets mode to FIFO18 or FIFO18_36
   .FIRST_WORD_FALL_THROUGH("FALSE"), // Sets the FIFO FWFT to FALSE, TRUE
   .INIT(36'h000000000),              // Initial values on output port
   .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
   .SRVAL(36'h000000000)              // Set/Reset value for output port
)
FIFO18E1_inst (
   // Read Data: 32-bit (each) output: Read output data
   .DO(d_out),                   // 32-bit output: Data output
   .DOP(),                 // 4-bit output: Parity data output
   .EMPTY(empty),             // 1-bit output: Empty flag
   .FULL(full),               // 1-bit output: Full flag
   // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
   .RDCLK(rd_clk),             // 1-bit input: Read clock
   .RDEN(rd_en),               // 1-bit input: Read enable
   .REGCE(1),             // 1-bit input: Clock enable
   .RST(rst),                 // 1-bit input: Asynchronous Reset
   .RSTREG(rst),           // 1-bit input: Output register set/reset
   // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
   .WRCLK(wr_clk),             // 1-bit input: Write clock
   .WREN(wr_en),               // 1-bit input: Write enable
   // Write Data: 32-bit (each) input: Write input data
   .DI(d_in)                   // 32-bit input: Data input
);
endmodule
