`timescale 1ns/1ns

`include "axi4_lite_if.svh"
`include "system.svh"

module pcie_wrapper(   
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
        
        input  logic    REFCLK,
        input  logic    PERST,
        output logic    clk_out,
        axi4_lite_if.m  axi,
        output logic    mmcm_lock,
        output logic    user_link_up
    );
    
    `ifdef SYNTHESIS
        `define __NEED_PCI_IP
    `endif //SYNTHESIS    
    
    `ifndef SYNTHESIS
    `ifdef PCIE_PIPE_STACK
        `define __NEED_PCI_IP
    `endif //PCIE_FULL_STACK 
    `endif //SYNTHESIS  
    
    
    `ifdef  __NEED_PCI_IP
    wire [31 : 0]   axi4_awaddr;
    wire [7 : 0]    axi4_awlen;
    wire [2 : 0]    axi4_awsize;
    wire [1 : 0]    axi4_awburst;
    wire [2 : 0]    axi4_awprot;
    wire            axi4_awvalid;
    wire            axi4_awready;
    wire            axi4_awlock;
    wire [3 : 0]    axi4_awcache;
    wire [63 : 0]   axi4_wdata;
    wire [7 : 0]    axi4_wstrb;
    wire            axi4_wlast;
    wire            axi4_wvalid;
    wire            axi4_wready;
    wire [1 : 0]    axi4_bresp;
    wire            axi4_bvalid;
    wire            axi4_bready;
    wire [31 : 0]   axi4_araddr;
    wire [7 : 0]    axi4_arlen;
    wire [2 : 0]    axi4_arsize;
    wire [1 : 0]    axi4_arburst;
    wire [2 : 0]    axi4_arprot;
    wire            axi4_arvalid;
    wire            axi4_arready;
    wire            axi4_arlock;
    wire [3 : 0]    axi4_arcache;
    wire [63 : 0]   axi4_rdata;
    wire [1 : 0]    axi4_rresp;
    wire            axi4_rlast;
    wire            axi4_rvalid;
    wire            axi4_rready;
    

    axi4_lite_if #(.DW(64), .AW(32)) axi64();
    
    pcie pcie_i(
      .axi_aresetn(PERST),
      .user_link_up,
      .axi_aclk_out(clk_out),
      .axi_ctl_aclk_out(),
      .mmcm_lock,
      .interrupt_out(),
      .INTX_MSI_Request('b0),
      .INTX_MSI_Grant(),
      .MSI_enable(),
      .MSI_Vector_Num('b0),
      .MSI_Vector_Width(),
      .REFCLK(REFCLK),
      
      .s_axi_awid('b0),
      .s_axi_awaddr('b0),
      .s_axi_awregion('b0),
      .s_axi_awlen('b0),
      .s_axi_awsize('b0),
      .s_axi_awburst('b0),
      .s_axi_awvalid('b0),
      .s_axi_awready(),
      .s_axi_wdata('b0),
      .s_axi_wstrb('b0),
      .s_axi_wlast('b0),
      .s_axi_wvalid('b0),
      .s_axi_wready(),
      .s_axi_bid(),
      .s_axi_bresp(),
      .s_axi_bvalid(),
      .s_axi_bready('b0),
      .s_axi_arid('b0),
      .s_axi_araddr('b0),
      .s_axi_arregion('b0),
      .s_axi_arlen('b0),
      .s_axi_arsize('b0),
      .s_axi_arburst('b0),
      .s_axi_arvalid('b0),
      .s_axi_arready(),
      .s_axi_rid(),
      .s_axi_rdata(),
      .s_axi_rresp(),
      .s_axi_rlast(),
      .s_axi_rvalid(),
      .s_axi_rready('b0),
      .s_axi_ctl_awaddr('b0),
      .s_axi_ctl_awvalid('b0),
      .s_axi_ctl_awready(),
      .s_axi_ctl_wdata('b0),
      .s_axi_ctl_wstrb('b0),
      .s_axi_ctl_wvalid('b0),
      .s_axi_ctl_wready(),
      .s_axi_ctl_bresp(),
      .s_axi_ctl_bvalid(),
      .s_axi_ctl_bready('b0),
      .s_axi_ctl_araddr('b0),
      .s_axi_ctl_arvalid('b0),
      .s_axi_ctl_arready(),
      .s_axi_ctl_rdata(),
      .s_axi_ctl_rresp(),
      .s_axi_ctl_rvalid(),
      .s_axi_ctl_rready('b0),
      
      .m_axi_awaddr(axi4_awaddr),
      .m_axi_awlen(axi4_awlen),
      .m_axi_awsize(axi4_awsize),
      .m_axi_awburst(axi4_awburst),
      .m_axi_awprot(axi4_awprot),
      .m_axi_awvalid(axi4_awvalid),
      .m_axi_awready(axi4_awready),
      .m_axi_awlock(axi4_awlock),
      .m_axi_awcache(axi4_awcache),
      .m_axi_wdata(axi4_wdata),
      .m_axi_wstrb(axi4_wstrb),
      .m_axi_wlast(axi4_wlast),
      .m_axi_wvalid(axi4_wvalid),
      .m_axi_wready(axi4_wready),
      .m_axi_bresp(axi4_bresp),
      .m_axi_bvalid(axi4_bvalid),
      .m_axi_bready(axi4_bready),
      .m_axi_araddr(axi4_araddr),
      .m_axi_arlen(axi4_arlen),
      .m_axi_arsize(axi4_arsize),
      .m_axi_arburst(axi4_arburst),
      .m_axi_arprot(axi4_arprot),
      .m_axi_arvalid(axi4_arvalid),
      .m_axi_arready(axi4_arready),
      .m_axi_arlock(axi4_arlock),
      .m_axi_arcache(axi4_arcache),
      .m_axi_rdata(axi4_rdata),
      .m_axi_rresp(axi4_rresp),
      .m_axi_rlast(axi4_rlast),
      .m_axi_rvalid(axi4_rvalid),
      .m_axi_rready(axi4_rready),
      
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
      .pipe_tx_7_sigs
      `endif //PCIE_FULL_STACK 
      `endif //SYNTHESIS 
      
      `ifdef SYNTHESIS
      .pci_exp_txp(pcie_7x_mgt_txp),
      .pci_exp_txn(pcie_7x_mgt_txn),
      .pci_exp_rxp(pcie_7x_mgt_rxp),
      .pci_exp_rxn(pcie_7x_mgt_rxn)
      `endif //SYNTHESIS 
    );
    
    pcie_protocol_converter pcie_protocol_converter_i(
        .aclk(clk_out),
        .aresetn(PERST),
        
        .s_axi_awaddr(axi4_awaddr),
        .s_axi_awlen(axi4_awlen),
        .s_axi_awsize(axi4_awsize),
        .s_axi_awburst(axi4_awburst),
        .s_axi_awprot(axi4_awprot),
        .s_axi_awvalid(axi4_awvalid),
        .s_axi_awready(axi4_awready),
        .s_axi_awlock(axi4_awlock),
        .s_axi_awcache(axi4_awcache),
        .s_axi_wdata(axi4_wdata),
        .s_axi_wstrb(axi4_wstrb),
        .s_axi_wlast(axi4_wlast),
        .s_axi_wvalid(axi4_wvalid),
        .s_axi_wready(axi4_wready),
        .s_axi_bresp(axi4_bresp),
        .s_axi_bvalid(axi4_bvalid),
        .s_axi_bready(axi4_bready),
        .s_axi_araddr(axi4_araddr),
        .s_axi_arlen(axi4_arlen),
        .s_axi_arsize(axi4_arsize),
        .s_axi_arburst(axi4_arburst),
        .s_axi_arprot(axi4_arprot),
        .s_axi_arvalid(axi4_arvalid),
        .s_axi_arready(axi4_arready),
        .s_axi_arlock(axi4_arlock),
        .s_axi_arcache(axi4_arcache),
        .s_axi_rdata(axi4_rdata),
        .s_axi_rresp(axi4_rresp),
        .s_axi_rlast(axi4_rlast),
        .s_axi_rvalid(axi4_rvalid),
        .s_axi_rready(axi4_rready),
        
        .m_axi_araddr(axi64.araddr),
        .m_axi_arprot(axi64.arprot),
        .m_axi_arready(axi64.arready),
        .m_axi_arvalid(axi64.arvalid),
        .m_axi_awaddr(axi64.awaddr),
        .m_axi_awprot(axi64.awprot),
        .m_axi_awready(axi64.awready),
        .m_axi_awvalid(axi64.awvalid),
        .m_axi_bready(axi64.bready),
        .m_axi_bresp(axi64.bresp),
        .m_axi_bvalid(axi64.bvalid),
        .m_axi_rdata(axi64.rdata),
        .m_axi_rready(axi64.rready),
        .m_axi_rresp(axi64.rresp),
        .m_axi_rvalid(axi64.rvalid),
        .m_axi_wdata(axi64.wdata),
        .m_axi_wready(axi64.wready),
        .m_axi_wstrb(axi64.wstrb),
        .m_axi_wvalid(axi64.wvalid)
    );
    
    
    axi4_lite_dw_translator axi4_lite_dw_translator_i(
        .m(axi64),
        .s(axi)
    );
    `else // __NEED_PCI_IP
    axi_pcie_model axi_pcie_model_i(
        .REFCLK,
        .aresetn(PERST),
        .clk_out,
        .axi
    );
    `endif // __NEED_PCI_IP
endmodule


