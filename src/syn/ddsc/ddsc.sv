

`include "axi4_lite_if.svh"

module ddsc_avmm_m import hp_pkg::*;
#(
    parameter NUMBER          = 0,
    parameter AW              = 12,
    parameter DW              = 64,
    parameter EVENT_BUS_W     = 8,
    parameter DESC_ITEM_DW    = 32,
    parameter DESC_ITEM_COUNT = 16,
    parameter B_FIELD_W       = 32,
    parameter TIME_W          = 64,
    parameter CLK_PRD         = 10
)
(
    input  logic                    clk,
    input  logic                    rst,

    axi4_lite_if.s                  mmr_i,
    axi4_lite_if.s                  conv_tbl_i,
    axi4_lite_if.s                  desc_tbl_i,

    input  logic                    sync,
    input  logic [DESC_ITEM_DW-1:0] sync_prd,
    input  logic [ EVENT_BUS_W-1:0] ev,

    input  logic [   B_FIELD_W-1:0] b_field,
    input  logic                    b_ready,

    ddsc_if.out                     out,
    axi4_lite_if.s                  shared_in_i
);

    avmm_if #(.AW(AW), .DW(DW), .MAX_BURST(1)) mmr_i_avmm();
    avmm_if #(.AW(AW), .DW(DW), .MAX_BURST(1)) conv_tbl_i_avmm();
    avmm_if #(.AW(AW), .DW(DW), .MAX_BURST(1)) desc_tbl_i_avmm();
    avmm_if #(.AW(AW), .DW(DW), .MAX_BURST(1)) shared_in_i_avmm();
    avmm_if #(.AW(AW), .DW(DW), .MAX_BURST(1)) shared_out_i_avmm();

    axi2avmm_wrapper axi2avmm_mmr(
        .clk(clk),
        .aresetn(!rst),
        .in(mmr_i),
        .out(mmr_i_avmm)
    );
    axi2avmm_wrapper axi2avmm_conv(
        .clk(clk),
        .aresetn(!rst),
        .in(conv_tbl_i),
        .out(conv_tbl_i_avmm)
    );
    axi2avmm_wrapper axi2avmm_desc(
        .clk(clk),
        .aresetn(!rst),
        .in(desc_tbl_i),
        .out(desc_tbl_i_avmm)
    );
    axi2avmm_wrapper axi2avmm_shared(
        .clk(clk),
        .aresetn(!rst),
        .in(shared_in_i),
        .out(shared_in_i_avmm)
    );


    ddsc_avmm_m #(
        .NUMBER(NUMBER),
        .AW(AW),
        .DW(DW),
        .MAX_BURST(1),
        .EVENT_BUS_W(EVENT_BUS_W),
        .DESC_ITEM_DW(DESC_ITEM_DW),
        .DESC_ITEM_COUNT(DESC_ITEM_COUNT),
        .B_FIELD_W(B_FIELD_W),
        .TIME_W(TIME_W),
        .CLK_PRD(CLK_PRD)
    ) ddsc_avmm (
        .clk(clk),
        .rst(rst),
        .mmr_i(mmr_i_avmm),
        .conv_tbl_i(conv_tbl_i_avmm),
        .desc_tbl_i(desc_tbl_i_avmm),
        .sync(sync),
        .sync_prd(sync_prd),
        .ev(ev),
        .b_field(b_field),
        .b_ready(b_ready),
        .out(out),
        .shared_in_i(shared_in_i_avmm)
    );



endmodule


module axi2avmm_wrapper(
    input logic    clk,
    input logic    arsetn,
    axi4_lite_if.s in,
    avmm_if.master out
);

    axi2avmm axi2avmm_m(
    .s_axi_aclk(clk),
    .s_axi_aresetn(aresetn),

    .s_axi_awaddr(in.awaddr),
    .s_axi_awvalid(in.awvalid),
    .s_axi_awready(in.awready),
    .s_axi_wdata(in.wdata),
    .s_axi_wstrb(in.wstrb),
    .s_axi_wvalid(in.wvalid),
    .s_axi_wready(in.wready),
    .s_axi_bresp(in.bresp),
    .s_axi_bvalid(in.bvalid),
    .s_axi_bready(in.bready),
    .s_axi_araddr(in.araddr),
    .s_axi_arvalid(in.arvalid),
    .s_axi_arready(in.arready),
    .s_axi_rdata(in.rdata),
    .s_axi_rresp(in.rresp),
    .s_axi_rvalid(in.rvalid),
    .s_axi_rready(in.rready),

    .avm_address(out.address),
    .avm_write(out.write),
    .avm_read(out.read),
    .avm_byteenable(out.byteenable),
    .avm_writedata(out.writedata),
    .avm_readdata(out.readdata),
    .avm_readdatavalid(out.readdatavalid),
    .avm_burstcount(out.burstcount),
    .avm_waitrequest(out.waitrequest)
);

endmodule