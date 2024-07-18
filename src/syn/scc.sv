//------------------------------------------------
//
//      Project: LLRF HP
//
//      Module:  Sync & clock control
//
//------------------------------------------------

`ifndef __SCC_SV__
`define __SCC_SV__

`include "top.svh"
`include "afe.svh"

module scc_m
(
    input  logic                  clk,
    output logic                  rst,

    axi4_lite_if.s                mmr,
    axi4_lite_if.m                afe_ctrl_i,

    input  logic                  afe_init_done,
    input  logic                  evr_link_ok,
    input  logic                  dc_coarse_done,
    output logic                  llrf_sync_done,

    input  logic [      EV_W-1:0] ev,
    output logic                  sync,
    output logic                  align,
    output logic                  log_start,

    output logic                  dds_clk_out,

    output logic                  sync_x2, // x2 repeated outputs
    output logic                  align_x2,

    output logic [           3:0] test_out,

    output logic [MMR_DATA_W-1:0] sync_prd,
    output logic                  sync_PS
);

//------------------------------------------------
`timescale 1ns / 1ps
parameter PS_SYNC_WIDTH = 32;

//------------------------------------------------
//
//      Types
//
typedef logic [MMR_DEV_ADDR_W-1:0] addr_t;
typedef logic [    MMR_DATA_W-1:0] data_t;
typedef logic [          EV_W-1:0] event_t;

enum addr_t {
    SR        = addr_t'( 8'h00 ),
    CR        = addr_t'( 8'h04 ),
    CR_S      = addr_t'( 8'h08 ),
    CR_C      = addr_t'( 8'h0C ),
    SYNC_EV   = addr_t'( 8'h10 ),
    SYNC_PRD  = addr_t'( 8'h14 ),
    ALIGN_EV0 = addr_t'( 8'h18 ),
    ALIGN_EV1 = addr_t'( 8'h1C ),
    ALIGN_EV2 = addr_t'( 8'h20 ),
    ALIGN_EV3 = addr_t'( 8'h24 ),
    TEST0_EV  = addr_t'( 8'h28 ),
    TEST1_EV  = addr_t'( 8'h2C ),
    TEST2_EV  = addr_t'( 8'h30 ),
    TEST3_EV  = addr_t'( 8'h34 )
} regs;

typedef struct packed
{
    logic clk_sync_manual;
    logic dds_sync_ena;
    logic dds_clk_ena;
} cr_t;

typedef struct packed
{
    logic odd_shift;
    logic dc_changed;
    logic afe_down;
    logic clk_sync_loss;
    logic clk_sync_done;
    logic dds_sync_ena;
    logic dds_clk_ena;
} sr_t;

//------------------------------------------------
//
//      Objects
//
sr_t          sr;
cr_t          cr        = 0;
event_t       sync_ev   = 1;
logic         sync_ev_p;
logic         sync_ev_recv;

event_t [3:0] align_ev  = 0;
logic   [3:0] align_ev_recv;
logic   [3:0] align_p;
logic   [3:0] align_ena  = '0;

event_t [3:0] test_ev  = 0;
logic   [3:0] test_ev_recv;
logic   [3:0] test_p;
logic   [3:0] test_ena  = '0;

logic         int_dds_clk_ena;
logic         int_dds_sync_ena;
logic         dds_clk = 0;

logic         sync_loss_p;
logic         dc_changed_p;
logic         afe_down_p;
logic         odd_shift_p;

data_t        cnt = data_t'(SYNC_PRD_DEF - 1);

//------------------------------------------------
//
//      Logic
//
logic [MMR_DEV_ADDR_W-1:0] addr;
logic [MMR_DATA_W-1:0] data;
logic read;
logic write_addr;
logic write_data;


logic [1:0] rst_cnt = '1;

assign aresetn = rst_cnt == '0;

always_ff @(posedge clk) begin
    if (rst_cnt)
        rst_cnt <= rst_cnt - 2'b01;
end


always_ff @(posedge clk) begin
    if (!aresetn) begin
        cr              <=  cr_t'(0);
        sync_ev         <= '0;
        sync_prd        <=  data_t'(SYNC_PRD_DEF);
        align_ena       <=  0;
        align_ev        <= '0;
        test_ena        <= '0;
        test_ev[0]      <= '0;
        test_ev[1]      <= '0;
        test_ev[2]      <= '0;
        test_ev[3]      <= '0;
        read            <= 0;
        write_addr      <= 0;
        write_data      <= 0;
        addr            <= '0;
        data            <= '0;
        mmr.rresp <= '0;
        mmr.bresp <= '0;
    end
    else begin

        if (sync_loss_p )
            sr.clk_sync_loss <= 1;
        if (afe_down_p  )
            sr.afe_down      <= 1;
        if (dc_changed_p)
            sr.dc_changed    <= 1;
        if (odd_shift_p ) begin 
            sr.odd_shift     <= 1;
            sr.clk_sync_loss <= 1;
        end

        mmr.arready <= 0;
        if(mmr.arvalid && !read) begin
            addr <= mmr.araddr;
            read <= 1;
            mmr.arready <= 1;
        end 

        mmr.rvalid <= read;
        if(mmr.rready && read) begin
            read <= 0;
            case (addr)
                CR:        mmr.rdata <= data_t'(cr);
                SR:        mmr.rdata <= data_t'(sr);
                SYNC_EV:   mmr.rdata <= data_t'(sync_ev);
                SYNC_PRD:  mmr.rdata <= data_t'(sync_prd);
                ALIGN_EV0: mmr.rdata <= data_t'(align_ev[0]);
                ALIGN_EV1: mmr.rdata <= data_t'(align_ev[1]);
                ALIGN_EV2: mmr.rdata <= data_t'(align_ev[2]);
                ALIGN_EV3: mmr.rdata <= data_t'(align_ev[3]);
                TEST0_EV:  mmr.rdata <= data_t'(test_ev[0]);
                TEST1_EV:  mmr.rdata <= data_t'(test_ev[1]);
                TEST2_EV:  mmr.rdata <= data_t'(test_ev[2]);
                TEST3_EV:  mmr.rdata <= data_t'(test_ev[3]);
                default:   mmr.rdata <= '0;
            endcase
        end 


        mmr.awready <= 0;
        if(mmr.awvalid && !write_addr) begin
            addr <= mmr.awaddr;
            write_addr  <= 1;
            mmr.awready <= 1;
        end 

        mmr.wready <= 0;
        if(mmr.wvalid && !write_data) begin
            data <= mmr.wdata;
            write_data <= 1;
            mmr.wready <= 1;
        end 

        mmr.bvalid <= write_addr && write_data;
        if(mmr.bready && write_addr && write_data) begin
            write_addr <= 0;
            write_data <= 0;
            case (addr)
                SR: begin
<<<<<<< HEAD
                    automatic sr_t sr_wr = sr_t'(mmr.writedata);
=======
                    automatic sr_t sr_wr = sr_t'(mmr.wdata);
>>>>>>> 2927dab (Chemge scc logic)
                    sr.clk_sync_loss <= sr.clk_sync_loss & sr_wr.clk_sync_loss;
                    sr.afe_down      <= sr.afe_down      & sr_wr.afe_down;
                    sr.dc_changed    <= sr.dc_changed    & sr_wr.dc_changed;
                    sr.odd_shift     <= sr.odd_shift     & sr_wr.odd_shift;
                end
                CR:       cr      <= cr_t'(data);
                CR_S:     cr      <= cr | cr_t'(data);
                CR_C:     cr      <= cr & ~(cr_t'(data));
                SYNC_EV:  sync_ev <= event_t'(data);
                SYNC_PRD: begin
                    if (data != 0)
                        sync_prd <= data_t'(data);
                end                
                ALIGN_EV0: begin
                    align_ev[0]   <= event_t'(data);
                    align_ena[0]  <= event_t'(data) != '0;
                end
                ALIGN_EV1: begin
                    align_ev[1]   <= event_t'(data);
                    align_ena[1]  <= event_t'(data) != '0;
                end
                ALIGN_EV2: begin
                    align_ev[2]   <= event_t'(data);
                    align_ena[2]  <= event_t'(data) != '0;
                end
                ALIGN_EV3: begin
                    align_ev[3]   <= event_t'(data);
                    align_ena[3]  <= event_t'(data) != '0;
                end
                TEST0_EV: begin
                    test_ev[0]  <= event_t'(data);
                    test_ena[0] <= event_t'(data) != '0;
                end
                TEST1_EV: begin
                    test_ev[1]  <= event_t'(data);
                    test_ena[1] <= event_t'(data) != '0;
                end
                TEST2_EV: begin
                    test_ev[2]  <= event_t'(data);
                    test_ena[2] <= event_t'(data) != '0;
                end
                TEST3_EV: begin
                    test_ev[3]  <= event_t'(data);
                    test_ena[3] <= event_t'(data) != '0;
                end
                default;
            endcase
        end 
    end
end

//------------------------------------------------
assign sr.dds_clk_ena  = cr.clk_sync_manual ? cr.dds_clk_ena  : int_dds_clk_ena;
assign sr.dds_sync_ena = cr.clk_sync_manual ? cr.dds_sync_ena : int_dds_sync_ena;
assign dds_clk_ena     = sr.dds_clk_ena;
assign llrf_sync_done  = sr.clk_sync_done;

//------------------------------------------------
assign sync_ev_recv    = ev == sync_ev && sync_ev != 0;

//------------------------------------------------
always_ff @(posedge clk) begin
    automatic logic cnt_reload = cnt == 0;
    if (sr.dds_sync_ena) begin
        cnt <= cnt - 1;
        if (cnt_reload || sync_ev_recv) 
            cnt <= sync_prd - 1;
    end
end

//------------------------------------------------
always_ff @(posedge clk) dds_clk     <= sync_ev_recv ? 0 : ~dds_clk;
always_ff @(posedge clk) dds_clk_out <= sr.dds_clk_ena ? dds_clk : 0;

assign odd_shift_p = sr.clk_sync_done && sync_ev_recv && dds_clk == 0;

//------------------------------------------------
always_ff @(posedge clk) align_x2 <= align_p[0] | align_p[1] | align_p[2] | align_p[3];
genvar i;
generate
    for (i=0; i<4; i=i+1) begin : align_pulse_formers
        assign align_ev_recv[i] = align_ev[i] != 0 && ev == align_ev[i];
        pf_m #(.WIDTH(2)) align_pf (.clk(clk), .in(align_ev_recv[i]), .out(align_p[i]));
    end
endgenerate

//------------------------------------------------
generate
    for (i=0; i<4; i=i+1) begin : test_pulse_formers
        assign test_ev_recv[i] = test_ev[i] != 0 && ev == test_ev[i];
        pf_m #(.WIDTH(2)) test_pf (.clk(clk), .in(test_ev_recv[i]), .out(test_p[i]));
    end
endgenerate

pf_m #(.WIDTH(3), .POR("ON")) rst_pf        (.clk(clk), .in(0),                           .out(rst)         );

pf_m #(.WIDTH(1)            ) sync_pf       (.clk(clk), .in(sr.dds_sync_ena && cnt == 0), .out(sync)        );
pf_m #(.WIDTH(2)            ) sync_x2_pf    (.clk(clk), .in(sr.dds_sync_ena && cnt == 0), .out(sync_x2)     );


pf_m #(.WIDTH(1)            ) afe_down_pf   (.clk(clk), .in(~afe_init_done),              .out(afe_down_p)  );
pf_m #(.WIDTH(1)            ) dc_changed_pf (.clk(clk), .in(~dc_coarse_done),             .out(dc_changed_p));
pf_m #(.WIDTH(1)            ) sync_loss_pf  (.clk(clk), .in(~sr.clk_sync_done),           .out(sync_loss_p) );


pf_m #(.WIDTH(PS_SYNC_WIDTH)) PS_pf         (.clk(clk), .in(sync),                        .out(sync_PS)     );

//------------------------------------------------
llrf_init_m llrf_init
(
    .clk             ( clk                 ),
    .rst             ( rst                 ),
    
    .mode            ( !cr.clk_sync_manual ),
    .sync_done       ( sr.clk_sync_done    ),
    
    .sync            ( sync                ),
    .sync_ev_p       ( sync_ev_recv        ),
    
    .afe_ready       ( afe_init_done       ),
    .link_ok         ( evr_link_ok         ),
    .dc_coarse_done  ( dc_coarse_done      ),

    .dds_clk_ena     ( int_dds_clk_ena     ),
    .dds_sync_ena    ( int_dds_sync_ena    ),
    
    .afe_ctrl_i      ( afe_ctrl_i          )
);
    
//------------------------------------------------
endmodule : scc_m

`endif//__SCC_SV__