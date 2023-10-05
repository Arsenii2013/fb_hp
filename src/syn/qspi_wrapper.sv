`timescale 1ns/1ns

`include "axi4_lite_if.svh"
`include "system.svh"

module qspi_wrapper
(
    input  logic       aclk,
    input  logic       aresetn,
    axi4_lite_if.s     ps_bus,
    axi4_lite_if.s     pcie_bus,

    input  logic       spi_aclk,
    input  logic       spi_oclk,
    input  logic       spi_aresetn,
    
    output logic       SCK,
    output logic       CSn,
    input  logic [3:0] MISO,
    output logic [3:0] MOSI

);

    axi4_lite_if #(.DW(32), .AW(32)) spi_bus_aclk();
    axi4_lite_if #(.DW(32), .AW(32)) spi_bus_spi_aclk();


    qspi_crossbar spi_crossbar_m(
        .aclk(aclk),
        .aresetn(aresetn),

        .s_axi_awaddr({ps_bus.awaddr, pcie_bus.awaddr}),
        .s_axi_awprot({ps_bus.awprot, pcie_bus.awprot}),
        .s_axi_awvalid({ps_bus.awvalid, pcie_bus.awvalid}),
        .s_axi_awready({ps_bus.awready, pcie_bus.awready}),
        .s_axi_wdata({ps_bus.wdata, pcie_bus.wdata}),
        .s_axi_wstrb({ps_bus.wstrb, pcie_bus.wstrb}),
        .s_axi_wvalid({ps_bus.wvalid, pcie_bus.wvalid}),
        .s_axi_wready({ps_bus.wready, pcie_bus.wready}),
        .s_axi_bresp({ps_bus.bresp, pcie_bus.bresp}),
        .s_axi_bvalid({ps_bus.bvalid, pcie_bus.bvalid}),
        .s_axi_bready({ps_bus.bready, pcie_bus.bready}),
        .s_axi_araddr({ps_bus.araddr, pcie_bus.araddr}),
        .s_axi_arprot({ps_bus.arprot, pcie_bus.arprot}),
        .s_axi_arvalid({ps_bus.arvalid, pcie_bus.arvalid}),
        .s_axi_arready({ps_bus.arready, pcie_bus.arready}),
        .s_axi_rdata({ps_bus.rdata, pcie_bus.rdata}),
        .s_axi_rresp({ps_bus.rresp, pcie_bus.rresp}),
        .s_axi_rvalid({ps_bus.rvalid, pcie_bus.rvalid}),
        .s_axi_rready({ps_bus.rready, pcie_bus.rready}),

        .m_axi_awaddr(spi_bus_aclk.awaddr),
        .m_axi_awprot(spi_bus_aclk.awprot),
        .m_axi_awvalid(spi_bus_aclk.awvalid),
        .m_axi_awready(spi_bus_aclk.awready),
        .m_axi_wdata(spi_bus_aclk.wdata),
        .m_axi_wstrb(spi_bus_aclk.wstrb),
        .m_axi_wvalid(spi_bus_aclk.wvalid),
        .m_axi_wready(spi_bus_aclk.wready),
        .m_axi_bresp(spi_bus_aclk.bresp),
        .m_axi_bvalid(spi_bus_aclk.bvalid),
        .m_axi_bready(spi_bus_aclk.bready),
        .m_axi_araddr(spi_bus_aclk.araddr),
        .m_axi_arprot(spi_bus_aclk.arprot),
        .m_axi_arvalid(spi_bus_aclk.arvalid),
        .m_axi_arready(spi_bus_aclk.arready),
        .m_axi_rdata(spi_bus_aclk.rdata),
        .m_axi_rresp(spi_bus_aclk.rresp),
        .m_axi_rvalid(spi_bus_aclk.rvalid),
        .m_axi_rready(spi_bus_aclk.rready)
    );

    qspi_clock_converter spi_clock_converter_m(
        .s_axi_awaddr(spi_bus_aclk.awaddr),
        .s_axi_awprot(spi_bus_aclk.awprot),
        .s_axi_awvalid(spi_bus_aclk.awvalid),
        .s_axi_awready(spi_bus_aclk.awready),
        .s_axi_wdata(spi_bus_aclk.wdata),
        .s_axi_wstrb(spi_bus_aclk.wstrb),
        .s_axi_wvalid(spi_bus_aclk.wvalid),
        .s_axi_wready(spi_bus_aclk.wready),
        .s_axi_bresp(spi_bus_aclk.bresp),
        .s_axi_bvalid(spi_bus_aclk.bvalid),
        .s_axi_bready(spi_bus_aclk.bready),
        .s_axi_araddr(spi_bus_aclk.araddr),
        .s_axi_arprot(spi_bus_aclk.arprot),
        .s_axi_arvalid(spi_bus_aclk.arvalid),
        .s_axi_arready(spi_bus_aclk.arready),
        .s_axi_rdata(spi_bus_aclk.rdata),
        .s_axi_rresp(spi_bus_aclk.rresp),
        .s_axi_rvalid(spi_bus_aclk.rvalid),
        .s_axi_rready(spi_bus_aclk.rready),

        .m_axi_awaddr(spi_bus_spi_aclk.awaddr),
        .m_axi_awprot(spi_bus_spi_aclk.awprot),
        .m_axi_awvalid(spi_bus_spi_aclk.awvalid),
        .m_axi_awready(spi_bus_spi_aclk.awready),
        .m_axi_wdata(spi_bus_spi_aclk.wdata),
        .m_axi_wstrb(spi_bus_spi_aclk.wstrb),
        .m_axi_wvalid(spi_bus_spi_aclk.wvalid),
        .m_axi_wready(spi_bus_spi_aclk.wready),
        .m_axi_bresp(spi_bus_spi_aclk.bresp),
        .m_axi_bvalid(spi_bus_spi_aclk.bvalid),
        .m_axi_bready(spi_bus_spi_aclk.bready),
        .m_axi_araddr(spi_bus_spi_aclk.araddr),
        .m_axi_arprot(spi_bus_spi_aclk.arprot),
        .m_axi_arvalid(spi_bus_spi_aclk.arvalid),
        .m_axi_arready(spi_bus_spi_aclk.arready),
        .m_axi_rdata(spi_bus_spi_aclk.rdata),
        .m_axi_rresp(spi_bus_spi_aclk.rresp),
        .m_axi_rvalid(spi_bus_spi_aclk.rvalid),
        .m_axi_rready(spi_bus_spi_aclk.rready)
    );


    hs_spi_master_axi_m
    #(
        .AW (10),
        .DW (32),
        .SPI_W (4),
        .DUMMY_CYCLES (4)
    )
    hs_spi_m
    (
        .aclk(spi_aclk),
        .aresetn(spi_aresetn),
        .oclk(spi_oclk),
        .idle(),
        .bus_axi(spi_bus_spi_aclk),
        .SCK(SCK),
        .CSn(CSn),
        .MISO(MISO),
        .MOSI(MOSI)
    );
endmodule 