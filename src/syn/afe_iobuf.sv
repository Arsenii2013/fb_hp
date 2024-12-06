`include "top.svh"

module afe_iobuf(
    input  logic afe_prsnt,
    output logic afe_pwr_ena,
    input  logic afe_pwr_gd,
    output logic nConfig,
    input  logic nStatus,
    input  logic CONF_DONE,
    input  logic INIT_DONE,
    output logic DCLK,
    output logic DATA,
    output logic MSEL0,
    output logic MSEL1,

    input  logic [10:0] emio_o,
    input  logic [10:0] emio_t,
    output logic [10:0] emio_i
);

    OBUFT OBUFT_nConfig (
        .O(nConfig),
        .I(emio_o[0]),
        .T(emio_t[0])
    );
    assign emio_i[1] = nStatus;
    assign emio_i[2] = CONF_DONE;
    assign emio_i[3] = INIT_DONE;
    OBUFT OBUFT_DCLK (
        .O(DCLK),
        .I(emio_o[4]),
        .T(emio_t[4])
    );
    
    OBUFT OBUFT_DATA (
        .O(DATA),
        .I(emio_o[5]),
        .T(emio_t[5])
    );
    
    OBUFT OBUFT_MSEL0 (
        .O(MSEL0),
        .I(emio_o[6]),
        .T(emio_t[6])
    );
    OBUFT OBUFT_MSEL1 (
        .O(MSEL1),
        .I(emio_o[7]),
        .T(emio_t[7])
    );
    assign emio_i[8] = afe_prsnt;
    assign emio_i[9] = afe_pwr_gd;

    OBUFT OBUFT_inst (
        .O(afe_pwr_ena),
        .I(0),
        .T(!emio_o[10])
    );
    
endmodule