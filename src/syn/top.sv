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
    input  logic [1:0]  pcie_7x_mgt_rxn,
    input  logic [1:0]  pcie_7x_mgt_rxp,
    output logic [1:0]  pcie_7x_mgt_txn,
    output logic [1:0]  pcie_7x_mgt_txp,
    `endif //SYNTHESIS 
    
    input  logic        REFCLK_n,
    input  logic        REFCLK_p,
    input  logic        PERST,

    //-------Processing System-------\\
    `ifdef SYNTHESIS
    inout wire [14:0]   DDR_addr,
    inout wire [2:0]    DDR_ba,
    inout wire          DDR_cas_n,
    inout wire          DDR_ck_n,
    inout wire          DDR_ck_p,
    inout wire          DDR_cke,
    inout wire          DDR_cs_n,
    inout wire [3:0]    DDR_dm,
    inout wire [31:0]   DDR_dq,
    inout wire [3:0]    DDR_dqs_n,
    inout wire [3:0]    DDR_dqs_p,
    inout wire          DDR_odt,
    inout wire          DDR_ras_n,
    inout wire          DDR_reset_n,
    inout wire          DDR_we_n,
    inout wire          FIXED_IO_ddr_vrn,
    inout wire          FIXED_IO_ddr_vrp,
    inout wire [53:0]   FIXED_IO_mio,
    inout wire          FIXED_IO_ps_clk,
    inout wire          FIXED_IO_ps_porb,
    inout wire          FIXED_IO_ps_srstb,
    `endif //SYNTHESIS 

    //-------------QSPI--------------\\
    output logic        SCK,
    output logic        CSn,
    input  logic [3:0]  MISO,
    output logic [3:0]  MOSI,

    //-------------GPIO--------------\\
    output PL_led

    );

    logic REFCLK;
    logic PS_aresetn;
    logic PS_clk;
    logic spi_aclk;
    logic spi_oclk;
    logic spi_aresetn;
    
    //-------------PCI-E-------------\\ 
    axi4_lite_if #(.DW(32), .AW(32)) bar0();
    axi4_lite_if #(.DW(32), .AW(32)) bar1();
    axi4_lite_if #(.DW(32), .AW(32)) bar2();

    IBUFDS_GTE2 REFCLK_ibuf_i (.O(REFCLK), .ODIV2(), .I(REFCLK_p), .CEB(1'b0), .IB(REFCLK_n));
    
    pcie_wrapper_ pcie_i(
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
        
        .bar0(bar0),
        .bar1(bar1),
        .bar2(bar2),
        .bar_clk(PS_clk),
        .bar_aresetn(PS_aresetn)
    );

    axi4_lite_if #(.DW(32), .AW(32)) GP0();
    //axi4_lite_if #(.DW(32), .AW(32)) HP0();

     
    //-------Processing System-------\\
    PS_wrapper_ 
    PS_wrapper_i (
        `ifdef SYNTHESIS
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
        `endif // SYNTHESIS

        .GP0,
        .HP0(bar2),
        
        .peripheral_clock(PS_clk),
        .peripheral_aresetn(PS_aresetn),
        .peripheral_reset()
    );


    mem_wrapper
    mem_i (
        .aclk(PS_clk),
        .aresetn(PS_aresetn),
        .axi(bar0)
    );

    //-------------QSPI--------------\\
    qspi_wrapper qspi_wrapper_m
    (
        .aclk(PS_clk),
        .aresetn(PS_aresetn),
        .ps_bus(GP0),
        .pcie_bus(bar1),

        .spi_aclk(spi_aclk),
        .spi_oclk(spi_oclk),
        .spi_aresetn(spi_aresetn),
        
        .SCK(SCK),
        .CSn(CSn),
        .MISO(MISO),
        .MOSI(MOSI)
    );

    //-------------GPIO--------------\\
    blink
    blink_i (
        .reset(PS_aresetn),
        .clk(REFCLK),
        .led(PL_led)
    );

endmodule
