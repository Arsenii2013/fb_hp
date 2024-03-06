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
    logic [         31:0] parser_delay;
    logic [          2:0] parser_status;
    logic [         31:0] parser_topoid;

    logic                 adjust_dc_ena;
    logic [         31:0] adjust_delay_req;
    logic                 adjust_delay_req_upd;
    logic [          1:0] adjust_status;
    logic [         31:0] adjust_delay_comp;

    logic [         31:0] target_delay;

//MMR logic 
    typedef logic [MMR_DEV_ADDR_W-1:0] addr_t;
    typedef logic [    MMR_DATA_W-1:0] data_t;

    typedef enum addr_t {
        SR            = addr_t'(8'h00),
        CR            = addr_t'(8'h04),
        CR_S          = addr_t'(8'h08),
        CR_C          = addr_t'(8'h0C),
        LINK_TOPO_ID  = addr_t'(8'h10),
        LINK_DELAY    = addr_t'(8'h14),
        TGT_DELAY     = addr_t'(8'h18),
        COMP_DELAY    = addr_t'(8'h1C)
    } evr_regs;

    typedef struct packed {
        logic [1:0] dc_status;
        logic [2:0] link_delay_st;
        logic       link_up;
    } sr_t;

    typedef struct packed {
        logic       dc_ena;
    } cr_t;

    sr_t sr;
    cr_t cr;
    logic [MMR_DEV_ADDR_W-1:0] addr;
    logic [MMR_DATA_W-1:0] data;
    logic read;
    logic write_addr;
    logic write_data;

    assign sr.link_up       = ready_sync;
    assign sr.dc_status     = adjust_status;
    assign sr.link_delay_st = parser_status;
    assign adjust_dc_ena    = cr.dc_ena;
    assign adjust_delay_req = target_delay - parser_delay;

    always_ff @(posedge app_clk) begin
        if (app_rst) begin
            mmr.arready        <= 0;
            mmr.rvalid         <= 0;
            mmr.awready        <= 0;
            mmr.wready         <= 0;
            mmr.bvalid         <= 0;
            cr.dc_ena          <= 0;
            adjust_delay_req_upd <= 0;
            mmr.rresp <= '0;
            mmr.bresp <= '0;
            mmr.rdata <= '0;
            read       <= 0;
            write_addr <= 0;
            write_data <= 0;
        end
        else begin
            if (~ready_sync) begin
                cr.dc_ena <= 0;
            end
        
            adjust_delay_req_upd <= 0;

            mmr.arready <= 0;
            if(mmr.arvalid) begin
                addr <= mmr.araddr;
                read <= 1;
                mmr.arready <= !read;
            end 

            mmr.rvalid <= read;
            if(mmr.rvalid && mmr.rready) begin
                read <= 0;
                mmr.rvalid <= 0;
                case (addr)
                    SR            : mmr.rdata <= data_t'(sr);
                    CR            : mmr.rdata <= data_t'(cr);
                    LINK_TOPO_ID  : mmr.rdata <= data_t'(parser_topoid);
                    LINK_DELAY    : mmr.rdata <= data_t'(parser_delay);
                    TGT_DELAY     : mmr.rdata <= data_t'(target_delay);
                    COMP_DELAY    : mmr.rdata <= data_t'(adjust_delay_comp);
                    default       : mmr.rdata <= '0;
                endcase 
            end 


            mmr.awready <= 0;
            if(mmr.awvalid) begin
                addr <= mmr.awaddr;
                write_addr <= 1;
                mmr.awready <= !write_addr;
            end 

            mmr.wready <= 0;
            if(mmr.wvalid) begin
                data <= mmr.wdata;
                write_data <= 1;
                mmr.wready <= !write_data;
            end 

            mmr.bvalid <= write_addr && write_data;
            if(write_addr && write_data && mmr.bready) begin
                write_addr <= 0;
                write_data <= 0;
                mmr.bvalid <= 0;
                case (addr)
                    CR        : cr <= cr_t'(data);
                    CR_S      : cr <= cr | cr_t'(data);
                    CR_C      : cr <= cr & ~(cr_t'(data));
                    TGT_DELAY : begin
                        if (data > parser_delay) begin
                            target_delay <= data;
                            adjust_delay_req_upd <= 1;
                        end
                    end
                    default;
                endcase
            end 
            
        end
    end

//Beacon logic
    logic       beacon_pulse_rx;
    logic       beacon_pulse_rx_expand;
    logic [1:0] beacon_cnt = '0;
    logic       beacon_pulse_tx;

    assign beacon_pulse_rx        = rx_data[7:0] == 8'h7E;
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
        tx_charisk[1] = 0;
        tx_data[15:8] = '0;

        if (beacon_pulse_tx) begin
            tx_charisk[0] = 0;
            tx_data[7:0]  = 8'h7E;
        end
        else if (tx_cnt == '0) begin
            tx_charisk[0] = 1;
            tx_data[7:0]  = 8'hBC;
        end
        else begin
            tx_charisk[0] = 0;
            tx_data[7:0]  = 8'h00;
        end
    end


//FIFO-only beacon logic 
    logic          local_beacon_ena;
    logic [  11:0] local_beacon_cnt = '1;

    assign local_beacon_ena = !rx_charisk[0] && rx_data[7:0] == '0;

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

    assign rx_data_shared     = rx_data[15:8];
    assign rx_charisk_shared  = rx_charisk[1];

    always_comb begin
        rx_charisk_fifo_in    = local_beacon_ena && local_beacon_cnt == '0 ? 0     : (beacon_pulse_rx ?  0 : rx_charisk[0]);
        rx_data_fifo_in       = local_beacon_ena && local_beacon_cnt == '0 ? 8'h7E : (beacon_pulse_rx ? '0 : rx_data[7:0]); // ignore external beacons becouse of fifo lenght
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
    logic pll_ph_inc;
    logic pll_ph_dec;
    logic psclk;
    logic psen;
    logic psincdec;
    logic psdone;
    logic psinprocess;
    logic mmcm_resetn;
    
    assign psclk = app_clk;

    mmcm_wrapper mmcm_wrapper_i(
        .clk_in1(rx_clk),
        .clk_in2(refclk),
        .clk_in_sel(aligned),
        .clk_out1(app_clk),
        .psclk(psclk),
        .psen(psen),
        .psincdec(psincdec),
        .psdone(psdone),
        .resetn(mmcm_resetn),
        .locked(mmcm_locked)
    );

//Phase shift
    logic clk_in_sel_prev;
    always_ff @(posedge rx_clk) begin
        clk_in_sel_prev <= aligned;
    end
    assign mmcm_resetn = !(aligned ^ clk_in_sel_prev);


    always_ff @(posedge psclk) begin
        if (ready_sync) begin
            if (pll_ph_inc) begin
                psen        <= 1;
                psincdec    <= 1;
                psinprocess <= 1;
            end
            else if (pll_ph_dec) begin
                psen        <= 1;
                psincdec    <= 0;
                psinprocess <= 1;
            end
            else 
                psen <= 0;

            if (psdone) begin
                psinprocess <= 0;
            end
        end
        else 
            psen <= 0;
            psinprocess <= 0;
    end


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
        .pll_ph_inc(pll_ph_inc),
        .pll_ph_dec(pll_ph_dec),

        .ena(adjust_dc_ena),
        .delay_req_upd(adjust_delay_req_upd),
        .delay_req(adjust_delay_req),
        .status(adjust_status),
        .delay(adjust_delay_comp)
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