`include "top.svh"
`include "axi4_lite_if.svh"

module evr
(
    input  logic            sysclk,
    input  logic            refclk,

    //------GTP signals-------
    input  logic            aligned,

    input  logic            tx_resetdone,
    input  logic            tx_clk,
    output logic [15:0]     tx_data,
    output logic [1:0]      tx_charisk,

    input  logic            rx_resetdone,
    input  logic            rx_clk,
    input  logic [15:0]     rx_data,
    input  logic [1:0]      rx_charisk,

    //------Application signals-------
    output logic            app_clk,
    input  logic            app_rst,
    output logic [7:0]      ev,
    axi4_lite_if.s          mmr,
    axi4_lite_if.m          shared_data_out
);
    logic ready;
    logic ready_sync;
    logic mmcm_locked;
    assign ready = aligned && mmcm_locked;

    xpm_cdc_single ready_cdc_i(
        .dest_clk(app_clk),
        .dest_out(ready_sync),
        .src_clk(rx_clk),
        .src_in(ready)
    );
//MMR logic 
    logic [         31:0] parser_delay;
    logic [          2:0] parser_status;
    logic [         31:0] parser_topoid;

    logic                 adjust_dc_ena;
    logic [         31:0] adjust_delay_req;
    logic [          1:0] adjust_status;
    logic [         31:0] adjust_delay;


//Beacon logic
    logic       beacon_pulse_rx;
    logic       beacon_pulse_rx_expand;
    logic [1:0] beacon_cnt = '0;
    logic       beacon_pulse_tx;

    assign beacon_pulse_rx        = rx_data[15:8] == 8'h7E;
    assign beacon_pulse_rx_expand = beacon_cnt != 'b0;

    always_ff @(posedge rx_clk) begin
        if(beacon_pulse_rx) 
            beacon_cnt <= 2'b11;
        else
            if(beacon_cnt != 2'b0)
                beacon_cnt <= beacon_cnt-1;         
    end

    xpm_cdc_pulse XPM_CDC_PULSE_i(
        .dest_clk(tx_clk),
        .dest_pulse(beacon_pulse_tx),
        .dest_rst('b0),
        .src_clk(rx_clk),
        .src_pulse(beacon_pulse_rx_expand),
        .src_rst('b0)
    );

//TX Data logic
    logic [   1:0] tx_cnt = '0;
    always_ff @(posedge tx_clk) tx_cnt <= tx_cnt + 1;

    always_comb begin
        tx_charisk[0] = 0;
        tx_data[7:0] = '0;

        if (beacon_pulse_tx) begin
            tx_charisk[1] = 0;
            tx_data[15:8]  = 8'h7E;
        end
        else if (tx_cnt == '0) begin
            tx_charisk[1] = 1;
            tx_data[15:8]  = 8'hBC;
        end
        else begin
            tx_charisk[1] = 0;
            tx_data[15:8]  = 8'h00;
        end
    end


//FIFO-only beacon logic 
    logic          local_beacon_ena;
    logic [  11:0] local_beacon_cnt = '1;

    assign local_beacon_ena = !rx_charisk[1] && rx_data[15:8] == '0;

    always_ff @(posedge rx_clk) begin
        local_beacon_cnt     <= local_beacon_cnt - 1;
        if (local_beacon_cnt == '0 && !local_beacon_ena)
            local_beacon_cnt <= '0;
    end

//RX Data logic 
    logic           fifo_empty;

    logic [7:0]     rx_data_shared;
    logic           rx_charisk_shared;
    
    logic [7:0]     rx_data_fifo_in;
    logic           rx_charisk_fifo_in;
    logic [7:0]     rx_data_fifo_out;
    logic           rx_charisk_fifo_out;

    assign rx_data_shared     = rx_data[7:0];
    assign rx_charisk_shared  = rx_charisk[0];

    always_comb begin
        rx_charisk_fifo_in    = local_beacon_ena && local_beacon_cnt == '0 ? 0     : (beacon_pulse_rx ?  0 : rx_charisk[1]);
        rx_data_fifo_in       = local_beacon_ena && local_beacon_cnt == '0 ? 8'h7E : (beacon_pulse_rx ? '0 : rx_data[15:8]); // ignore external beacons becouse of fifo lenght
    end

    assign ev                 = !fifo_empty && !rx_charisk_fifo_out ? rx_data_fifo_out : '0;


//Shared data buffer
    stream_decoder_m stream_decoder_i(
        .clk(app_clk),
        .rst(app_rst),
        .rx_data_in(rx_data_shared),
        .rx_isk_in(rx_charisk_shared),
        .shared_data_out_i({shared_data_out})
    );

    
//Parser
    parser_m parser_i(
        .clk(app_clk),
        .rst(~ready_sync),
        .valid(!fifo_empty),
        .rx_data(rx_data_shared),
        .rx_isk(rx_charisk_shared),
        .delay(parser_delay),
        .status(parser_status),
        .topoid(parser_topoid)
    );

//MMMC implies FIFO phase shift and clock multyplexing
    mmcm_wrapper mmcm_wrapper_i(
        .clk_in1(rx_clk),
        .clk_in2(refclk),
        .clk_in_sel(ready),
        .clk_out1(app_clk),
        .psclk(),
        .psen(),
        .psincdec(),
        .psdone(),
        .resetn(1),
        .locked(mmcm_locked)
    );

//FIFO lenght adjust
    logic fifo_dec;
    logic fifo_inc;


    logic       fifo_dec_appclk;
    logic       fifo_dec_appclk_expand;
    logic       fifo_dec_appclk_cnt = '0;

    assign fifo_dec_appclk_expand = fifo_dec_appclk_cnt != 1'b0;

    always_ff @(posedge app_clk) begin
        if(fifo_dec_appclk) 
            fifo_dec_appclk_cnt <= 1'b1;
        else
            if(fifo_dec_appclk_cnt != 1'b0)
                fifo_dec_appclk_cnt <= fifo_dec_appclk_cnt-1;         
    end

    xpm_cdc_pulse fifo_dec_i(
        .dest_clk(rx_clk),
        .dest_pulse(fifo_dec),
        .dest_rst('b0),
        .src_clk(app_clk),
        .src_pulse(fifo_dec_appclk_expand),
        .src_rst('b0)
    );

    adjust_m adjust_i(
        .refclk(refclk),

        .rst_wclk(~ready),
        .fifo_wclk(rx_clk),
        .fifo_wdata({rx_charisk_fifo_in, rx_data_fifo_in}),
        .fifo_wdata_valid(ready),

        .rst_rclk(~ready_sync),
        .fifo_rclk(app_clk),
        .fifo_rdata({rx_charisk_fifo_out, rx_data_fifo_out}),
        .fifo_rdata_valid(!fifo_empty),

        .fifo_inc(fifo_inc),
        .fifo_dec(fifo_dec_appclk),
        .pll_ph_inc(),
        .pll_ph_dec(),

        .ena(adjust_dc_ena),
        .delay_req_upd(adjust_delay_req_upd),
        .delay_req(adjust_delay_req),
        .status(adjust_status),
        .delay(adjust_delay)
    );


//FIFO 
    fifo_wrapper #(
        .WIDTH( $bits(rx_data) ),
        .DEPTH( 1024 )
    ) fifo_i (
        .rst(app_rst),
        .wr_clk(rx_clk),
        .rd_clk(app_clk),
        .d_in({rx_charisk_fifo_in, rx_data_fifo_in}),
        .wr_en(ready && ~fifo_dec),
        .rd_en(ready && ~fifo_inc),
        .d_out({rx_charisk_fifo_out, rx_data_fifo_out}),
        .full(),
        .empty(fifo_empty)
    );

endmodule;