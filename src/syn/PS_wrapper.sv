`include "axi_if.svh"

module PS_wrapper(
    inout wire [14:0]  DDR_Addr,
    inout wire [2:0]   DDR_BankAddr,
    inout wire         DDR_CAS_n,
    inout wire         DDR_CKE,
    inout wire         DDR_CS_n,
    inout wire [3:0]   DDR_DM,
    inout wire [31:0]  DDR_DQ,
    inout wire [3:0]   DDR_DQS_n,
    inout wire [3:0]   DDR_DQS,
    inout wire         DDR_ODT,
    inout wire         DDR_RAS_n,
    inout wire         DDR_reset_n,
    inout wire         DDR_we_n,
    inout wire         DDR_VRN,
    inout wire         DDR_VRP,
    inout wire         DDR_Clk_n,
    inout wire         DDR_Clk,
    inout wire         DDR_DRSTB,
    inout wire         DDR_WEB,

    inout wire [53:0]  MIO,
    inout wire         PS_SRSTB,
    inout wire         PS_CLK,
    inout wire         PS_PORB,

    axi4_lite_if.m     GP0,
    axi4_lite_if.s     HP0,
    output logic       clock,
    output logic       aresetn,
    output logic       reset
   );

    wire GP0_ARVALID;
    wire GP0_AWVALID;
    wire GP0_BREADY;
    wire GP0_RREADY;
    wire GP0_WLAST;
    wire GP0_WVALID;
    wire GP0_ARID;
    wire GP0_AWID;
    wire GP0_WID;
    wire GP0_ARBURST;
    wire GP0_ARLOCK;
    wire GP0_ARSIZE;
    wire GP0_AWBURST;
    wire GP0_AWLOCK;
    wire GP0_AWSIZE;
    wire GP0_ARPROT;
    wire GP0_AWPROT;
    wire GP0_ARADDR;
    wire GP0_AWADDR;
    wire GP0_WDATA;
    wire GP0_ARCACHE;
    wire GP0_ARLEN;
    wire GP0_ARQOS;
    wire GP0_AWCACHE;
    wire GP0_AWLEN;
    wire GP0_AWQOS;
    wire GP0_WSTRB;
    wire GP0_ARREADY;
    wire GP0_AWREADY;
    wire GP0_BVALID;
    wire GP0_RLAST;
    wire GP0_RVALID;
    wire GP0_WREADY;
    wire GP0_BID;
    wire GP0_RID;
    wire GP0_BRESP;
    wire GP0_RRESP;
    wire GP0_RDATA;

    wire HP0_ARREADY;
    wire HP0_AWREADY;
    wire HP0_BVALID;
    wire HP0_RLAST;
    wire HP0_RVALID;
    wire HP0_WREADY;
    wire HP0_BRESP;
    wire HP0_RRESP;
    wire HP0_BID;
    wire HP0_RID;
    wire HP0_RDATA;
    wire HP0_RCOUNT;
    wire HP0_WCOUNT;
    wire HP0_RACOUNT;
    wire HP0_WACOUNT;
    wire HP0_ARVALID;
    wire HP0_AWVALID;
    wire HP0_BREADY;
    wire HP0_RDISSUECAP1_EN;
    wire HP0_RREADY;
    wire HP0_WLAST;
    wire HP0_WRISSUECAP1_EN;
    wire HP0_WVALID;
    wire HP0_ARBURST;
    wire HP0_ARLOCK;
    wire HP0_ARSIZE;
    wire HP0_AWBURST;
    wire HP0_AWLOCK;
    wire HP0_AWSIZE;
    wire HP0_ARPROT;
    wire HP0_AWPROT;
    wire HP0_ARADDR;
    wire HP0_AWADDR;
    wire HP0_ARCACHE;
    wire HP0_ARLEN;
    wire HP0_ARQOS;
    wire HP0_AWCACHE;
    wire HP0_AWLEN;
    wire HP0_AWQOS;
    wire HP0_ARID;
    wire HP0_AWID;
    wire HP0_WID;
    wire HP0_WDATA;
    wire HP0_WSTRB;

    wire PS_reset;

    PS PS_i(
        .M_AXI_GP0_ARVALID(GP0_ARVALID),
        .M_AXI_GP0_AWVALID(GP0_AWVALID),
        .M_AXI_GP0_BREADY(GP0_BREADY),
        .M_AXI_GP0_RREADY(GP0_RREADY),
        .M_AXI_GP0_WLAST(GP0_WLAST),
        .M_AXI_GP0_WVALID(GP0_WVALID),
        .M_AXI_GP0_ARID(GP0_ARID),
        .M_AXI_GP0_AWID(GP0_AWID),
        .M_AXI_GP0_WID(GP0_WID),
        .M_AXI_GP0_ARBURST(GP0_ARBURST),
        .M_AXI_GP0_ARLOCK(GP0_ARLOCK),
        .M_AXI_GP0_ARSIZE(GP0_ARSIZE),
        .M_AXI_GP0_AWBURST(GP0_AWBURST),
        .M_AXI_GP0_AWLOCK(GP0_AWLOCK),
        .M_AXI_GP0_AWSIZE(GP0_AWSIZE),
        .M_AXI_GP0_ARPROT(GP0_ARPROT),
        .M_AXI_GP0_AWPROT(GP0_AWPROT),
        .M_AXI_GP0_ARADDR(GP0_ARADDR),
        .M_AXI_GP0_AWADDR(GP0_AWADDR),
        .M_AXI_GP0_WDATA(GP0_WDATA),
        .M_AXI_GP0_ARCACHE(GP0_ARCACHE),
        .M_AXI_GP0_ARLEN(GP0_ARLEN),
        .M_AXI_GP0_ARQOS(GP0_ARQOS),
        .M_AXI_GP0_AWCACHE(GP0_AWCACHE),
        .M_AXI_GP0_AWLEN(GP0_AWLEN),
        .M_AXI_GP0_AWQOS(GP0_AWQOS),
        .M_AXI_GP0_WSTRB(GP0_WSTRB),
        .M_AXI_GP0_ACLK(clock),
        .M_AXI_GP0_ARREADY(GP0_ARREADY),
        .M_AXI_GP0_AWREADY(GP0_AWREADY),
        .M_AXI_GP0_BVALID(GP0_BVALID),
        .M_AXI_GP0_RLAST(GP0_RLAST),
        .M_AXI_GP0_RVALID(GP0_RVALID),
        .M_AXI_GP0_WREADY(GP0_WREADY),
        .M_AXI_GP0_BID(GP0_BID),
        .M_AXI_GP0_RID(GP0_RID),
        .M_AXI_GP0_BRESP(GP0_BRESP),
        .M_AXI_GP0_RRESP(GP0_RRESP),
        .M_AXI_GP0_RDATA(GP0_RDATA),

        .S_AXI_HP0_ARREADY(HP0_ARREADY),
        .S_AXI_HP0_AWREADY(HP0_AWREADY),
        .S_AXI_HP0_BVALID(HP0_BVALID),
        .S_AXI_HP0_RLAST(HP0_RLAST),
        .S_AXI_HP0_RVALID(HP0_RVALID),
        .S_AXI_HP0_WREADY(HP0_WREADY),
        .S_AXI_HP0_BRESP(HP0_BRESP),
        .S_AXI_HP0_RRESP(HP0_RRESP),
        .S_AXI_HP0_BID(HP0_BID),
        .S_AXI_HP0_RID(HP0_RID),
        .S_AXI_HP0_RDATA(HP0_RDATA),
        .S_AXI_HP0_RCOUNT(HP0_RCOUNT),
        .S_AXI_HP0_WCOUNT(HP0_WCOUNT),
        .S_AXI_HP0_RACOUNT(HP0_RACOUNT),
        .S_AXI_HP0_WACOUNT(HP0_WACOUNT),
        .S_AXI_HP0_ACLK(clock),
        .S_AXI_HP0_ARVALID(HP0_ARVALID),
        .S_AXI_HP0_AWVALID(HP0_AWVALID),
        .S_AXI_HP0_BREADY(HP0_BREADY),
        .S_AXI_HP0_RDISSUECAP1_EN(HP0_RDISSUECAP1_EN),
        .S_AXI_HP0_RREADY(HP0_RREADY),
        .S_AXI_HP0_WLAST(HP0_WLAST),
        .S_AXI_HP0_WRISSUECAP1_EN(HP0_WRISSUECAP1_EN),
        .S_AXI_HP0_WVALID(HP0_WVALID),
        .S_AXI_HP0_ARBURST(HP0_ARBURST),
        .S_AXI_HP0_ARLOCK(HP0_ARLOCK),
        .S_AXI_HP0_ARSIZE(HP0_ARSIZE),
        .S_AXI_HP0_AWBURST(HP0_AWBURST),
        .S_AXI_HP0_AWLOCK(HP0_AWLOCK),
        .S_AXI_HP0_AWSIZE(HP0_AWSIZE),
        .S_AXI_HP0_ARPROT(HP0_ARPROT),
        .S_AXI_HP0_AWPROT(HP0_AWPROT),
        .S_AXI_HP0_ARADDR(HP0_ARADDR),
        .S_AXI_HP0_AWADDR(HP0_AWADDR),
        .S_AXI_HP0_ARCACHE(HP0_ARCACHE),
        .S_AXI_HP0_ARLEN(HP0_ARLEN),
        .S_AXI_HP0_ARQOS(HP0_ARQOS),
        .S_AXI_HP0_AWCACHE(HP0_AWCACHE),
        .S_AXI_HP0_AWLEN(HP0_AWLEN),
        .S_AXI_HP0_AWQOS(HP0_AWQOS),
        .S_AXI_HP0_ARID(HP0_ARID),
        .S_AXI_HP0_AWID(HP0_AWID),
        .S_AXI_HP0_WID(HP0_WID),
        .S_AXI_HP0_WDATA(HP0_WDATA),
        .S_AXI_HP0_WSTRB(HP0_WSTRB),

        .FCLK_CLK0(clock),
        .FCLK_RESET0_N(PS_reset),

        .MIO,
        .DDR_CAS_n,
        .DDR_CKE,
        .DDR_Clk_n,
        .DDR_Clk,
        .DDR_CS_n,
        .DDR_DRSTB,
        .DDR_ODT,
        .DDR_RAS_n,
        .DDR_WEB,
        .DDR_BankAddr,
        .DDR_Addr,
        .DDR_VRN,
        .DDR_VRP,
        .DDR_DM,
        .DDR_DQ,
        .DDR_DQS_n,
        .DDR_DQS,
        .PS_SRSTB,
        .PS_CLK,
        .PS_PORB
    );

    GP_protocol_converter 
    GP_protocol_converter_i (
        .aclk(clock),
        .aresetn,

        .s_axi_awaddr(GP0_AWADDR),
        .s_axi_awlen(GP0_AWLEN),
        .s_axi_awsize(GP0_AWSIZE),
        .s_axi_awburst(GP0_AWBURST),
        .s_axi_awlock(GP0_AWLOCK),
        .s_axi_awcache(GP0_AWCACHE),
        .s_axi_awprot(GP0_AWPROT),
        .s_axi_awqos(GP0_AWQOS),
        .s_axi_awvalid(GP0_AWVALID),
        .s_axi_awready(GP0_AWREADY),
        .s_axi_wdata(GP0_WDATA),
        .s_axi_wstrb(GP0_WSTRB),
        .s_axi_wlast(GP0_WLAST),
        .s_axi_wvalid(GP0_WVALID),
        .s_axi_wready(GP0_WREADY),
        .s_axi_bresp(GP0_BRESP),
        .s_axi_bvalid(GP0_BVALID),
        .s_axi_bready(GP0_BREADY),
        .s_axi_araddr(GP0_ARADDR),
        .s_axi_arlen(GP0_ARLEN),
        .s_axi_arsize(GP0_ARSIZE),
        .s_axi_arburst(GP0_ARBURST),
        .s_axi_arlock(GP0_ARLOCK),
        .s_axi_arcache(GP0_ARCACHE),
        .s_axi_arprot(GP0_ARPROT),
        .s_axi_arqos(GP0_ARQOS),
        .s_axi_arvalid(GP0_ARVALID),
        .s_axi_arready(GP0_ARREADY),
        .s_axi_rdata(GP0_RDATA),
        .s_axi_rresp(GP0_RRESP),
        .s_axi_rlast(GP0_RLAST),
        .s_axi_rvalid(GP0_RVALID),
        .s_axi_rready(GP0_RREADY),
        .s_axi_arid(GP0_ARID),
        .s_axi_awid(GP0_AWID),
        .s_axi_wid(GP0_WID),
        .s_axi_bid(GP0_BID),
        .s_axi_rid(GP0_RID),

        .m_axi_awaddr(GP0.awaddr),
        .m_axi_awprot(GP0.awprot),
        .m_axi_awvalid(GP0.awvalid),
        .m_axi_awready(GP0.awready),
        .m_axi_wdata(GP0.wdata),
        .m_axi_wstrb(GP0.wstrb),
        .m_axi_wvalid(GP0.wvalid),
        .m_axi_wready(GP0.wready),
        .m_axi_bresp(GP0.bresp),
        .m_axi_bvalid(GP0.bvalid),
        .m_axi_bready(GP0.bready),
        .m_axi_araddr(GP0.araddr),
        .m_axi_arprot(GP0.arprot),
        .m_axi_arvalid(GP0.arvalid),
        .m_axi_arready(GP0.arready),
        .m_axi_rdata(GP0.rdata),
        .m_axi_rresp(GP0.rresp),
        .m_axi_rvalid(GP0.rvalid),
        .m_axi_rready(GP0.rready)
    );
    
    assign HP0_ARID = 0;
    assign HP0_AWID = 0;
    assign HP0_WID = 0;
    assign HP0_BID = 0;
    assign HP0_RID = 0;
    
    
    HP_protocol_converter 
    HP_protocol_converter_i (
        .aclk(clock),
        .aresetn,

        .s_axi_awaddr(HP0.awaddr),
        .s_axi_awprot(HP0.awprot),
        .s_axi_awvalid(HP0.awvalid),
        .s_axi_awready(HP0.awready),
        .s_axi_wdata(HP0.wdata),
        .s_axi_wstrb(HP0.wstrb),
        .s_axi_wvalid(HP0.wvalid),
        .s_axi_wready(HP0.wready),
        .s_axi_bresp(HP0.bresp),
        .s_axi_bvalid(HP0.bvalid),
        .s_axi_bready(HP0.bready),
        .s_axi_araddr(HP0.araddr),
        .s_axi_arprot(HP0.arprot),
        .s_axi_arvalid(HP0.arvalid),
        .s_axi_arready(HP0.arready),
        .s_axi_rdata(HP0.rdata),
        .s_axi_rresp(HP0.rresp),
        .s_axi_rvalid(HP0.rvalid),
        .s_axi_rready(HP0.rready),

        .m_axi_awaddr(HP0_AWADDR),
        .m_axi_awlen(HP0_AWLEN),
        .m_axi_awsize(HP0_AWSIZE),
        .m_axi_awburst(HP0_AWBURST),
        .m_axi_awlock(HP0_AWLOCK),
        .m_axi_awcache(HP0_AWCACHE),
        .m_axi_awprot(HP0_AWPROT),
        .m_axi_awqos(HP0_AWQOS),
        .m_axi_awvalid(HP0_AWVALID),
        .m_axi_awready(HP0_AWREADY),
        .m_axi_wdata(HP0_WDATA),
        .m_axi_wstrb(HP0_WSTRB),
        .m_axi_wlast(HP0_WLAST),
        .m_axi_wvalid(HP0_WVALID),
        .m_axi_wready(HP0_WREADY),
        .m_axi_bresp(HP0_BRESP),
        .m_axi_bvalid(HP0_BVALID),
        .m_axi_bready(HP0_BREADY),
        .m_axi_araddr(HP0_ARADDR),
        .m_axi_arlen(HP0_ARLEN),
        .m_axi_arsize(HP0_ARSIZE),
        .m_axi_arburst(HP0_ARBURST),
        .m_axi_arlock(HP0_ARLOCK),
        .m_axi_arcache(HP0_ARCACHE),
        .m_axi_arprot(HP0_ARPROT),
        .m_axi_arqos(HP0_ARQOS),
        .m_axi_arvalid(HP0_ARVALID),
        .m_axi_arready(HP0_ARREADY),
        .m_axi_rdata(HP0_RDATA),
        .m_axi_rresp(HP0_RRESP),
        .m_axi_rlast(HP0_RLAST),
        .m_axi_rvalid(HP0_RVALID),
        .m_axi_rready(HP0_RREADY)
    );

    proc_reset
    proc_reset_i(
        .slowest_sync_clk(clock),
        .ext_reset_in(PS_reset),
        .peripheral_reset(reset),
        .peripheral_aresetn(aresetn),
        .mb_debug_sys_rst(0),
        .aux_reset_in(1),
        .dcm_locked(1)
    );

endmodule