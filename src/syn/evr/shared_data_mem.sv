/*
    dual port memory
*/

module shared_data_mem(
    input  logic               clk,
    input  logic               aresetn,

    axi4_lite_if.s             mmr,
    axi4_lite_if.s             shared_data_in
);
    axi4_lite_if #(
        .AW        ( 32 ),
        .DW        ( FB_DW       )
    ) axi_mem();

    qspi_crossbar 
    spi_crossbar_m(
        .aclk(clk),
        .aresetn(aresetn),

        .s_axi_awaddr({mmr.awaddr, shared_data_in.awaddr}),
        .s_axi_awprot({mmr.awprot, shared_data_in.awprot}),
        .s_axi_awvalid({mmr.awvalid, shared_data_in.awvalid}),
        .s_axi_awready({mmr.awready, shared_data_in.awready}),
        .s_axi_wdata({mmr.wdata, shared_data_in.wdata}),
        .s_axi_wstrb({mmr.wstrb, shared_data_in.wstrb}),
        .s_axi_wvalid({mmr.wvalid, shared_data_in.wvalid}),
        .s_axi_wready({mmr.wready, shared_data_in.wready}),
        .s_axi_bresp({mmr.bresp, shared_data_in.bresp}),
        .s_axi_bvalid({mmr.bvalid, shared_data_in.bvalid}),
        .s_axi_bready({mmr.bready, shared_data_in.bready}),
        .s_axi_araddr({mmr.araddr, shared_data_in.araddr}),
        .s_axi_arprot({mmr.arprot, shared_data_in.arprot}),
        .s_axi_arvalid({mmr.arvalid, shared_data_in.arvalid}),
        .s_axi_arready({mmr.arready, shared_data_in.arready}),
        .s_axi_rdata({mmr.rdata, shared_data_in.rdata}),
        .s_axi_rresp({mmr.rresp, shared_data_in.rresp}),
        .s_axi_rvalid({mmr.rvalid, shared_data_in.rvalid}),
        .s_axi_rready({mmr.rready, shared_data_in.rready}),

        .m_axi_awaddr(axi_mem.awaddr),
        .m_axi_awprot(axi_mem.awprot),
        .m_axi_awvalid(axi_mem.awvalid),
        .m_axi_awready(axi_mem.awready),
        .m_axi_wdata(axi_mem.wdata),
        .m_axi_wstrb(axi_mem.wstrb),
        .m_axi_wvalid(axi_mem.wvalid),
        .m_axi_wready(axi_mem.wready),
        .m_axi_bresp(axi_mem.bresp),
        .m_axi_bvalid(axi_mem.bvalid),
        .m_axi_bready(axi_mem.bready),
        .m_axi_araddr(axi_mem.araddr),
        .m_axi_arprot(axi_mem.arprot),
        .m_axi_arvalid(axi_mem.arvalid),
        .m_axi_arready(axi_mem.arready),
        .m_axi_rdata(axi_mem.rdata),
        .m_axi_rresp(axi_mem.rresp),
        .m_axi_rvalid(axi_mem.rvalid),
        .m_axi_rready(axi_mem.rready)
    );

    mem_wrapper
    mem_i (
        .aclk(clk),
        .aresetn(aresetn),
        .axi(axi_mem),
        .offset(0)
    );

endmodule