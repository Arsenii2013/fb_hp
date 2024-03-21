`ifndef __DDSC_CORE_SV__
`define __DDSC_CORE_SV__

// synopsys translate off
`define SIMULATOR
// synopsys translate on

`include "../hp.svh"

module ddsc_core_m import hp_pkg::*;
#(
    parameter CONV_TBL_AW     = 8,
    parameter CONV_TBL_DW     = 8,
    parameter DESC_AW         = 6,
    parameter DESC_ITEM_COUNT = 16,
    parameter DESC_TBL_AW     = 10,
    parameter DESC_TBL_DW     = 32,
    parameter B_FIELD_W       = 32,
    parameter TIME_W          = 64,
    parameter CLK_PRD         = 10
)
(
    input  logic                   clk,
    input  logic                   rst,

    input  logic                   sync,
    input  logic [DESC_TBL_DW-1:0] sync_prd,
    input  logic [     TIME_W-1:0] timestamp,

    input  logic [CONV_TBL_DW-1:0] conv_tbl_out,
    output logic [DESC_TBL_AW-1:0] desc_tbl_addr,
    input  logic [DESC_TBL_DW-1:0] desc_tbl_data,

    input  logic [  B_FIELD_W-1:0] b_field,
    input  logic                   b_ready,

    avmm_if.master                 data_out_i,
    avmm_if.master                 shared_data_out_i
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Parameters
//
localparam DESC_OFFS_AW = $clog2(DESC_ITEM_COUNT);

//------------------------------------------------
//
//      Types
//
typedef logic [        DESC_AW-1:0] desc_t;
typedef logic [   DESC_OFFS_AW-1:0] offs_t;
typedef logic [    DESC_TBL_DW-1:0] item_t;
typedef logic [         TIME_W-1:0] time_t;

typedef logic [        LLRF_DW-1:0] llrf_data_t;

typedef struct packed {
    logic                           valid;
    desc_t                          desc;
} conv_data_t;

typedef struct packed {
    logic [DESC_TBL_DW-DESC_AW-3:0] rsrv;
    desc_t                          next;
    logic                           mode;
    logic                           ena;
} chain_data_t;

typedef struct {
    logic  start;
    logic  done;
    logic  mode;
    item_t fstart;
    item_t target;
    item_t dt;
    logic  valid;
    item_t out;
} adj_data_t;

typedef struct {
    logic        start;
    logic [31:0] field;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] c;
    logic [31:0] k;
    logic [31:0] freq;
    logic        ready;
} b2f_data_t;

typedef enum {
    WAIT_SYNC,
    PARSE,
    EXEC,
    DELAY
} state_t;

enum offs_t {
    TYPE     = offs_t'( 0),
    CHAIN    = offs_t'(13),
    DELAY_LO = offs_t'(14),
    DELAY_HI = offs_t'(15)
} items_list;

typedef enum item_t {
    NOP,
    B2F,
    F,
    dF,
    TYPES_COUNT
} desc_type_t;

typedef enum {
    b2fIDLE,
    b2fWAIT_ACK,
    b2fCONV,
    b2fWAIT_SYNC
} b2f_state_t;

//------------------------------------------------
//
//      Objects
//
state_t      state = WAIT_SYNC, next;

desc_t       desc;
desc_t       next_desc;
offs_t       offs = '0;
offs_t       rptr = '0;
item_t       item[DESC_ITEM_COUNT];

conv_data_t  conv_out = '0;
chain_data_t chain;
time_t       delay;
time_t       cnt = '0;

logic        done = 1;
desc_type_t  desc_type;

//------------------------------------------------
adj_data_t   adj;

//------------------------------------------------
b2f_data_t   b2f;
logic        b2f_mode  = 0;
b2f_state_t  b2f_state = b2fIDLE;

//------------------------------------------------
llrf_data_t  desc_res;
logic        desc_res_write;

llrf_data_t  b2f_res;
logic        b2f_res_write;

//------------------------------------------------
//
//      Tasks
//
task automatic exec();
    if (!done) begin
        case (desc_type)
            default: begin
                done <= 1;
            end
            F: begin
                desc_res       <= item[1];
                desc_res_write <= 1;
                done           <= 1;
            end
            dF: begin
                if (adj.valid) begin
                    desc_res       <= adj.out;
                    desc_res_write <= 1;
                end
                if (adj.done) begin
                    done <= 1;
                end
            end
            B2F: begin
                b2f_mode <= 1;
                done     <= 1;
            end
        endcase
    end
endtask

//------------------------------------------------
//
//      Logic
//
assign adj.start  = state == PARSE && next == EXEC && desc_type == dF;
assign adj.mode   = 0;
assign adj.fstart = desc_res;
assign adj.target = item[1];
assign adj.dt     = item[2];

//------------------------------------------------
assign b2f.field  = b_field;
assign b2f.a      = item[1];
assign b2f.b      = item[2];
assign b2f.c      = item[3];
assign b2f.k      = item[4];

//------------------------------------------------
assign desc_type = item[TYPE] < TYPES_COUNT ? desc_type_t'(item[TYPE]) : NOP;
assign chain     = chain_data_t'(item[CHAIN]);
assign next_desc = chain.mode ? chain.next : desc_t'(desc + 1);
assign delay     = {item[DELAY_HI], item[DELAY_LO]};

//------------------------------------------------
always_ff @(posedge clk) begin
    automatic conv_data_t tmp = conv_data_t'(conv_tbl_out);
    if (rst) begin
        conv_out <= '0;
    end
    else begin
        if (tmp.valid)
            conv_out <= tmp;
        if (state != WAIT_SYNC)
            conv_out <= '0;
    end
end

always_comb begin
    case (state)
        PARSE:   desc_tbl_addr = {desc, offs};
        EXEC,
        DELAY:   desc_tbl_addr = chain.ena ? {next_desc, offs} : {conv_out.desc, offs};
        default: desc_tbl_addr = {conv_out.desc, offs};
    endcase
end

//------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        state          <= WAIT_SYNC;
        done           <= 1;
        b2f_mode       <= 0;
        desc_res       <= 0;
        desc_res_write <= 0;
    end
    else begin
        state <= next;
        case (state)
            WAIT_SYNC: begin
                offs <= '0;
                rptr <= '0;
                desc <= conv_out.desc;
                if (sync & conv_out.valid) begin
                    $display("[%t]: <%0d> <ddsc core> select descriptor at 0x%0x", $realtime, timestamp, conv_out.desc);
                    offs <= offs_t'(1);
                end                
            end
            PARSE: begin
                item[rptr] <= desc_tbl_data;
                $display("[%t]: <%0d> <ddsc core> descriptor field %2d = %0d", $realtime, timestamp, rptr, desc_tbl_data);
                if (offs < offs_t'(DESC_ITEM_COUNT-1))
                    offs <= offs_t'(offs + 1);
                rptr <= offs_t'(rptr + 1);
                if (rptr == offs_t'(DESC_ITEM_COUNT-1)) begin
                    rptr <= '0;
                    offs <= '0;
                    done <= 0;
                end
                if (rptr == 0) begin
                    if (desc_tbl_data < TYPES_COUNT && desc_type_t'(desc_tbl_data) != B2F)
                        b2f_mode <= 0;
                end
            end
            EXEC: begin
                exec();
                if (done & sync) begin
                    if (chain.ena) begin
                        $display("[%t]: <%0d> <ddsc core> next descriptor in chain at 0x%0x", $realtime, timestamp, next_desc);
                        if (delay == '0) begin
                            desc <= next_desc;
                            offs <= offs_t'(1);
                        end
                        else begin
                            $display("[%t]: <%0d> <ddsc core> delay is %0dns", $realtime, timestamp, delay);
                            cnt <= delay - time_t'(sync_prd);
                        end
                    end
                end
            end
            DELAY: begin
                if (sync) begin
                    if (cnt < time_t'(sync_prd)) begin
                        desc <= next_desc;
                        offs <= offs_t'(1);
                    end
                    else begin
                        cnt <= cnt - time_t'(sync_prd);
                    end
                end
            end
        endcase

        if (desc_res_write) desc_res_write <= 0;
    end
end

always_comb begin
    automatic logic delay_done = cnt < time_t'(sync_prd);
    if (rst) begin
        next = WAIT_SYNC;
    end
    else begin
        case (state)
            WAIT_SYNC:         next = sync & conv_out.valid ? PARSE : WAIT_SYNC;
            PARSE:             next = rptr == offs_t'(DESC_ITEM_COUNT-1) ? EXEC : PARSE;
            EXEC: begin
                if (chain.ena) next = sync & done ? (delay == '0 ? PARSE : DELAY) : EXEC;
                else           next = done ? WAIT_SYNC : EXEC;
            end
            DELAY: begin
                if (chain.ena) next = sync & delay_done ? PARSE : DELAY;
                else           next = delay_done ? WAIT_SYNC : DELAY;
            end
        endcase
    end
end

`ifdef SIMULATOR
always @(posedge done)    
    $display("[%t]: <%0d> <ddsc core> executed %0s type descriptor at 0x%0x", $realtime, timestamp, desc_type.name(), desc);
`endif        

//------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        b2f_state     <= b2fIDLE;
        b2f.start     <= 0;
        b2f_res       <= 0;
        b2f_res_write <= 0;
    end
    else begin
        if (b2f_mode) begin
            case (b2f_state)
                b2fIDLE: begin
                    b2f.start <= 0;
                    if (b_ready) begin
                        b2f.start <= 1;
                        b2f_state <= b2fWAIT_ACK;
                    end
                end
                b2fWAIT_ACK: begin
                    if (~b2f.ready) begin
                        b2f.start <= 0;
                        b2f_state <= b2fCONV;
                    end
                end
                b2fCONV: begin
                    if (b2f.ready) begin                    
                        b2f_state     <= b2fWAIT_SYNC;
                        b2f_res       <= b2f.freq;
                        b2f_res_write <= 1;
                    end
                end
                b2fWAIT_SYNC: begin
                    b2f_res_write <= 0;
                    if (sync)
                        b2f_state <= b2fIDLE;
                end
            endcase
        end
        else begin
            b2f_state <= b2fIDLE;
            b2f.start <= 0;
        end

        if (b2f_res_write) b2f_res_write <= 0;
    end
end

//------------------------------------------------
initial data_out_i.write      = 0;
initial data_out_i.writedata  = 0;

assign  data_out_i.read       = 0;
assign  data_out_i.address    = 0;
assign  data_out_i.byteenable = 0;
assign  data_out_i.burstcount = 1;

always_ff @(posedge clk) begin
    if (b2f_mode) begin
        if (b2f_res_write) begin
            data_out_i.write <= 1;
            data_out_i.writedata <= b2f_res;
        end
        if (data_out_i.write && ~data_out_i.waitrequest)
            data_out_i.write <= 0;
    end
    else begin
        if (desc_res_write) begin
            data_out_i.write <= 1;
            data_out_i.writedata <= desc_res;
        end
        if (data_out_i.write && ~data_out_i.waitrequest)
            data_out_i.write <= 0;
    end
end

//------------------------------------------------
initial shared_data_out_i.write      = 0;
initial shared_data_out_i.writedata  = 0;

assign  shared_data_out_i.read       = 0;
assign  shared_data_out_i.address    = 0;
assign  shared_data_out_i.byteenable = 0;
assign  shared_data_out_i.burstcount = 1;

always_ff @(posedge clk) begin
    if (b2f_mode) begin
        if (b2f_res_write) begin
            shared_data_out_i.write <= 1;
            shared_data_out_i.writedata <= b2f_res;
        end
        if (shared_data_out_i.write && ~shared_data_out_i.waitrequest)
            shared_data_out_i.write <= 0;
    end
    else begin
        if (desc_res_write) begin
            shared_data_out_i.write <= 1;
            shared_data_out_i.writedata <= desc_res;
        end
        if (shared_data_out_i.write && ~shared_data_out_i.waitrequest)
            shared_data_out_i.write <= 0;
    end
end

//------------------------------------------------
//
//      Instances
//
adj_m #(
    .DW       ( DESC_TBL_DW )
)
freq_ph_adj
(
    .clk      ( clk         ),
    .rst      ( rst         ),

    .sync     ( sync        ),
    .sync_prd ( sync_prd    ),
    .start    ( adj.start   ),
    .done     ( adj.done    ),
    
    .mode     ( adj.mode    ),
    .fstart   ( adj.fstart  ),
    .target   ( adj.target  ),
    .dt       ( adj.dt      ),

    .valid    ( adj.valid   ),
    .out      ( adj.out     )
);
//------------------------------------------------
b2f_m b2f_conv
(
    .clk      ( clk         ),
    .rst      ( rst         ),
    
    .start    ( b2f.start   ),

    .field    ( b2f.field   ),
    .a        ( b2f.a       ),
    .b        ( b2f.b       ),
    .c        ( b2f.c       ),
    .k        ( b2f.k       ),
    
    .freq     ( b2f.freq    ),
    .ready    ( b2f.ready   )
);
//------------------------------------------------
endmodule : ddsc_core_m

`endif//__DDSC_CORE_SV__
