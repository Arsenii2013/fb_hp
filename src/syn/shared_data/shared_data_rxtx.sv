`ifndef __SHARED_DATA_RXTX_SV__
`define __SHARED_DATA_RXTX_SV__

`include "top.svh"
`include "axi4_lite_if.svh"

module stream_decoder_m 
( 
    input  logic               clk,
    input  logic               rst,

    input  logic [7:0]         rx_data_in,
    input  logic               rx_isk_in,

    axi4_lite_if.m             shared_data_out_i[SHARED_MEM_COUNT]
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Parameters
//
localparam DATA_WORD_SZ = FB_DW / 8;
localparam CHKSUM_SZ    = 2;
localparam MAX_SZ       = DATA_WORD_SZ > CHKSUM_SZ ? DATA_WORD_SZ : CHKSUM_SZ;
localparam BYTES_CNT_W  = $clog2(MAX_SZ);

localparam BUF_SIZE     = SHARED_MEM_SEG_SIZE / DATA_WORD_SZ;
localparam BCW          = $clog2(BUF_SIZE);

localparam logic [7:0] DATA_TRANSFER_START = 8'h5C;
localparam logic [7:0] DATA_TRANSFER_STOP  = 8'h3C;

//------------------------------------------------
//
//      Types
//
typedef logic [    SHARED_MEM_AW-1:0] addr_t;
typedef logic [SHARED_MEM_SEG_AW-1:0] seg_addr_t;
typedef logic [                BCW:0] count_t;
typedef logic [              BCW-1:0] cnt_t;

typedef logic [DATA_WORD_SZ-1:0][7:0] data_t;
typedef logic [   CHKSUM_SZ-1:0][7:0] chksum_t;
typedef logic [      BYTES_CNT_W-1:0] bytes_cnt_t;


//------------------------------------------------
typedef enum {
    rxfsmIDLE,
    rxfsmRECV_ADDR,
    rxfsmRECV_DATA,
    rxfsmRECV_CHKSUM,
    rxfsmCHECK
} rxfsm_state_t;


//------------------------------------------------
//
//      Objects
//
seg_addr_t    rx_addr;
data_t        rx_data[BUF_SIZE];
count_t       rx_count;

chksum_t      chksum;
chksum_t      chksum_recv;

count_t       word_cnt;
bytes_cnt_t   byte_cnt;

logic         rx_valid;
logic         start;
logic         stop;
rxfsm_state_t rxfsm_state = rxfsmIDLE, rxfsm_next;

//------------------------------------------------
seg_addr_t    addr;
data_t        data[BUF_SIZE];
count_t       count;

logic         data_received;
//------------------------------------------------
//
//      Logic
//
assign start = rx_isk_in && rx_data_in == DATA_TRANSFER_START;
assign stop  = rx_isk_in && rx_data_in == DATA_TRANSFER_STOP;

always_ff @(posedge clk) begin
    if (rst) begin
        rxfsm_state <= rxfsmIDLE;
    end
    else begin
        rx_valid <= ~rx_valid;
        rxfsm_state <= rxfsm_next;
        case (rxfsm_state)
            rxfsmIDLE: begin
                chksum        <= '1;
                word_cnt      <= 0;
                byte_cnt      <= 0;
                rx_valid      <= 0;
            end
            rxfsmRECV_ADDR: begin
                if (rx_valid) begin
                    rx_addr <= rx_data_in;
                    chksum  <= chksum - rx_data_in;
                end
            end
            rxfsmRECV_DATA: begin
                if (!stop) begin
                    if (rx_valid) begin
                        rx_data[word_cnt][byte_cnt] <= rx_data_in;
                        chksum   <= chksum - rx_data_in;
                        byte_cnt <= byte_cnt + 1;
                        if (byte_cnt == DATA_WORD_SZ - 1) begin
                            byte_cnt <= 0;
                            word_cnt <= word_cnt + 1;
                        end
                    end
                end
                else begin
                    byte_cnt <= 0;
                    rx_count <= byte_cnt != 0 ? word_cnt + 1 : word_cnt;
                end
            end
            rxfsmRECV_CHKSUM: begin
                if (rx_valid) begin
                    chksum_recv[CHKSUM_SZ-1-byte_cnt] <= rx_data_in;
                    byte_cnt <= byte_cnt + 1;
                end
            end
            rxfsmCHECK: begin
                if (chksum == chksum_recv && rx_count != 0 && rx_addr != 8'hFF) begin
                    addr  <= rx_addr;
                    data  <= rx_data;
                    count <= rx_count;
                end
            end
        endcase
    end
end

always_comb begin
    if (rst) begin
        rxfsm_next = rxfsmIDLE;
    end
    else begin
        case (rxfsm_state)
            rxfsmIDLE:        rxfsm_next = start    ? rxfsmRECV_ADDR   : rxfsmIDLE;
            rxfsmRECV_ADDR:   rxfsm_next = rx_valid ? rxfsmRECV_DATA   : rxfsmRECV_ADDR;
            rxfsmRECV_DATA:   rxfsm_next = stop     ? rxfsmRECV_CHKSUM : rxfsmRECV_DATA;
            rxfsmRECV_CHKSUM: rxfsm_next = rx_valid && byte_cnt == CHKSUM_SZ-1 ? rxfsmCHECK : rxfsmRECV_CHKSUM;
            rxfsmCHECK:       rxfsm_next = rxfsmIDLE;
        endcase        
    end
end

//------------------------------------------------

typedef enum {
    sdfsmIDLE,
    sdfsmWRITE_SLAVE,
    sdfsmWAIT_SLAVE
} sdfsm_state_t;


logic         AW_handsnake[SHARED_MEM_COUNT];
logic         W_handsnake[SHARED_MEM_COUNT];
logic         B_handsnake[SHARED_MEM_COUNT];
cnt_t         cnt[SHARED_MEM_COUNT];
sdfsm_state_t sdfsm_state[SHARED_MEM_COUNT] = '{default: sdfsmIDLE};


assign data_received = rxfsm_state == rxfsmCHECK && chksum == chksum_recv && rx_count != 0 && rx_addr != 8'hFF;

genvar i;
generate
    for (i=0; i<SHARED_MEM_COUNT; i=i+1) begin : shared_data_axi_master
        assign shared_data_out_i[i].araddr  = 'b0;
        assign shared_data_out_i[i].arprot  = 'b1;
        assign shared_data_out_i[i].arvalid = 'b0;
        //assign shared_data_out_i[i].rvalid  = 'b0;
        assign shared_data_out_i[i].rready  = 'b0;
        assign shared_data_out_i[i].awprot  = 'b0;
        assign shared_data_out_i[i].wstrb   = '1;

        assign shared_data_out_i[i].awaddr  = (addr * SHARED_MEM_SEG_SIZE) | (addr_t'(cnt[i]) * DATA_WORD_SZ);
        assign shared_data_out_i[i].wdata   = data[cnt[i]];

        assign shared_data_out_i[i].awvalid = sdfsm_state[i] == sdfsmWRITE_SLAVE;
        assign shared_data_out_i[i].wvalid  = sdfsm_state[i] == sdfsmWRITE_SLAVE;
        assign shared_data_out_i[i].bready  = (sdfsm_state[i] == sdfsmWRITE_SLAVE) || (sdfsm_state[i] == sdfsmWAIT_SLAVE);

        assign AW_handsnake[i]              =  shared_data_out_i[i].awvalid && shared_data_out_i[i].awready;
        assign W_handsnake[i]               =  shared_data_out_i[i].wvalid  && shared_data_out_i[i].wready;
        assign B_handsnake[i]               =  shared_data_out_i[i].bvalid  && shared_data_out_i[i].bready;

        always_ff @(posedge clk) begin
            if (rst) begin
                sdfsm_state[i] <= sdfsmIDLE; 
            end
            else begin
                case (sdfsm_state[i])
                    sdfsmIDLE: begin
                        cnt[i] <= 0;
                        if (data_received)
                            sdfsm_state[i] <= sdfsmWRITE_SLAVE;
                    end
                    sdfsmWRITE_SLAVE: begin
                        if (AW_handsnake[i] && W_handsnake[i]) begin
                            sdfsm_state[i] <= sdfsmWAIT_SLAVE;
                        end
                    end
                    sdfsmWAIT_SLAVE: begin
                        if (B_handsnake[i]) begin
                            cnt[i] <= cnt[i] + 1;
                            if (count_t'(cnt[i]) == count - 1)
                                sdfsm_state[i] <= sdfsmIDLE;
                            else
                                sdfsm_state[i] <= sdfsmWRITE_SLAVE;
                        end
                    end
                endcase
            end
        end
    end
endgenerate

//------------------------------------------------
endmodule : stream_decoder_m

`endif//__STREAM_DATA_RXTX_SV__


/*
always_ff @(posedge clk) begin
            if (rst) begin
                AW_handsnake[i] <= 0;
                W_handsnake[i]  <= 0;
                B_handsnake[i]  <= 0;
            end
            else begin
                case (sdfsm_state[i])
                    sdfsmIDLE: begin
                        AW_handsnake[i] <= 0;
                        W_handsnake[i]  <= 0;
                        B_handsnake[i]  <= 0;
                    end
                    sdfsmWRITE_SLAVE: begin
                        B_handsnake[i]  <= 0;
                        if()
                    end
                    sdfsmWAIT_SLAVE: begin
                        AW_handsnake[i] <= 0;
                        W_handsnake[i]  <= 0;
                    end
                endcase
            end
        end



module stream_generator_m;
( 
    input  logic               clk,
    input  logic               rst,

    axi4_lite.s                shared_data_in_i,

    input  logic               tx_clk,
    input  logic               tx_rst,

    input  logic               data_tx_ena,
    output xcvr_tx_data_word_t tx_data_out
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Parameters
//
localparam DATA_WORD_SZ = FB_DW / 8;
localparam CHKSUM_SZ    = 2;
localparam MAX_SZ       = DATA_WORD_SZ > CHKSUM_SZ ? DATA_WORD_SZ : CHKSUM_SZ;
localparam BYTES_CNT_W  = $clog2(MAX_SZ);

localparam BUF_SIZE     = SHARED_MEM_SEG_SIZE / DATA_WORD_SZ;
localparam BCW          = $clog2(MAX_BURST);

//------------------------------------------------
//
//      Types
//
typedef logic [    SHARED_MEM_AW-1:0] addr_t;
typedef logic [SHARED_MEM_SEG_AW-1:0] seg_addr_t;
typedef logic [                BCW:0] count_t;

typedef logic [DATA_WORD_SZ-1:0][7:0] data_t;
typedef logic [   CHKSUM_SZ-1:0][7:0] chksum_t;
typedef logic [      BYTES_CNT_W-1:0] bytes_cnt_t;

//------------------------------------------------
typedef enum {
    sdfsmIDLE,
    sdfsmSTORE_DATA,
    sdfsmWAIT_DATA_SEND
} sdfsm_state_t;

typedef enum {
    txfsmIDLE,
    txfsmSEND_START,
    txfsmSEND_ADDR,
    txfsmSEND_DATA,
    txfsmSEND_STOP,
    txfsmSEND_CHKSUM
} txfsm_state_t;

//------------------------------------------------
//
//      Objects
//
seg_addr_t    addr;
data_t        data[BUF_SIZE];
count_t       count;

count_t       cnt;

logic         send;
sdfsm_state_t sdfsm_state = sdfsmIDLE, sdfsm_next;

//------------------------------------------------
seg_addr_t    tx_addr;
data_t        tx_data[BUF_SIZE];
count_t       tx_count;

chksum_t      chksum;

count_t       word_cnt;
bytes_cnt_t   byte_cnt;

logic         start;
txfsm_state_t txfsm_state = txfsmIDLE, txfsm_next;

//------------------------------------------------
//
//      Logic
//
assign shared_data_in_i.arready       = 'b1;
assign shared_data_in_i.rdata         = 'hdead;
assign shared_data_in_i.rresp         = 'b0;
assign shared_data_in_i.rvalid        = 'b1;


assign shared_data_in_i.waitrequest   = ~(sdfsm_state == sdfsmSTORE_DATA && shared_data_in_i.write);

always_ff @(posedge clk) begin
    if (rst) begin
        sdfsm_state <= sdfsmIDLE;
    end
    else begin
        sdfsm_state <= sdfsm_next;
        case (sdfsm_state)
            sdfsmIDLE: begin
                if (shared_data_in_i.write) begin
                    addr  <= shared_data_in_i.address / SHARED_MEM_SEG_SIZE;
                    count <= shared_data_in_i.burstcount;
                    cnt   <= 0;
                    if (shared_data_in_i.burstcount > MAX_BURST) begin
                        $display("stream_generator> invalid burstcount");
                        $stop();
                    end
                end
            end
            sdfsmSTORE_DATA: begin
                if (shared_data_in_i.write) begin
                    data[cnt] <= shared_data_in_i.writedata;
                    cnt <= cnt + 1;
                end
            end
        endcase
    end
end

always_comb begin
    if (rst) begin
        sdfsm_next = sdfsmIDLE;
    end
    else begin
        case (sdfsm_state)
            sdfsmIDLE:           sdfsm_next = shared_data_in_i.write ? sdfsmSTORE_DATA : sdfsmIDLE;
            sdfsmSTORE_DATA:     sdfsm_next = cnt == count - 1 && shared_data_in_i.write ? sdfsmWAIT_DATA_SEND : sdfsmSTORE_DATA;
            sdfsmWAIT_DATA_SEND: sdfsm_next = send ? sdfsmIDLE : sdfsmWAIT_DATA_SEND;
        endcase
    end
end

//------------------------------------------------
always_ff @(posedge tx_clk) begin
    if (tx_rst) begin
        txfsm_state <= txfsmIDLE;    
    end
    else begin
    txfsm_state <= txfsm_next;
        case(txfsm_state)
            txfsmIDLE: begin
                if (start) begin
                    tx_addr  <= addr;
                    tx_count <= count;
                    word_cnt <= 0;
                    byte_cnt <= 0;
                    chksum   <= '1;
                    for (int i=0; i<MAX_BURST; i=i+1) begin
                        tx_data[i] <= data[i];
                    end
                end
            end
            txfsmSEND_ADDR: begin
                if (data_tx_ena) chksum <= chksum - tx_addr;
            end
            txfsmSEND_DATA: begin
                if (data_tx_ena) begin
                    chksum <= chksum - tx_data[word_cnt][byte_cnt];
                    byte_cnt <= byte_cnt + 1;
                    if (byte_cnt == DATA_WORD_SZ - 1) begin
                        byte_cnt <= 0;
                        word_cnt <= word_cnt + 1;
                    end
                end
            end
            txfsmSEND_CHKSUM: begin
                if (data_tx_ena) begin
                    byte_cnt <= byte_cnt + 1;
                end
            end
        endcase
    end
end

always_comb begin
    if (tx_rst) begin
        txfsm_next = txfsmIDLE;
    end
    else begin
        case(txfsm_state)
            txfsmIDLE:        txfsm_next = start       ? txfsmSEND_START : txfsmIDLE;
            txfsmSEND_START:  txfsm_next = data_tx_ena ? txfsmSEND_ADDR  : txfsmSEND_START;
            txfsmSEND_ADDR:   txfsm_next = data_tx_ena ? txfsmSEND_DATA  : txfsmSEND_ADDR;
            txfsmSEND_DATA:   txfsm_next = data_tx_ena && byte_cnt == DATA_WORD_SZ-1 && word_cnt == tx_count-1 ? txfsmSEND_STOP : txfsmSEND_DATA;
            txfsmSEND_STOP:   txfsm_next = data_tx_ena ? txfsmSEND_CHKSUM : txfsmSEND_STOP;
            txfsmSEND_CHKSUM: txfsm_next = data_tx_ena && byte_cnt == CHKSUM_SZ-1 ? txfsmIDLE : txfsmSEND_CHKSUM;
        endcase
    end
end

//------------------------------------------------
always_comb begin
    tx_data_out.disp       = 0;
    tx_data_out.force_disp = 0;
    tx_data_out.iskey      = 0;
    tx_data_out.data       = 0;
    if (data_tx_ena) begin
        case(txfsm_state)
            txfsmIDLE:        begin tx_data_out.iskey = 0; tx_data_out.data = 0;                           end
            txfsmSEND_START:  begin tx_data_out.iskey = 1; tx_data_out.data = DATA_TRANSFER_START;         end
            txfsmSEND_ADDR:   begin tx_data_out.iskey = 0; tx_data_out.data = tx_addr;                     end
            txfsmSEND_DATA:   begin tx_data_out.iskey = 0; tx_data_out.data = tx_data[word_cnt][byte_cnt]; end
            txfsmSEND_STOP:   begin tx_data_out.iskey = 1; tx_data_out.data = DATA_TRANSFER_STOP;          end
            txfsmSEND_CHKSUM: begin tx_data_out.iskey = 0; tx_data_out.data = chksum[1-byte_cnt];          end
        endcase
    end
end

//------------------------------------------------
//
//      Instances
//
sync_single_pf_m start_syncronizer (.iclk(clk),    .in(sdfsm_state == sdfsmWAIT_DATA_SEND), .oclk(tx_clk), .out(start)   );
sync_single_pf_m send_syncronizer  (.iclk(tx_clk), .in(txfsm_state == txfsmIDLE),           .oclk(clk),    .out(send)    );

//------------------------------------------------
endmodule : stream_generator_m*/