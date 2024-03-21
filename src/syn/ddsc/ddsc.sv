`ifndef __DDSC_SV__
`define __DDSC_SV__

// synopsys translate off
`define SIMULATOR
// synopsys translate on

`include "../hp.svh"

module ddsc_m import hp_pkg::*;
#(
    parameter NUMBER          = 0,
    parameter AW              = 12,
    parameter DW              = 64,
    parameter MAX_BURST       = 8,
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

    avmm_if.slave                   mmr_i,
    avmm_if.slave                   conv_tbl_i,
    avmm_if.slave                   desc_tbl_i,

    input  logic                    sync,
    input  logic [DESC_ITEM_DW-1:0] sync_prd,
    input  logic [ EVENT_BUS_W-1:0] ev,

    input  logic [   B_FIELD_W-1:0] b_field,
    input  logic                    b_ready,

    ddsc_if.out                     out,
    avmm_if.master                  shared_out_i,
    avmm_if.slave                   shared_in_i
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Parameters
//
localparam DESC_SIZE     = DESC_ITEM_COUNT * DESC_ITEM_DW/8;
localparam DESC_TBL_SIZE = (2**AW);

localparam DESC_COUNT    = DESC_TBL_SIZE / DESC_SIZE;
localparam DESC_AW       = $clog2(DESC_COUNT);
 
localparam DESC_TBL_AW   = $clog2(DESC_TBL_SIZE / (DESC_ITEM_DW/8));
localparam DESC_TBL_DW   = DESC_ITEM_DW;

localparam CONV_TBL_AW   = EVENT_BUS_W;
localparam CONV_TBL_DW   = ((DESC_AW-1)/8 + 1) * 8;

//------------------------------------------------
//
//      Types
//
typedef logic [      CONV_TBL_DW-1:0] conv_tbl_data_t;
typedef logic [      DESC_TBL_AW-1:0] desc_tbl_addr_t;
typedef logic [      DESC_TBL_DW-1:0] desc_tbl_data_t;

typedef logic [   MMR_DEV_ADDR_W-1:0] mmr_addr_t;
typedef logic [       MMR_DATA_W-1:0] mmr_data_t;

typedef logic [SHARED_MEM_SEG_AW-1:0] seg_addr_t;

typedef enum mmr_addr_t {
    SR        = mmr_addr_t'( 8'h00 ),
    CR        = mmr_addr_t'( 8'h04 ),
    CR_S      = mmr_addr_t'( 8'h08 ),
    CR_C      = mmr_addr_t'( 8'h0C ),
    SRC_ID    = mmr_addr_t'( 8'h10 ),
    MASTER_ID = mmr_addr_t'( 8'h14 )
} regs_t;

typedef enum logic [1:0] {
    STANDALONE = 2'b00,
    MASTER     = 2'b01,
    SLAVE      = 2'b10,
    RSRV       = 2'b11
} mode_t;

typedef struct packed
{
    mode_t mode;
} cr_t;

//------------------------------------------------
//
//      Objects
//
conv_tbl_data_t conv_tbl_data;
desc_tbl_addr_t desc_tbl_addr;
desc_tbl_data_t desc_tbl_data;

avmm_if #(
    .AW        ( MMR_ADDR_W    ),
    .DW        ( MMR_DATA_W    ),
    .MAX_BURST ( 1             )
) data_out_i();

avmm_if #(
    .AW        ( SHARED_MEM_AW ),
    .DW        ( LLRF_DW       ),
    .MAX_BURST ( 1             )
) shared_data_out_i();

//------------------------------------------------
cr_t       cr, cr_buf;

seg_addr_t src_id;
seg_addr_t master_id;

logic      hit;

//------------------------------------------------
//
//      Logic
//
assign mmr_i.waitrequest = rst;

always_ff @(posedge clk) begin
    if (rst) begin
        cr        <= cr_t'(STANDALONE);
        cr_buf    <= cr_t'(STANDALONE);
        src_id    <= 0;
        master_id <= NUMBER;
    end
    else begin

        if (sync)
            cr <= cr_buf;

        if (mmr_i.write) begin
            case (mmr_i.address)
                CR:        cr_buf    <= cr_t'(mmr_i.writedata);
                CR_S:      cr        <= cr |   cr_t'(mmr_i.writedata);
                CR_C:      cr        <= cr & ~(cr_t'(mmr_i.writedata));
                SRC_ID:    src_id    <= seg_addr_t'(mmr_i.writedata);
                MASTER_ID: master_id <= seg_addr_t'(mmr_i.writedata);
                default;
            endcase
        end

        mmr_i.readdatavalid <= 0;
        if (mmr_i.read) begin
            mmr_i.readdatavalid <= 1;
            case (mmr_i.address)
                CR:        mmr_i.readdata <= mmr_data_t'(cr);
                SRC_ID:    mmr_i.readdata <= mmr_data_t'(src_id);
                MASTER_ID: mmr_i.readdata <= mmr_data_t'(master_id);
                default:   mmr_i.readdata <= '0;
            endcase
        end
    end
end

//------------------------------------------------
assign hit                     = src_id * SHARED_MEM_SEG_SIZE == shared_in_i.address;

assign shared_out_i.read       = 0;
assign shared_out_i.address    = master_id * SHARED_MEM_SEG_SIZE;
assign shared_out_i.burstcount = 1;
assign shared_out_i.byteenable = 0;

always_comb begin
    case (cr.mode)
        default: begin
            out.tx_valid           = data_out_i.write;
            out.f                  = data_out_i.writedata;

            shared_out_i.write     = 0;
            shared_out_i.writedata = 0;
        end
        MASTER: begin
            out.tx_valid           = data_out_i.write;
            out.f                  = data_out_i.writedata;

            shared_out_i.write     = shared_data_out_i.write;
            shared_out_i.writedata = shared_data_out_i.writedata;
        end
        SLAVE: begin
            out.tx_valid           = hit ? shared_in_i.write : 0;
            out.f                  = shared_in_i.writedata;

            shared_out_i.write     = 0;
            shared_out_i.writedata = 0;
        end
    endcase
end

always_comb begin
    case (cr.mode)
        default: begin
            data_out_i.waitrequest        = ~out.rx_ready;
            shared_data_out_i.waitrequest = 0;
            shared_in_i.waitrequest       = 0;
        end
        MASTER: begin
            data_out_i.waitrequest        = ~out.rx_ready;
            shared_data_out_i.waitrequest = shared_out_i.waitrequest;
            shared_in_i.waitrequest       = 0;
        end
        SLAVE: begin
            data_out_i.waitrequest        = 0;
            shared_data_out_i.waitrequest = 0;
            shared_in_i.waitrequest       = hit ? ~out.rx_ready : 0;
        end
    endcase
end

//------------------------------------------------
`ifdef SIMULATOR
always @(posedge out.tx_valid)
    $display("[%t]: <ddsc core %0d> set new freq value %0d", $realtime, NUMBER, out.f);
`endif 

//------------------------------------------------
//
//      Instances
//
dpram_avmm_m #(
    .AVMM_AW           ( AW                ),
    .AVMM_DW           ( DW                ),
    .AVMM_MAX_BURST    ( MAX_BURST         ),
    .APP_AW            ( CONV_TBL_AW       ),
    .APP_DW            ( CONV_TBL_DW       ),
    .INIT_FILE         ( "conv_tbl.mif"    )
)
conv_table
(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .bus               ( conv_tbl_i        ),
    .app_addr          ( ev                ),
    .app_data          ( conv_tbl_data     )
);
//------------------------------------------------
dpram_avmm_m #(
    .AVMM_AW           ( AW                ),
    .AVMM_DW           ( DW                ),
    .AVMM_MAX_BURST    ( MAX_BURST         ),
    .APP_AW            ( DESC_TBL_AW       ),
    .APP_DW            ( DESC_TBL_DW       ),
    .INIT_FILE         ( "desc_tbl.mif"    )
)
desc_table
(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .bus               ( desc_tbl_i        ),
    .app_addr          ( desc_tbl_addr     ),
    .app_data          ( desc_tbl_data     )
);
//------------------------------------------------
ddsc_core_m #(
    .CONV_TBL_AW       ( CONV_TBL_AW       ),
    .CONV_TBL_DW       ( CONV_TBL_DW       ),
    .DESC_AW           ( DESC_AW           ),
    .DESC_ITEM_COUNT   ( DESC_ITEM_COUNT   ),
    .DESC_TBL_AW       ( DESC_TBL_AW       ),
    .DESC_TBL_DW       ( DESC_TBL_DW       ),
    .CLK_PRD           ( CLK_PRD           )
)
ddsc_core
(
    .clk               ( clk               ),
    .rst               ( rst               ),
    .sync              ( sync              ),
    .sync_prd          ( sync_prd          ),
    .timestamp         ( '0                ),
    .conv_tbl_out      ( conv_tbl_data     ),
    .desc_tbl_addr     ( desc_tbl_addr     ),
    .desc_tbl_data     ( desc_tbl_data     ),
    .b_ready           ( b_ready           ),
    .b_field           ( b_field           ),
    .data_out_i        ( data_out_i        ),
    .shared_data_out_i ( shared_data_out_i )
);
//------------------------------------------------
endmodule : ddsc_m

`endif//__DDSC_SV__
