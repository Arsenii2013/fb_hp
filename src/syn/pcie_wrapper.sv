`timescale 1ns/1ns

`include "axi4_lite_if.svh"
`include "top.svh"

module pcie_wrapper_(   
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

        output logic [1:0]  pcie_qpll_drp_qplld,
        input  logic [1:0]  pcie_qpll_drp_qplllock,
        input  logic [1:0]  pcie_qpll_drp_qplloutclk,
        input  logic [1:0]  pcie_qpll_drp_qplloutrefclk,
        output logic [1:0]  pcie_qpll_drp_qpllreset,

        output logic        DRP_CLK,  
        input  logic [15:0] DRP_DO,
        input  logic        DRP_RDY,
        output logic [ 7:0] DRP_ADDR,
        output logic        DRP_EN,  
        output logic [15:0] DRP_DI,   
        output logic        DRP_WE,

        `ifdef SYNTHESIS
        input  logic [1:0]  pcie_7x_mgt_rxn,
        input  logic [1:0]  pcie_7x_mgt_rxp,
        output logic [1:0]  pcie_7x_mgt_txn,
        output logic [1:0]  pcie_7x_mgt_txp,
        `endif //SYNTHESIS      
        
        axi4_lite_if.m      bar0,
        axi4_lite_if.m      bar1,
        axi4_lite_if.m      bar2,
        
        input  logic        REFCLK,
        input  logic        PERST,
        input  logic        bar_clk,
        input  logic        bar_aresetn
    );
    
    `ifdef SYNTHESIS
        `define __NEED_PCI_IP
    `endif //SYNTHESIS    
    
    `ifndef SYNTHESIS
    `ifdef PCIE_PIPE_STACK
        `define __NEED_PCI_IP
    `endif //PCIE_FULL_STACK 
    `endif //SYNTHESIS  

    logic [1:0]  pcie_qpll_drp_clk;
    logic [11:0] pcie_qpll_drp_crscode;
    logic [1:0]  pcie_qpll_drp_done;
    logic [17:0] pcie_qpll_drp_fsm;
    logic [1:0]  pcie_qpll_drp_gen3;
    logic [1:0]  pcie_qpll_drp_ovrd;
    logic [1:0]  pcie_qpll_drp_reset;
    logic [1:0]  pcie_qpll_drp_rst_n;
    logic [1:0]  pcie_qpll_drp_start;

    //assign pcie_qpll_drp_qpllreset = pcie_qpll_drp_reset;
    
    
    `ifdef  __NEED_PCI_IP

    axi4_lite_if #(.DW(64), .AW(32)) bar0_64();
    axi4_lite_if #(.DW(64), .AW(32)) bar1_64();
    axi4_lite_if #(.DW(64), .AW(32)) bar2_64();
    
    pcie pcie_i(
        .PERST(PERST),
        .REFCLK(REFCLK),
        .m_axi_aclk(bar_clk),
        .m_axi_aresetn(bar_aresetn),
    
        .bar0_araddr(bar0_64.araddr),
        .bar0_arprot(bar0_64.arprot),
        .bar0_arready(bar0_64.arready),
        .bar0_arvalid(bar0_64.arvalid),
        .bar0_awaddr(bar0_64.awaddr),
        .bar0_awprot(bar0_64.awprot),
        .bar0_awready(bar0_64.awready),
        .bar0_awvalid(bar0_64.awvalid),
        .bar0_bready(bar0_64.bready),
        .bar0_bresp(bar0_64.bresp),
        .bar0_bvalid(bar0_64.bvalid),
        .bar0_rdata(bar0_64.rdata),
        .bar0_rready(bar0_64.rready),
        .bar0_rresp(bar0_64.rresp),
        .bar0_rvalid(bar0_64.rvalid),
        .bar0_wdata(bar0_64.wdata),
        .bar0_wready(bar0_64.wready),
        .bar0_wstrb(bar0_64.wstrb),
        .bar0_wvalid(bar0_64.wvalid),
        
        .bar1_araddr(bar1_64.araddr),
        .bar1_arprot(bar1_64.arprot),
        .bar1_arready(bar1_64.arready),
        .bar1_arvalid(bar1_64.arvalid),
        .bar1_awaddr(bar1_64.awaddr),
        .bar1_awprot(bar1_64.awprot),
        .bar1_awready(bar1_64.awready),
        .bar1_awvalid(bar1_64.awvalid),
        .bar1_bready(bar1_64.bready),
        .bar1_bresp(bar1_64.bresp),
        .bar1_bvalid(bar1_64.bvalid),
        .bar1_rdata(bar1_64.rdata),
        .bar1_rready(bar1_64.rready),
        .bar1_rresp(bar1_64.rresp),
        .bar1_rvalid(bar1_64.rvalid),
        .bar1_wdata(bar1_64.wdata),
        .bar1_wready(bar1_64.wready),
        .bar1_wstrb(bar1_64.wstrb),
        .bar1_wvalid(bar1_64.wvalid),
        
        .bar2_araddr(bar2_64.araddr),
        .bar2_arprot(bar2_64.arprot),
        .bar2_arready(bar2_64.arready),
        .bar2_arvalid(bar2_64.arvalid),
        .bar2_awaddr(bar2_64.awaddr),
        .bar2_awprot(bar2_64.awprot),
        .bar2_awready(bar2_64.awready),
        .bar2_awvalid(bar2_64.awvalid),
        .bar2_bready(bar2_64.bready),
        .bar2_bresp(bar2_64.bresp),
        .bar2_bvalid(bar2_64.bvalid),
        .bar2_rdata(bar2_64.rdata),
        .bar2_rready(bar2_64.rready),
        .bar2_rresp(bar2_64.rresp),
        .bar2_rvalid(bar2_64.rvalid),
        .bar2_wdata(bar2_64.wdata),
        .bar2_wready(bar2_64.wready),
        .bar2_wstrb(bar2_64.wstrb),
        .bar2_wvalid(bar2_64.wvalid),
        
        `ifndef SYNTHESIS
        `ifdef PCIE_PIPE_STACK
        .pcie_ext_pipe_commands_in(common_commands_out),
        .pcie_ext_pipe_rx_0(pipe_tx_0_sigs),
        .pcie_ext_pipe_rx_1(pipe_tx_1_sigs),
        .pcie_ext_pipe_rx_2(pipe_tx_2_sigs),
        .pcie_ext_pipe_rx_3(pipe_tx_3_sigs),
        .pcie_ext_pipe_rx_4(pipe_tx_4_sigs),
        .pcie_ext_pipe_rx_5(pipe_tx_5_sigs),
        .pcie_ext_pipe_rx_6(pipe_tx_6_sigs),
        .pcie_ext_pipe_rx_7(pipe_tx_7_sigs),
        .pcie_ext_pipe_commands_out(common_commands_in),
        .pcie_ext_pipe_tx_0(pipe_rx_0_sigs),
        .pcie_ext_pipe_tx_1(pipe_rx_1_sigs),
        .pcie_ext_pipe_tx_2(pipe_rx_2_sigs),
        .pcie_ext_pipe_tx_3(pipe_rx_3_sigs),
        .pcie_ext_pipe_tx_4(pipe_rx_4_sigs),
        .pcie_ext_pipe_tx_5(pipe_rx_5_sigs),
        .pcie_ext_pipe_tx_6(pipe_rx_6_sigs),
        .pcie_ext_pipe_tx_7(pipe_rx_7_sigs),
        `endif //PCIE_FULL_STACK 
        `endif //SYNTHESIS 
        
        `ifdef SYNTHESIS
        .pcie_7x_mgt_txp(pcie_7x_mgt_txp),
        .pcie_7x_mgt_txn(pcie_7x_mgt_txn),
        .pcie_7x_mgt_rxp(pcie_7x_mgt_rxp),
        .pcie_7x_mgt_rxn(pcie_7x_mgt_rxn),
        `endif //SYNTHESIS 

        .pcie_qpll_drp_0_clk(pcie_qpll_drp_clk),
        .pcie_qpll_drp_0_crscode(pcie_qpll_drp_crscode),
        .pcie_qpll_drp_0_done(pcie_qpll_drp_done),
        .pcie_qpll_drp_0_fsm(pcie_qpll_drp_fsm),
        .pcie_qpll_drp_0_gen3(pcie_qpll_drp_gen3),
        .pcie_qpll_drp_0_ovrd(pcie_qpll_drp_ovrd),
        .pcie_qpll_drp_0_qplld(pcie_qpll_drp_qplld), // PD
        .pcie_qpll_drp_0_qplllock(pcie_qpll_drp_qplllock), // LOCK
        .pcie_qpll_drp_0_qplloutclk(pcie_qpll_drp_qplloutclk), // OUTCLK
        .pcie_qpll_drp_0_qplloutrefclk(pcie_qpll_drp_qplloutrefclk), // OUTREFCLK
        .pcie_qpll_drp_0_qpllreset(pcie_qpll_drp_qpllreset), // RESET
        .pcie_qpll_drp_0_reset(pcie_qpll_drp_reset),
        .pcie_qpll_drp_0_rst_n(pcie_qpll_drp_rst_n),
        .pcie_qpll_drp_0_start(pcie_qpll_drp_start)
    );

    assign DRP_CLK = pcie_qpll_drp_clk;

    qpll_drp drp(
        //---------- Input -------------------------
        .DRP_CLK                        (pcie_qpll_drp_clk),
        .DRP_RST_N                      (!pcie_qpll_drp_rst_n),
        .DRP_OVRD                       (pcie_qpll_drp_ovrd),
        .DRP_GEN3                       (&pcie_qpll_drp_gen3),
        .DRP_QPLLLOCK                   (pcie_qpll_drp_qplllock),
        .DRP_START                      (pcie_qpll_drp_start),
        .DRP_DO                         (DRP_DO),
        .DRP_RDY                        (DRP_RDY),
                                                                                                            
        //----------           Output ------------------------
        .DRP_ADDR                       (DRP_ADDR),
        .DRP_EN                         (DRP_EN),
        .DRP_DI                         (DRP_DI),
        .DRP_WE                         (DRP_WE),
        .DRP_DONE                       (pcie_qpll_drp_done),
        .DRP_QPLLRESET                  (pcie_qpll_drp_reset),
        .DRP_CRSCODE                    (pcie_qpll_drp_crscode),
        .DRP_FSM                        (pcie_qpll_drp_fsm)
    );

    axi4_lite_dw_translator bar0_t_i(
        .m(bar0_64),
        .s(bar0)
    );
    
    axi4_lite_dw_translator bar1_t_i(
        .m(bar1_64),
        .s(bar1)
    );
    
    axi4_lite_dw_translator bar2_t_i(
        .m(bar2_64),
        .s(bar2)
    );
    
    `else // __NEED_PCI_IP
    axi_pcie_model axi_pcie_model_i(
        .bar0(bar0),
        .bar1(bar1),
        .bar2(bar2),

        .REFCLK(REFCLK),
        .PERST(PERST),
        .bar_clk(bar_clk),
        .bar_aresetn(bar_aresetn)
    );
    `endif // __NEED_PCI_IP
endmodule


