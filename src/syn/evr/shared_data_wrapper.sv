`include "top.svh"
`include "axi4_lite_if.svh"

module shared_data_rx_wrapper 
( 
    input  logic               clk,
    input  logic               rst,
    input  logic               aresetn,

    input  logic [7:0]         rx_data_in,
    input  logic               rx_isk_in,

    input  logic               pci_clk,
    axi4_lite_if.s             axi_pci
);

    axi4_lite_if #(
    .AW        ( 32 ),
    .DW        ( FB_DW       )
    ) axi_shared_data[SHARED_MEM_COUNT]();

    axi4_lite_if #(
    .AW        ( 32 ),
    .DW        ( FB_DW       )
    ) axi_mem();

    axi4_lite_if #(
    .AW        ( 32 ),
    .DW        ( FB_DW       )
    ) axi_pci_sfp_clk();

    stream_decoder_m stream_decoder_i(
        .clk(clk),
        .rst(rst),
        .rx_data_in(rx_data_in),
        .rx_isk_in(rx_isk_in),
        .shared_data_out_i(axi_shared_data)
    );

    qspi_clock_converter spi_clock_converter_m(
        .s_axi_aclk(pci_clk),
        .s_axi_aresetn(aresetn),
        .s_axi_awaddr(axi_pci.awaddr),
        .s_axi_awprot(axi_pci.awprot),
        .s_axi_awvalid(axi_pci.awvalid),
        .s_axi_awready(axi_pci.awready),
        .s_axi_wdata(axi_pci.wdata),
        .s_axi_wstrb(axi_pci.wstrb),
        .s_axi_wvalid(axi_pci.wvalid),
        .s_axi_wready(axi_pci.wready),
        .s_axi_bresp(axi_pci.bresp),
        .s_axi_bvalid(axi_pci.bvalid),
        .s_axi_bready(axi_pci.bready),
        .s_axi_araddr(axi_pci.araddr),
        .s_axi_arprot(axi_pci.arprot),
        .s_axi_arvalid(axi_pci.arvalid),
        .s_axi_arready(axi_pci.arready),
        .s_axi_rdata(axi_pci.rdata),
        .s_axi_rresp(axi_pci.rresp),
        .s_axi_rvalid(axi_pci.rvalid),
        .s_axi_rready(axi_pci.rready),

        .m_axi_aclk(clk),
        .m_axi_aresetn(aresetn),
        .m_axi_awaddr(axi_pci_sfp_clk.awaddr),
        .m_axi_awprot(axi_pci_sfp_clk.awprot),
        .m_axi_awvalid(axi_pci_sfp_clk.awvalid),
        .m_axi_awready(axi_pci_sfp_clk.awready),
        .m_axi_wdata(axi_pci_sfp_clk.wdata),
        .m_axi_wstrb(axi_pci_sfp_clk.wstrb),
        .m_axi_wvalid(axi_pci_sfp_clk.wvalid),
        .m_axi_wready(axi_pci_sfp_clk.wready),
        .m_axi_bresp(axi_pci_sfp_clk.bresp),
        .m_axi_bvalid(axi_pci_sfp_clk.bvalid),
        .m_axi_bready(axi_pci_sfp_clk.bready),
        .m_axi_araddr(axi_pci_sfp_clk.araddr),
        .m_axi_arprot(axi_pci_sfp_clk.arprot),
        .m_axi_arvalid(axi_pci_sfp_clk.arvalid),
        .m_axi_arready(axi_pci_sfp_clk.arready),
        .m_axi_rdata(axi_pci_sfp_clk.rdata),
        .m_axi_rresp(axi_pci_sfp_clk.rresp),
        .m_axi_rvalid(axi_pci_sfp_clk.rvalid),
        .m_axi_rready(axi_pci_sfp_clk.rready)
    );

    genvar i;
    generate
        for (i=0; i<SHARED_MEM_COUNT; i=i+1) begin : shared_data_axi_master
            qspi_crossbar 
            spi_crossbar_m(
                .aclk(clk),
                .aresetn(aresetn),

                .s_axi_awaddr({axi_pci_sfp_clk.awaddr, axi_shared_data[i].awaddr}),
                .s_axi_awprot({axi_pci_sfp_clk.awprot, axi_shared_data[i].awprot}),
                .s_axi_awvalid({axi_pci_sfp_clk.awvalid, axi_shared_data[i].awvalid}),
                .s_axi_awready({axi_pci_sfp_clk.awready, axi_shared_data[i].awready}),
                .s_axi_wdata({axi_pci_sfp_clk.wdata, axi_shared_data[i].wdata}),
                .s_axi_wstrb({axi_pci_sfp_clk.wstrb, axi_shared_data[i].wstrb}),
                .s_axi_wvalid({axi_pci_sfp_clk.wvalid, axi_shared_data[i].wvalid}),
                .s_axi_wready({axi_pci_sfp_clk.wready, axi_shared_data[i].wready}),
                .s_axi_bresp({axi_pci_sfp_clk.bresp, axi_shared_data[i].bresp}),
                .s_axi_bvalid({axi_pci_sfp_clk.bvalid, axi_shared_data[i].bvalid}),
                .s_axi_bready({axi_pci_sfp_clk.bready, axi_shared_data[i].bready}),
                .s_axi_araddr({axi_pci_sfp_clk.araddr, axi_shared_data[i].araddr}),
                .s_axi_arprot({axi_pci_sfp_clk.arprot, axi_shared_data[i].arprot}),
                .s_axi_arvalid({axi_pci_sfp_clk.arvalid, axi_shared_data[i].arvalid}),
                .s_axi_arready({axi_pci_sfp_clk.arready, axi_shared_data[i].arready}),
                .s_axi_rdata({axi_pci_sfp_clk.rdata, axi_shared_data[i].rdata}),
                .s_axi_rresp({axi_pci_sfp_clk.rresp, axi_shared_data[i].rresp}),
                .s_axi_rvalid({axi_pci_sfp_clk.rvalid, axi_shared_data[i].rvalid}),
                .s_axi_rready({axi_pci_sfp_clk.rready, axi_shared_data[i].rready}),

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
        end
    endgenerate

endmodule