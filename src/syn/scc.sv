`ifndef __SCC_SV__
`define __SCC_SV__

`include "top.svh"

module scc_m
(
    input  logic                  clk,
    output logic                  aresetn,
    input  logic                  cdr_locked,

    axi4_lite_if.s                mmr,

    input  logic [      EV_W-1:0] ev,
    output logic                  sync,
    output logic                  align,
    output logic                  log_start,

    output logic                  dds_clk_ena,

    output logic                  sync_x2, // x2 repeated outputs
    output logic                  align_x2,

    output logic [           3:0] test_out,

    output logic [MMR_DATA_W-1:0] sync_prd
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Types
//
typedef logic [MMR_DEV_ADDR_W-1:0] addr_t;
typedef logic [    MMR_DATA_W-1:0] data_t;
typedef logic [          EV_W-1:0] event_t;

enum addr_t {
    SR       = addr_t'( 8'h00 ),
    CR       = addr_t'( 8'h04 ),
    CR_S     = addr_t'( 8'h08 ),
    CR_C     = addr_t'( 8'h0C ),
    SYNC_EV  = addr_t'( 8'h10 ),
    SYNC_PRD = addr_t'( 8'h14 ),
    ALIGN_EV = addr_t'( 8'h18 ),
    TEST0_EV = addr_t'( 8'h1C ),
    TEST1_EV = addr_t'( 8'h20 ),
    TEST2_EV = addr_t'( 8'h24 ),
    TEST3_EV = addr_t'( 8'h28 )
} regs;

typedef struct packed
{
    logic dds_sync_ena;
    logic dds_clk_ena;
} cr_t;

//------------------------------------------------
//
//      Objects
//
data_t      sr;
cr_t        cr        = cr_t'(0);
event_t     sync_ev   = '0;

event_t     align_ev  = '0;
logic       align_ena =  0;

logic [3:0] test_ena  = '0;
event_t     test_ev[4];

data_t      cnt = data_t'(SYNC_PRD_DEF);

logic [1:0] rst_cnt = '1;


logic [MMR_DEV_ADDR_W-1:0] addr;
logic [MMR_DATA_W-1:0] data;
logic read;
logic write_addr;
logic write_data;


//------------------------------------------------
//
//      Logic
//
assign aresetn = rst_cnt == '0;

always_ff @(posedge clk) begin
    if (rst_cnt)
        rst_cnt <= rst_cnt - 2'b01;
end

//----------------------------------------------

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
    end
    else begin
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
                CR:       mmr.rdata <= data_t'(cr);
                SR:       mmr.rdata <= data_t'(sr);
                SYNC_EV:  mmr.rdata <= data_t'(sync_ev);
                SYNC_PRD: mmr.rdata <= data_t'(sync_prd);
                ALIGN_EV: mmr.rdata <= data_t'(align_ev);
                TEST0_EV: mmr.rdata <= data_t'(test_ev[0]);
                TEST1_EV: mmr.rdata <= data_t'(test_ev[1]);
                TEST2_EV: mmr.rdata <= data_t'(test_ev[2]);
                TEST3_EV: mmr.rdata <= data_t'(test_ev[3]);
                default:  mmr.rdata <= '0;
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
                CR:       cr      <= cr_t'(data);
                CR_S:     cr      <= cr | cr_t'(data);
                CR_C:     cr      <= cr & ~(cr_t'(data));
                SYNC_EV:  sync_ev <= event_t'(data);
                SYNC_PRD: begin
                    if (data != 0)
                        sync_prd <= data_t'(data);
                end
                ALIGN_EV: begin
                    align_ev  <= event_t'(data);
                    align_ena <= event_t'(data) != '0;
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

//always_comb begin
//    case (mmr.address)
//        CSR:      mmr.readdata = data_t'(csr);
//        SYNC_EV:  mmr.readdata = data_t'(sync_ev);
//        SYNC_PRD: mmr.readdata = data_t'(sync_prd);
//        ALIGN_EV: mmr.readdata = data_t'(align_ev);
//        default:  mmr.readdata = '0;
//    endcase
//end

//------------------------------------------------
assign sr = data_t'(cdr_locked);
assign dds_clk_ena = cr.dds_clk_ena;

//------------------------------------------------
always_ff @(posedge clk) begin
    automatic logic ev_recieved = ev == align_ev;
    align    <= align_ena &  ev_recieved;
    align_x2 <= align_ena & (ev_recieved | align);
end

//------------------------------------------------
always_ff @(posedge clk) begin
    automatic logic ev_recieved = ev == sync_ev && sync_ev != 0;
    automatic logic reload      = cnt == data_t'(1);
    if (cr.dds_sync_ena) begin
        cnt <= cnt - data_t'(1);
        if (reload || ev_recieved) 
            cnt <= sync_prd;
    end
    sync    <= cr.dds_sync_ena &  reload;
    sync_x2 <= cr.dds_sync_ena & (reload | sync);
end

//------------------------------------------------
always_ff @(posedge clk) begin
    automatic logic ev_recieved = ev == sync_ev && sync_ev != 0;
    log_start <= cr.dds_sync_ena & ev_recieved;
end

//------------------------------------------------
genvar i;
generate
for (i=0; i<4; i++) begin : test_out_pulse_formers
    logic       test_pulse;
    logic       test_pulse_expand;
    logic       test_pulse_cnt = '0;

    assign test_pulse  = test_ena[i] && ev == test_ev[i];
    assign test_out[i] = test_pulse_cnt != 1'b0;

    always_ff @(posedge clk) begin
        if(test_pulse) 
            test_pulse_cnt <= 1'b1;
        else
            if(test_pulse_cnt != 1'b0)
                test_pulse_cnt <= test_pulse_cnt-1;         
    end
end
endgenerate

//------------------------------------------------
endmodule : scc_m
