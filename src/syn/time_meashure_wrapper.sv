`timescale 1 ns / 1 ps

`include "axi_if.svh"

module time_meashure_wrapper 
#(
    parameter AW = 4,
    parameter DW = 32
)
(
    input logic aclk,
    input logic aresetn,
    axi4_lite_if.s axi
);
    time_meashure
    #(
        .C_S_AXI_DATA_WIDTH(DW),
        .C_S_AXI_ADDR_WIDTH(AW)
    )
    wrapped
    (
        .S_AXI_ACLK(aclk),
        .S_AXI_ARESETN(aresetn),
        .S_AXI_AWADDR(axi.awaddr),
        .S_AXI_AWPROT(axi.awprot),
        .S_AXI_AWVALID(axi.awvalid),
        .S_AXI_AWREADY(axi.awready),
        .S_AXI_WDATA(axi.wdata),
        .S_AXI_WSTRB(axi.wstrb),
        .S_AXI_WVALID(axi.wvalid),
        .S_AXI_WREADY(axi.wready),
        .S_AXI_BRESP(axi.bresp),
        .S_AXI_BVALID(axi.bvalid),
        .S_AXI_BREADY(axi.bready),
        .S_AXI_ARADDR(axi.araddr),
        .S_AXI_ARPROT(axi.arprot),
        .S_AXI_ARVALID(axi.arvalid),
        .S_AXI_ARREADY(axi.arready),
        .S_AXI_RDATA(axi.rdata),
        .S_AXI_RRESP(axi.rresp),
        .S_AXI_RVALID(axi.rvalid),
        .S_AXI_RREADY(axi.rready)
    );

endmodule;
