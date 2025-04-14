`include "top.svh"

module afe_iobuf(
    input  logic afe_prsnt,
    output logic afe_pwr_ena,
    input  logic afe_pwr_gd,
    inout  logic nConfig,
    input  logic nStatus,
    input  logic CONF_DONE,
    input  logic INIT_DONE,
    inout  logic DCLK,
    inout  logic DATA,
    inout  logic MSEL0,
    inout  logic MSEL1,

    input  logic [10:0] emio_o,
    input  logic [10:0] emio_t,
    output logic [10:0] emio_i
);
    IOBUF IOBUF_nConfig (
        .IO(nConfig),
        .O(emio_i[0]),
        .I(emio_o[0]),
        .T(emio_t[0])
    );
    assign emio_i[1] = nStatus;
    assign emio_i[2] = CONF_DONE;
    assign emio_i[3] = INIT_DONE;

    IOBUF IOBUF_DCLK (
        .IO(DCLK),
        .O(emio_i[4]),
        .I(emio_o[4]),
        .T(emio_t[4])
    );
    
    IOBUF IOBUF_DATA (
        .IO(DATA),
        .O(emio_i[5]),
        .I(emio_o[5]),
        .T(emio_t[5])
    );
    
    IOBUF IOBUF_MSEL0 (
        .IO(MSEL0),
        .O(emio_i[6]),
        .I(emio_o[6]),
        .T(emio_t[6])
    );
    
    IOBUF IOBUF_MSEL1 (
        .IO(MSEL1),
        .O(emio_i[7]),
        .I(emio_o[7]),
        .T(emio_t[7])
    );
    assign emio_i[8] = afe_prsnt;
    assign emio_i[9] = afe_pwr_gd;

    assign emio_i[10] = emio_o[10];
    OBUFT OBUFT_inst (
        .O(afe_pwr_ena),
        .I(0),
        .T(!emio_o[10])
    );
    
endmodule