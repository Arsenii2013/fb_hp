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
        mmr.rresp <= '0;
        mmr.bresp <= '0;
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
    logic [1:0] test_pulse_cnt = '0;

    assign test_pulse  = test_ena[i] && ev == test_ev[i];
    assign test_out[i] = test_pulse_cnt != 'b0;

    always_ff @(posedge clk) begin
        if(test_pulse) 
            test_pulse_cnt <= 'b11;
        else
            if(test_pulse_cnt != 'b0)
                test_pulse_cnt <= test_pulse_cnt-1;         
    end
end
endgenerate

//------------------------------------------------
logic [$clog2(PS_SYNC_WIDTH):0] PS_pulse_cnt = '0;

assign sync_PS = PS_pulse_cnt != 'b0;

always_ff @(posedge clk) begin
    if(sync) 
        PS_pulse_cnt <= PS_SYNC_WIDTH;
    else
        if(PS_pulse_cnt != 'b0)
            PS_pulse_cnt <= PS_pulse_cnt-1;         
end

//------------------------------------------------
endmodule : scc_m

module sccTB();
    logic clk;
    logic aresetn;
    logic cdr_locked;

    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    initial begin
        cdr_locked = 0;
        @(negedge aresetn);
        for(int i =0; i < 10; i++) begin
            @(posedge clk);
        end 
        cdr_locked = 1;
    end 

    logic sync;
    logic align;
    logic log_start;
    logic dds_clk_ena;
    logic sync_x2;
    logic align_x2;
    logic test_out;
    logic sync_prd;

    logic [7:0] ev;
    logic [7:0] shared_data;
    axi4_lite_if #(.AW(32), .DW(32)) mmr();

    scc_m DUT(
        .clk(clk),
        .aresetn(aresetn),
        .cdr_locked(cdr_locked),

        .mmr(mmr),

        .ev(ev),
        .sync(sync),
        .align(align),
        .log_start(log_start),

        .dds_clk_ena(dds_clk_ena),

        .sync_x2(sync_x2), 
        .align_x2(align_x2),

        .test_out(test_out),

        .sync_prd(sync_prd)
    );

    axi_master mmr_master(
        .axi(mmr),
        .aclk(clk),
        .aresetn(aresetn)
    );

    frame_gen frame_gen_i(
        .tx_data({ev, shared_data}),
        .is_k(),
        .tx_clk(clk),
        .ready(cdr_locked)
    );

    logic [31:0] recv_data;
    initial begin
        @(posedge cdr_locked);
        for(int i =0; i < 10; i++) begin
            @(posedge clk);
        end 

        mmr_master.read(32'h00, recv_data); // check cdr_locked
        mmr_master.write(32'h10, 32'h15); // write sync_ev
        mmr_master.write(32'h14, 32'd10); // write sync_prd
        mmr_master.write(32'h18, 32'h15); // write align_ev
        mmr_master.write(32'h1c, 32'h15); // write test0_ev

        for(int i =0; i < 100; i++) begin
            @(posedge clk);
        end 
        mmr_master.write(32'h04, 32'hFF); // enable all cr
        #1000;
        $stop();
    end 

endmodule

module axi_master(
    axi4_lite_if.m  axi,
    input  logic    aclk,
    input  logic    aresetn
);
    task automatic read(input [32:0] addr, output [32:0] data);
        begin

        logic [3:0] rresp;
        
        @(posedge aclk)
        axi.araddr  <= addr;
        axi.arvalid <= 1;
        axi.rready  <= 1;

        for(;;) begin
            @(posedge aclk)
            if(axi.arready)
                break;
        end
        axi.arvalid <= 0;

        for(;;) begin
            @(posedge aclk)
            if(axi.rvalid)
                break;
        end
        data        = axi.rdata;
        rresp       = axi.rresp;
        axi.rready  <= 0;

        if(rresp != 'b000)
            $display("RRESP isnt equal 0! RRESP = %x", rresp);

        $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
        end
    endtask

    task automatic write(input [32:0] addr, input [32:0] data);
        begin

        logic [3:0] wresp;
        
        @(posedge aclk)
        axi.awaddr  <= addr;
        axi.wdata   <= data;
        axi.awvalid <= 1;
        axi.wvalid  <= 1;
        axi.wstrb   <= 'hFFFF;
        axi.bready  <= 1;

        for(;;) begin
            @(posedge aclk)
            if(axi.awready && axi.wready)
                break;
        end
        axi.awvalid <= 0;
        axi.wvalid  <= 0;

        for(;;) begin
            @(posedge aclk)
            if(axi.bvalid)
                break;
        end
        wresp       = axi.bresp;
        axi.rready  <= 0;

        if(wresp != 'b000)
            $display("BRESP isnt equal 0! BRESP = %x", wresp);

        $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
        end
    endtask

endmodule

module frame_gen (
    output logic  [15:0]  tx_data,
    output logic  [2 :0]  is_k,

    input  logic          tx_clk,
    input  logic          ready 
); 

    localparam   WORDS_IN_BRAM = 32;
    logic [$clog2(WORDS_IN_BRAM*2) - 1:0] i = 0;

    logic [7:0] bram [0:WORDS_IN_BRAM-1] = 
    '{ 
        8'h5C, // start
        8'hFF, // addr = 4 segment
        8'h00, 8'h08, 8'h00, 8'h00, // 0-3 byte data 
        8'h00, 8'h00, 8'h00, 8'h07, // 4-7 byte data
        8'h00, 8'h00, 8'h00, 8'h00, // 8-11 byte data
        8'h00, 8'h00, 8'h00, 8'h07, // 12-15 byte data
        8'h3C, // stop
        8'hFE, 8'hEA, // checksum
        8'h00, 8'h00,
        8'h00, 8'h00,
        8'h00, 8'h00,
        8'h00, 8'h00,
        8'h00, 8'h00, 
        8'h00
    };
    
    logic [7:0] MSB, LSB;
    logic isk_msb, isk_lsb;

    assign tx_data = {LSB, MSB};    
    assign is_k    = {isk_lsb, isk_msb};
    assign isk_msb = (MSB == 8'h5C) || (MSB == 8'h3C); 
    assign isk_lsb = LSB == 8'hBC;

    always_comb begin : Event
        LSB = '0;
        if(!ready)
            LSB = '0;
        else if(i % 4 == 0)
            LSB = 8'hBC; // K28.5
        `ifndef SYNTHESIS
        else if(i % 7 == 0)
            LSB = 8'h7E; // beacon
        else if(i % 29 == 0)
            LSB = 8'h15; // test event
        `endif //SYNTHESIS
        else
            LSB = '0;
    end

    always_comb begin : Data
        MSB = 0;
        `ifndef SYNTHESIS
        if(!ready)
            MSB = 0;
        else if(i % 2 == 0)
            MSB = '0; // distributed bus
        else
            MSB = bram[i / 2]; // segmented data buffer
        `endif //SYNTHESIS
    end

    always_ff @( posedge tx_clk ) begin 
        if(!ready) 
        begin
            i <= 0;
        end
        else
        begin
            i <= i+1;
        end

    end

endmodule

`endif//__SCC_SV__