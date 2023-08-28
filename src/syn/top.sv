`timescale 1ns/1ns

`include "axi_if.svh"
`include "system.svh"

module top(
        `ifndef SYNTHESIS
        `ifdef PCIE_PIPE_STACK
        input  logic [11:0] common_commands_in,
        input  logic [24:0] pipe_rx_0_sigs,
        input  logic [24:0] pipe_rx_1_sigs,
        input  logic [24:0] pipe_rx_2_sigs,
        input  logic [24:0] pipe_rx_3_sigs,
        input  logic [24:0] pipe_rx_4_sigs,
        input  logic [24:0] pipe_rx_5_sigs,
        input  logic [24:0] pipe_rx_6_sigs,
        input  logic [24:0] pipe_rx_7_sigs,
        output logic [11:0] common_commands_out,
        output logic [24:0] pipe_tx_0_sigs,
        output logic [24:0] pipe_tx_1_sigs,
        output logic [24:0] pipe_tx_2_sigs,
        output logic [24:0] pipe_tx_3_sigs,
        output logic [24:0] pipe_tx_4_sigs,
        output logic [24:0] pipe_tx_5_sigs,
        output logic [24:0] pipe_tx_6_sigs,
        output logic [24:0] pipe_tx_7_sigs,
        `endif //PCIE_FULL_STACK 
        `endif //SYNTHESIS      
        
        `ifdef SYNTHESIS
        input  logic pcie_7x_mgt_rxn,
        input  logic pcie_7x_mgt_rxp,
        output logic pcie_7x_mgt_txn,
        output logic pcie_7x_mgt_txp,
        `endif //SYNTHESIS 
        
        input  logic    REFCLK_n,
        input  logic    REFCLK_p,
        input  logic    PERST
    );
    logic REFCLK;
    logic PERST_i;

    IBUF        PERST_ibuf_i (.O(PERST_i), .I(PERST));
    IBUFDS_GTE2 REFCLK_ibuf_i (.O(REFCLK), .ODIV2(), .I(REFCLK_p), .CEB(1'b0), .IB(REFCLK_n));


    axi4_lite_if #(.DW(32), .AW(32)) axi();
    
    pcie_wrapper pcie_i(
        `ifndef SYNTHESIS
        `ifdef PCIE_PIPE_STACK
        .common_commands_in,
        .pipe_rx_0_sigs,
        .pipe_rx_1_sigs,
        .pipe_rx_2_sigs,
        .pipe_rx_3_sigs,
        .pipe_rx_4_sigs,
        .pipe_rx_5_sigs,
        .pipe_rx_6_sigs,
        .pipe_rx_7_sigs,
        .common_commands_out,
        .pipe_tx_0_sigs,
        .pipe_tx_1_sigs,
        .pipe_tx_2_sigs,
        .pipe_tx_3_sigs,
        .pipe_tx_4_sigs,
        .pipe_tx_5_sigs,
        .pipe_tx_6_sigs,
        .pipe_tx_7_sigs,
        `endif //PCIE_FULL_STACK 
        `endif //SYNTHESIS      
        
        `ifdef SYNTHESIS
        .pcie_7x_mgt_rxn,
        .pcie_7x_mgt_rxp,
        .pcie_7x_mgt_txn,
        .pcie_7x_mgt_txp,
        `endif //SYNTHESIS 
        
        .REFCLK(REFCLK),
        .PERST(PERST_i),
        .clk_out(),
        .axi
    );
    /*
    time_meashure_wrapper
     # (.AW(32), .DW(64))
    time_meashure_i (
        .aclk(clock),
        .aresetn(reset_n),
        .axi
    );*/
    
    mem_wrapper
    mem_i (
        .aclk(REFCLK),
        .aresetn(PERST_i),
        .axi
    );
endmodule
