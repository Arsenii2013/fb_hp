`ifndef __LLRF_INIT_SV__
`define __LLRF_INIT_SV__

`include "top.svh"
`include "afe.svh"
`include "axi4_lite_if.svh"

//------------------------------------------------
//
//      LLRF initialization synchronization module
//
module llrf_init_m import afe_pkg::*;
(
    input  logic   clk,
    input  logic   rst,

    input  logic   mode,

    input  logic   sync,
    input  logic   sync_ev_p,

    input  logic   afe_ready,
    input  logic   link_ok,
    input  logic   dc_coarse_done,

    output logic   dds_clk_ena,
    output logic   dds_sync_ena,

    output logic   sync_done,
    
    axi4_lite_if.m afe_ctrl_i
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Parameters
//

//------------------------------------------------
//
//      Types
//
typedef enum {
    initfsmIDLE,
    initfsmENA_DDS_CLK,
    initfsmENA_DDS_SYNC,
    initfsmWAIT_AFE_READY,
    initfsmSETUP_AFE,
    initfsmDONE
} initfsm_state_t;

typedef enum {
    stfsmAFE_RESET,
    stfsmAFE_READY,
    stfsmLINK_OK,
    stfsmDC_COARSE_DONE,
    stfsmSYNC_DONE
} stfsm_state_t; // status fsm

//------------------------------------------------
//
//      Objects
//
initfsm_state_t initfsm_state = initfsmIDLE,    initfsm_next;
stfsm_state_t   stfsm_state   = stfsmAFE_RESET, stfsm_next;

//------------------------------------------------
//
//      Logic
//


always_ff @(posedge clk) begin
    if (rst) begin
        initfsm_state    <= initfsmIDLE;
        dds_clk_ena      <= 0;
        dds_sync_ena     <= 0;
        afe_ctrl_i.awvalid <= 0;
        afe_ctrl_i.arvalid <= 0;
        afe_ctrl_i.wvalid  <= 0;                                
    end
    else begin
        initfsm_state <= initfsm_next;
        case (initfsm_state)
        //------------------------------------------------
            initfsmENA_DDS_CLK:  dds_clk_ena  <= 1;
        //------------------------------------------------
            initfsmENA_DDS_SYNC: dds_sync_ena <= 1;
        //------------------------------------------------
            initfsmSETUP_AFE: begin
                if (sync) begin
                    afe_ctrl_i.awvalid   <= 1;
                    afe_ctrl_i.awaddr    <= AFE_SYS_BASE + CTRL_REG;
                    afe_ctrl_i.wvalid    <= 1;
                    afe_ctrl_i.wdata     <= '0;
                    afe_ctrl_i.bready    <= 1;
                end
            end
        //------------------------------------------------
        endcase
        
        if ((afe_ctrl_i.awvalid & afe_ctrl_i.awready)) begin
            afe_ctrl_i.awvalid <= 0;
        end
        if ((afe_ctrl_i.wvalid  & afe_ctrl_i.wready)) begin
            afe_ctrl_i.wvalid <= 0;
        end
        if ((afe_ctrl_i.arvalid & afe_ctrl_i.arready)) begin
            afe_ctrl_i.arvalid <= 0;
        end
        if ((afe_ctrl_i.bvalid  & afe_ctrl_i.bready)) begin
            afe_ctrl_i.bready <= 0;
        end

        if (!afe_ready) begin
            afe_ctrl_i.awvalid <= 0;
            afe_ctrl_i.wvalid  <= 0;
            afe_ctrl_i.arvalid <= 0;
            afe_ctrl_i.bready  <= 0;
        end
    end
end

always_comb begin
    if (rst) begin
        initfsm_next = initfsmIDLE;
    end
    else begin
        if (mode) begin
            automatic logic afe_wr_done = afe_ctrl_i.bvalid & afe_ctrl_i.bready;
            case (initfsm_state)
                initfsmIDLE:                initfsm_next = initfsmENA_DDS_CLK;
                initfsmENA_DDS_CLK:         initfsm_next = initfsmENA_DDS_SYNC;
                initfsmENA_DDS_SYNC:        initfsm_next = initfsmWAIT_AFE_READY;
                initfsmWAIT_AFE_READY:      initfsm_next = sync & afe_ready ? initfsmSETUP_AFE : initfsmWAIT_AFE_READY;
                initfsmSETUP_AFE:           initfsm_next = afe_ready ? (afe_wr_done ? initfsmDONE : initfsmSETUP_AFE) : initfsmWAIT_AFE_READY;
                initfsmDONE:                initfsm_next = afe_ready ? initfsmDONE : initfsmWAIT_AFE_READY;
            endcase            
        end
        else begin
            initfsm_next = initfsmIDLE;
        end
    end
end

//------------------------------------------------
assign sync_done = stfsm_state == stfsmSYNC_DONE;

always_ff @(posedge clk) begin
    if (rst) begin
        stfsm_state <= stfsmAFE_RESET;
    end
    else begin
        stfsm_state <= stfsm_next;            
        if (stfsm_state != stfsm_next) begin
            case (stfsm_next)
                stfsmAFE_RESET:      $display("[%t] <llrf clk sync> wait afe ready",      $realtime);
                stfsmAFE_READY:      $display("[%t] <llrf clk sync> wait link ok",        $realtime);
                stfsmLINK_OK:        $display("[%t] <llrf clk sync> wait dc coarse done", $realtime);
                stfsmDC_COARSE_DONE: $display("[%t] <llrf clk sync> wait sync event",     $realtime);
            endcase
        end
    end
end

always_comb begin
    if (rst) begin
        stfsm_next = stfsmAFE_RESET;
    end
    else begin
        if (mode) begin
            case (stfsm_state)
                stfsmAFE_RESET:      stfsm_next = afe_ready ? stfsmAFE_READY : stfsmAFE_RESET;
                stfsmAFE_READY:      stfsm_next = link_ok ? stfsmLINK_OK : stfsmAFE_READY;
                stfsmLINK_OK:        stfsm_next = dc_coarse_done ? stfsmDC_COARSE_DONE : stfsmLINK_OK;
                stfsmDC_COARSE_DONE: stfsm_next = sync_ev_p ? stfsmSYNC_DONE : stfsmDC_COARSE_DONE;
                stfsmSYNC_DONE:      stfsm_next = stfsmSYNC_DONE;
            endcase

            if      (!afe_ready     ) stfsm_next = stfsmAFE_RESET;
            else if (!link_ok       ) stfsm_next = stfsmAFE_READY;
            else if (!dc_coarse_done) stfsm_next = stfsmLINK_OK;
        end
        else begin
            stfsm_next = stfsmAFE_RESET;
        end
    end
end

//------------------------------------------------
endmodule : llrf_init_m

//------------------------------------------------
//
//      LLRF init module testbench
//
module llrf_initTB;

//------------------------------------------------
`timescale 1ns / 1ps;

//------------------------------------------------
//
//      Prameters
//
localparam CLK_PRD = 10ns;
localparam DDS_SYNC_PRD = 10;

//------------------------------------------------
//
//      Objects
//
logic clk            = 0;
logic rst            = 1;
logic mode           = 0;
logic sync           = 0;
logic sync_ev_p      = 0;
logic afe_ready      = 0;
logic link_ok        = 0;
logic dc_coarse_done = 0;

logic clk_ena;
logic sync_ena;
logic clk_sync_done;

axi4_lite_if #(
    .AW        ( 32   ),
    .DW        ( 32   )
) afe_ctrl_i();

//------------------------------------------------
//
//      Logic
//
always #(CLK_PRD/2) clk = ~clk;

//------------------------------------------------
int cnt = 0;

always @(posedge clk) begin
    sync <= 0;
    cnt <= cnt + 1;
    if (cnt == DDS_SYNC_PRD - 1) begin
        cnt <= 0;
        sync <= 1;
    end
    if (sync_ev_p) begin
        cnt <= 0;
        sync <= 1;
    end
end

//------------------------------------------------
initial begin

    $display("");
    $display("test> power on");
    #100ns
    rst = 0;
    #200ns
    mode = 1;
    #200ns
    afe_ready = 1;
    #200ns
    link_ok = 1;
    #200ns
    dc_coarse_done = 1;
    #200ns
    @(posedge clk) sync_ev_p = 1;
    @(posedge clk) sync_ev_p = 0;

    #1000ns
    $display("");
    $display("test> dc target is changed");
    dc_coarse_done = 0;
    #100ns
    dc_coarse_done = 1;
    #100ns
    @(posedge clk) sync_ev_p = 1;
    @(posedge clk) sync_ev_p = 0;

    #1000ns
    $display("");
    $display("test> link is lost");
    link_ok = 0;
    dc_coarse_done = 0;
    #100ns
    link_ok = 1;
    #100ns
    dc_coarse_done = 1;
    #100ns
    @(posedge clk) sync_ev_p = 1;
    @(posedge clk) sync_ev_p = 0;

    #1000ns
    $display("");
    $display("test> afe reset");
    afe_ready = 0;
    link_ok = 0;
    dc_coarse_done = 0;
    #100ns
    afe_ready = 1;
    #100ns
    link_ok = 1;
    #100ns
    dc_coarse_done = 1;
    #100ns
    @(posedge clk) sync_ev_p = 1;
    @(posedge clk) sync_ev_p = 0;

    @(posedge clk_sync_done)
    #100ns $stop();
end

//------------------------------------------------
//
//      Instances
//
llrf_init_m llrf_init_dut
(
    .clk            ( clk            ),
    .rst            ( rst            ),

    .mode           ( mode           ),
    
    .sync           ( sync           ),
    .sync_ev_p      ( sync_ev_p      ),
    .afe_ready      ( afe_ready      ),
    .link_ok        ( link_ok        ),
    .dc_coarse_done ( dc_coarse_done ),
    
    .dds_clk_ena    ( clk_ena        ),
    .dds_sync_ena   ( sync_ena       ),
    
    .sync_done      ( clk_sync_done  ),

    .afe_ctrl_i     ( afe_ctrl_i     )
);
//------------------------------------------------
mem_wrapper
ps_mem_i (
    .aclk(clk),
    .aresetn(!rst),
    .axi(afe_ctrl_i),
    .offset(0)
);

//------------------------------------------------
endmodule : llrf_initTB

`endif//__LLRF_INIT_SV__