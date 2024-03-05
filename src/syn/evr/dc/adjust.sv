//------------------------------------------------
//
//      project: llrf-hp
//
//      module:  adjust_m
//
//      desc:    Achieve target delay by varying
//               amount of data in FIFO and
//               adjusting dc PLL clock phase
//
//------------------------------------------------

`ifndef __ADJUST_SV__
`define __ADJUST_SV__

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
module adjust_m
#(
    DELAY_WIDTH      = 32,
    DELAY_INT_WIDTH  = 16,
    DELAY_FRAC_WIDTH = 16
)
(
    input  logic                   refclk,

    input  logic                   rst_wclk,
    input  logic                   fifo_wclk,
    input  logic [8:0]             fifo_wdata,
    input  logic                   fifo_wdata_valid,

    input  logic                   rst_rclk,
    input  logic                   fifo_rclk,
    input  logic [8:0]             fifo_rdata,
    input  logic                   fifo_rdata_valid,

    output logic                   fifo_inc,
    output logic                   fifo_dec,
    output logic                   pll_ph_inc,
    output logic                   pll_ph_dec,

    input  logic                   ena,
    input  logic                   delay_req_upd,
    input  logic [DELAY_WIDTH-1:0] delay_req,
    output logic [            1:0] status,
    output logic [DELAY_WIDTH-1:0] delay
);

//--------------------------------------------------
//
//      Parameters
//
localparam HIST  = 32'd150;
localparam THRES = 32'd256;

localparam SLOW_CNT_WIDTH = 20;
localparam FAST_CNT_WIDTH = 10;
localparam CNT_WIDTH      = SLOW_CNT_WIDTH;

localparam SLOW_CNT_PRD   = 2 ** SLOW_CNT_WIDTH;
localparam FAST_CNT_PRD   = 2 ** FAST_CNT_WIDTH;

//--------------------------------------------------
//
//      Types
//
typedef logic [     DELAY_WIDTH-1:0] delay_t;
typedef logic [ DELAY_INT_WIDTH-1:0] delay_int_t;
typedef logic [DELAY_FRAC_WIDTH-1:0] delay_frac_t;

typedef logic [       CNT_WIDTH-1:0] cnt_t;

typedef logic [                32:0] locked_cnt_t; // 2^33 * 10ns = ~85s - that time error should be under threshold
                                                   // before fsm go to the locked state

typedef enum logic [1:0] {
    COARSE,
    FINE,
    SLOW,
    LOCKED
} state_t;

//--------------------------------------------------
//
//      Objects
//
logic        rst_sync;

logic        beacon_0;
logic        beacon_0_p;
logic        beacon_0_sync;

logic        beacon_1;
logic        beacon_1_p;
logic        beacon_1_sync;

delay_t      delay_measured;
logic        delay_update;
logic        delay_nready;
logic        delay_ready;

delay_t      delay_req_avg;
delay_t      delay_req_err;
delay_int_t  delay_req_err_int;
delay_frac_t delay_req_err_frac;
delay_t      delay_err;
delay_int_t  delay_err_int;
delay_frac_t delay_err_frac;

logic        sign;

cnt_t        cnt;
locked_cnt_t locked_cnt;
logic        state_update;
state_t      state = COARSE, next;

logic        slow_sync;

//--------------------------------------------------
//
//      Logic
//

assign sign               = delay_req_avg > delay;
assign delay_err          = delay_req_avg > delay ? delay_req_avg - delay : delay - delay_req_avg;
assign delay_req_err      = delay_req_avg > delay_req ? delay_req_avg - delay_req : delay_req - delay_req_avg;

assign delay_err_int      = delay_err[DELAY_WIDTH-1                 -: DELAY_INT_WIDTH ];
assign delay_err_frac     = delay_err[DELAY_WIDTH-DELAY_INT_WIDTH-1 -: DELAY_FRAC_WIDTH];

assign delay_req_err_int  = delay_req_err[DELAY_WIDTH-1                 -: DELAY_INT_WIDTH ];
assign delay_req_err_frac = delay_req_err[DELAY_WIDTH-DELAY_INT_WIDTH-1 -: DELAY_FRAC_WIDTH];

//--------------------------------------------------
assign state_update = delay_ready && cnt == '0;

always_ff @(posedge fifo_rclk) begin
    if (ena) begin
        if (delay_ready) begin
            cnt <= cnt_t'(cnt - 1);
            if (cnt == '0)
                cnt <= state >= SLOW ? cnt_t'(SLOW_CNT_PRD - 1) : cnt_t'(FAST_CNT_PRD - 1);
        end
        if (delay_req_upd)
            cnt <= next >= SLOW ? cnt_t'(SLOW_CNT_PRD - 1) : cnt_t'(FAST_CNT_PRD - 1);
    end
    else begin
        cnt <= cnt_t'(FAST_CNT_PRD - 1);
    end
end

//--------------------------------------------------
assign status = state;

always_ff @(posedge fifo_rclk) begin
    if (rst_rclk) begin
        state <= COARSE;
    end
    else begin
        if (state_update || delay_req_upd)
            state <= next;
    end
end

always_ff @(posedge fifo_rclk) begin
    if (state == SLOW && !pll_ph_inc && !pll_ph_dec) begin
        if (locked_cnt != '0)
            locked_cnt <= locked_cnt_t'(locked_cnt - 1);
    end
    else begin
        locked_cnt <= '1;
    end
end

always_comb begin
    if (rst_rclk || !ena) begin
        next = COARSE;
    end
    else begin
        case (state)
            COARSE: next = delay_err_int == '0 && delay_req_err < delay_t'(THRES) ? FINE : COARSE;
            FINE:   next = delay_err < delay_t'(THRES) ? SLOW : FINE;
            SLOW:   next = locked_cnt == '0 ? LOCKED : SLOW;
            LOCKED: next = LOCKED;
        endcase
        if (delay_req_upd) begin
            if (delay_req_err_int != '0) next = COARSE;
            else                         next = delay_req_err_frac > delay_t'(THRES) ? FINE : SLOW;
        end
    end
end

//--------------------------------------------------
always_ff @(posedge fifo_rclk) begin
    fifo_inc   <= 0;
    fifo_dec   <= 0;
    pll_ph_inc <= 0;
    pll_ph_dec <= 0;
    if (ena) begin
        if (state_update) begin
            if (state == COARSE) begin
                if (delay_err_int != 0) begin
                    if (sign) fifo_inc <= 1;
                    else      fifo_dec <= 1;
                end
            end
            else begin
                if (delay_err_frac >= delay_frac_t'(THRES + HIST)) begin
                    if (sign) pll_ph_inc <= 1;
                    else      pll_ph_dec <= 1;
                end
            end
        end
    end
end

//--------------------------------------------------
always_ff @(posedge fifo_rclk) begin
    delay_ready <= !delay_nready;
end

//--------------------------------------------------
assign beacon_0 = fifo_wdata_valid && fifo_wdata == 8'h17E;
assign beacon_1 = fifo_rdata_valid && fifo_rdata == 8'h17E;

//--------------------------------------------------
//
//      Instances
//

logic       beacon0_expand;
logic [1:0] beacon0_cnt = '0;

assign beacon0_expand = beacon0_cnt != 'b0;

always_ff @(posedge fifo_wclk) begin
    if(beacon_0) 
        beacon0_cnt <= 2'b11;
    else
        if(beacon0_cnt != 2'b0)
            beacon0_cnt <= beacon0_cnt - 1;         
end

xpm_cdc_pulse beacon_0_sunchronizer_i(
    .dest_clk(refclk),
    .dest_pulse(beacon_0_sync),
    .dest_rst('b0),
    .src_clk(fifo_wclk),
    .src_pulse(beacon0_expand),
    .src_rst('b0)
);


logic       beacon1_expand;
logic [1:0] beacon1_cnt = '0;

assign beacon1_expand = beacon1_cnt != 'b0;

always_ff @(posedge fifo_rclk) begin
    if(beacon_1) 
        beacon1_cnt <= 2'b11;
    else
        if(beacon1_cnt != 2'b0)
            beacon1_cnt <= beacon1_cnt - 1;         
end

xpm_cdc_pulse beacon_1_sunchronizer_i(
    .dest_clk(refclk),
    .dest_pulse(beacon_1_sync),
    .dest_rst('b0),
    .src_clk(fifo_rclk),
    .src_pulse(beacon1_expand),
    .src_rst('b0)
);

xpm_cdc_single slow_syncronizer(
    .dest_clk(refclk),
    .dest_out(slow_sync),
    .src_clk(fifo_rclk),
    .src_in(state >= SLOW)
);

xpm_cdc_single rst_syncronizer(
    .dest_clk(refclk),
    .dest_out(rst_sync),
    .src_clk(fifo_wclk),
    .src_in(rst_wclk)
);

//--------------------------------------------------
measure_m #(
    .DELAY_WIDTH      ( DELAY_WIDTH     ),
    .DELAY_INT_WIDTH  ( DELAY_INT_WIDTH ),
    .DELAY_FRAC_FAST  ( FAST_CNT_WIDTH  ),
    .DELAY_FRAC_SLOW  ( SLOW_CNT_WIDTH  )
)
measure
(
    .clk              ( refclk          ),
    .rst              ( rst_sync        ),
    .slow             ( slow_sync       ),
    .beacon_0         ( beacon_0_sync   ),
    .beacon_1         ( beacon_1_sync   ),
    .update           ( delay_update    ),
    .delay            ( delay_measured  )
);
//--------------------------------------------------
xpm_fifo_async #(
    .CASCADE_HEIGHT(0),        // DECIMAL
    .CDC_SYNC_STAGES(2),       // DECIMAL
    .DOUT_RESET_VALUE("0"),    // String
    .ECC_MODE("no_ecc"),       // String
    .FIFO_MEMORY_TYPE("auto"), // String
    .FIFO_READ_LATENCY(1),     // DECIMAL
    .FIFO_WRITE_DEPTH(16),   // DECIMAL
    .FULL_RESET_VALUE(0),      // DECIMAL
    .PROG_EMPTY_THRESH(10),    // DECIMAL
    .PROG_FULL_THRESH(10),     // DECIMAL
    .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
    .READ_DATA_WIDTH(DELAY_WIDTH),      // DECIMAL
    .READ_MODE("std"),         // String
    .RELATED_CLOCKS(0),        // DECIMAL
    .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .USE_ADV_FEATURES("0707"), // String
    .WAKEUP_TIME(0),           // DECIMAL
    .WRITE_DATA_WIDTH(DELAY_WIDTH),     // DECIMAL
    .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
)
xpm_fifo_async_inst (
    .rst(rst_sync),

    .wr_clk(refclk),
    .wr_en(delay_update),
    .din(delay_measured),

    .rd_clk(fifo_rclk),
    .rd_en(1),
    .dout(delay),
    .empty(delay_nready)
);
//--------------------------------------------------
average_m #(
    .OUT_WIDTH        ( DELAY_WIDTH     ),
    .IN_WIDTH         ( DELAY_WIDTH     ),
    .N_FAST           ( FAST_CNT_WIDTH  ),
    .N_SLOW           ( SLOW_CNT_WIDTH  )
)
delay_req_average
(
    .clk              ( fifo_rclk       ),
    .rst              ( rst_rclk        ),
    .slow             ( state >= SLOW   ),
    .in               ( delay_req       ),
    .load             ( delay_ready     ),
    .out              ( delay_req_avg   )
);
//--------------------------------------------------
endmodule : adjust_m

`endif//__ADJUST_SV__