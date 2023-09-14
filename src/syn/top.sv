`timescale 1ns/1ns

`include "axi4_lite_if.svh"
`include "system.svh"

module top(
    //-------------PCI-E-------------\\
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
    input  logic [1:0] pcie_7x_mgt_rxn,
    input  logic [1:0] pcie_7x_mgt_rxp,
    output logic [1:0] pcie_7x_mgt_txn,
    output logic [1:0] pcie_7x_mgt_txp,
    `endif //SYNTHESIS 
    
    input  logic    REFCLK_n,
    input  logic    REFCLK_p,
    input  logic    PERST,

    //-------Processing System-------\\
    inout wire [14:0]  DDR_addr,
    inout wire [2:0]   DDR_ba,
    inout wire         DDR_cas_n,
    inout wire         DDR_ck_n,
    inout wire         DDR_ck_p,
    inout wire         DDR_cke,
    inout wire         DDR_cs_n,
    inout wire [3:0]   DDR_dm,
    inout wire [31:0]  DDR_dq,
    inout wire [3:0]   DDR_dqs_n,
    inout wire [3:0]   DDR_dqs_p,
    inout wire         DDR_odt,
    inout wire         DDR_ras_n,
    inout wire         DDR_reset_n,
    inout wire         DDR_we_n,
    inout wire         FIXED_IO_ddr_vrn,
    inout wire         FIXED_IO_ddr_vrp,
    inout wire [53:0]  FIXED_IO_mio,
    inout wire         FIXED_IO_ps_clk,
    inout wire         FIXED_IO_ps_porb,
    inout wire         FIXED_IO_ps_srstb,

    //-------------GPIO--------------\\
    output PL_led,
    output logic    mmcm_lock,
    output logic    user_link_up
    );

    //-------------PCI-E-------------\\
    logic REFCLK;
    logic pcie_aresetn;
    logic pcie_reset;
    logic pcie_axi_clk;
    logic PS_aresetn;

    IBUFDS_GTE2 REFCLK_ibuf_i (.O(REFCLK), .ODIV2(), .I(REFCLK_p), .CEB(1'b0), .IB(REFCLK_n));
    
    axi4_lite_if #(.DW(32), .AW(32)) pcie_axi();
    
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
        .PERST(PERST),
        .clk_out(pcie_axi_clk),
        .axi(pcie_axi),
        .user_link_up,
        .mmcm_lock
    );

    axi4_lite_if #(.DW(32), .AW(32)) GP0();
    axi4_lite_if #(.DW(32), .AW(32)) HP0();

     
    //-------Processing System-------\\
    `ifdef SYNTHESIS
    PS_wrapper 
    PS_wrapper_i (
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

        .GP0,
        .HP0,
        
        .peripheral_clock(),
        .peripheral_aresetn(PS_aresetn),
        .peripheral_reset()
    );
    `endif // SYNTHESIS


    mem_wrapper
    mem_i (
        .aclk(pcie_axi_clk),
        .aresetn(PERST),
        .axi(pcie_axi)
    );



    //-------------GPIO--------------\\
    blink
    blink_i (
        .reset(pcie_reset),
        .clk(REFCLK),
        .led(PL_led)
    );

endmodule
