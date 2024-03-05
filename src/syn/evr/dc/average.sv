//------------------------------------------------
//
//      project: llrf-hp
//
//      module:  average_m
//
//      desc:    average module for delay measurement
//
//------------------------------------------------

`ifndef __AVERAGE_SV__
`define __AVERAGE_SV__

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      First order exponential FIR described by eq:
//      Yn = Yn-1 + Yn-1/T + Xn , where 
//      1. T is defined as 2^N for this module
//      2. Fractional par of internal data representation is defined
//         by FRACTIONAL parameter
//      3. Output fixed point format is IN_WIDTH.N so 
//         IN_WIDTH + N must be lesser or equal OUT_WIDTH
//      4. Output data is left shifted to OUT_WIDTH boundary
//
//------------------------------------------------
module average_m #(
    parameter IN_WIDTH  = 16,
    parameter OUT_WIDTH = 32,
    parameter N_FAST    = 8,
    parameter N_SLOW    = 16,
    parameter PRECISION = 16
)
(
    input  logic                 clk,
    input  logic                 rst,

    input  logic                 slow,
    input  logic [ IN_WIDTH-1:0] in,
    input  logic                 load,
    output logic [OUT_WIDTH-1:0] out
);

//------------------------------------------------
localparam ACC_W = OUT_WIDTH + N_SLOW + PRECISION;

//------------------------------------------------
typedef logic [ACC_W-1:0] acc_t;

//------------------------------------------------
acc_t acc = '0;
acc_t fdb;
acc_t sample;

acc_t acc_aligned;

//------------------------------------------------
assign acc_aligned = acc << (OUT_WIDTH - IN_WIDTH);
assign out         = acc_aligned[ACC_W-1:ACC_W-OUT_WIDTH];

//------------------------------------------------
assign fdb    = slow ? (acc >> N_SLOW) : (acc >> N_FAST);
assign sample = slow ? acc_t'(in << PRECISION) :  acc_t'(in << (PRECISION + N_SLOW - N_FAST));

always_ff @(posedge clk) begin
    if (rst) begin
        acc <= '0;
    end
    else begin
        if (load) begin
            acc <= acc - fdb + sample;
        end
    end
end

//------------------------------------------------
endmodule : average_m

`endif//__AVERAGE_SV__