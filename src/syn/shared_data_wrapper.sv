`include "top.svh"
`include "axi4_lite_if.svh"

module shared_data_rx_wrapper 
( 
    input  logic               clk,
    input  logic               rst,
    input  logic               aresetn,

    input  logic [7:0]         rx_data_in,
    input  logic               rx_isk_in,

    axi4_lite_if.s             axi_pci
);

    axi4_lite_if #(
    .AW        ( 32 ),
    .DW        ( FB_DW       )
    ) axi_shared_data[SHARED_MEM_COUNT]();

    axi4_lite_if #(
    .AW        ( 32 ),
    .DW        ( FB_DW       )
    ) axi_mem[SHARED_MEM_COUNT]();

    stream_decoder_m stream_decoder_i(
        .clk(clk),
        .rst(rst),
        .rx_data_in(rx_data_in),
        .rx_isk_in(rx_isk_in),
        .shared_data_out_i(axi_shared_data)
    );

    genvar i;
    generate
        for (i=0; i<SHARED_MEM_COUNT; i=i+1) begin : shared_data_axi_master
            qspi_crossbar 
            spi_crossbar_m(
                .aclk(clk),
                .aresetn(aresetn),

                .s_axi_awaddr({axi_pci.awaddr, axi_shared_data[i].awaddr}),
                .s_axi_awprot({axi_pci.awprot, axi_shared_data[i].awprot}),
                .s_axi_awvalid({axi_pci.awvalid, axi_shared_data[i].awvalid}),
                .s_axi_awready({axi_pci.awready, axi_shared_data[i].awready}),
                .s_axi_wdata({axi_pci.wdata, axi_shared_data[i].wdata}),
                .s_axi_wstrb({axi_pci.wstrb, axi_shared_data[i].wstrb}),
                .s_axi_wvalid({axi_pci.wvalid, axi_shared_data[i].wvalid}),
                .s_axi_wready({axi_pci.wready, axi_shared_data[i].wready}),
                .s_axi_bresp({axi_pci.bresp, axi_shared_data[i].bresp}),
                .s_axi_bvalid({axi_pci.bvalid, axi_shared_data[i].bvalid}),
                .s_axi_bready({axi_pci.bready, axi_shared_data[i].bready}),
                .s_axi_araddr({axi_pci.araddr, axi_shared_data[i].araddr}),
                .s_axi_arprot({axi_pci.arprot, axi_shared_data[i].arprot}),
                .s_axi_arvalid({axi_pci.arvalid, axi_shared_data[i].arvalid}),
                .s_axi_arready({axi_pci.arready, axi_shared_data[i].arready}),
                .s_axi_rdata({axi_pci.rdata, axi_shared_data[i].rdata}),
                .s_axi_rresp({axi_pci.rresp, axi_shared_data[i].rresp}),
                .s_axi_rvalid({axi_pci.rvalid, axi_shared_data[i].rvalid}),
                .s_axi_rready({axi_pci.rready, axi_shared_data[i].rready}),

                .m_axi_awaddr(axi_mem[i].awaddr),
                .m_axi_awprot(axi_mem[i].awprot),
                .m_axi_awvalid(axi_mem[i].awvalid),
                .m_axi_awready(axi_mem[i].awready),
                .m_axi_wdata(axi_mem[i].wdata),
                .m_axi_wstrb(axi_mem[i].wstrb),
                .m_axi_wvalid(axi_mem[i].wvalid),
                .m_axi_wready(axi_mem[i].wready),
                .m_axi_bresp(axi_mem[i].bresp),
                .m_axi_bvalid(axi_mem[i].bvalid),
                .m_axi_bready(axi_mem[i].bready),
                .m_axi_araddr(axi_mem[i].araddr),
                .m_axi_arprot(axi_mem[i].arprot),
                .m_axi_arvalid(axi_mem[i].arvalid),
                .m_axi_arready(axi_mem[i].arready),
                .m_axi_rdata(axi_mem[i].rdata),
                .m_axi_rresp(axi_mem[i].rresp),
                .m_axi_rvalid(axi_mem[i].rvalid),
                .m_axi_rready(axi_mem[i].rready)
            );

            mem_wrapper
            mem_i (
                .aclk(clk),
                .aresetn(aresetn),
                .axi(axi_mem[i]),
                .offset(0)
            );
        end
    endgenerate

endmodule