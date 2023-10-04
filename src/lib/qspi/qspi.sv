`include "axi4_lite_if.svh"

module axi4_lite_qspi
#(
    parameter AW           = 10,
    parameter DW           = 32,
    parameter SPI_W        = 4,
    parameter DUMMY_CYCLES = 4
)
(
    input  logic              aclk,
    input  logic              aresetn,
    input  logic              oclk,
    output logic              idle,

    axi4_lite_if.s  bus,    
    
    output logic              SCK,
    output logic              CSn,
    input  logic  [SPI_W-1:0] MISO,
    output logic  [SPI_W-1:0] MOSI

);
    logic [  AW-1:0] address;
    logic            read;
    logic            write;
    logic [     0:0] burstcount;
    logic [  DW-1:0] writedata;
    logic [DW/8-1:0] byteenable;
    logic            waitrequest;
    logic [  DW-1:0] readdata;
    logic            readdatavalid;


    axi2avmm axi2avmm_m(
        .s_axi_aclk(aclk),
        .s_axi_aresetn(arsetn),

        .s_axi_awaddr(bus.awaddr),
        .s_axi_awvalid(bus.awvalid),
        .s_axi_awready(bus.awready),
        .s_axi_wdata(bus.wdata),
        .s_axi_wstrb(bus.wstrb),
        .s_axi_wvalid(bus.wvalid),
        .s_axi_wready(bus.wready),
        .s_axi_bresp(bus.bresp),
        .s_axi_bvalid(bus.bvalid),
        .s_axi_bready(bus.bready),
        .s_axi_araddr(bus.araddr),
        .s_axi_arvalid(bus.arvalid),
        .s_axi_arready(bus.arready),
        .s_axi_rdata(bus.rdata),
        .s_axi_rresp(bus.rresp),
        .s_axi_rvalid(bus.rvalid),
        .s_axi_rready(bus.rready),

        .avm_address(address),
        .avm_write(write),
        .avm_read(read),
        .avm_byteenable(byteenable),
        .avm_writedata(writedata),
        .avm_readdata(readdata),
        .avm_readdatavalid(readdatavalid),
        .avm_burstcount(burstcount),
        .avm_waitrequest(waitrequest)
    );

endmodule 