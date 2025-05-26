`ifndef __SIMPLE_PARSER_SV__
`define __SIMPLE_PARSER_SV__

`include "top.svh"
`include "axi4_lite_if.svh"

module simple_parser(
    input  logic       app_clk,
    input  logic       aresetn,

    input  logic [7:0] rx_data,
    input  logic       rx_is_k,

    axi4_lite_if.s     mmr
);
//MMR logic 
    typedef logic [MMR_DEV_ADDR_W-1:0] addr_t;
    typedef logic [    MMR_DATA_W-1:0] data_t;
    typedef logic [              31:0] word_t;

    typedef enum addr_t {
        SR            = addr_t'(8'h00),
        CR            = addr_t'(8'h04),
        CR_S          = addr_t'(8'h08),
        CR_C          = addr_t'(8'h0C),
        MASTER        = addr_t'(8'h10),
        ADDR          = addr_t'(8'h14),
        DATA          = addr_t'(8'h18)
    } tx_regs;

    typedef struct packed {
        logic none;
    } sr_t;

    typedef struct packed {
        logic none;
    } cr_t;

    sr_t sr;
    cr_t cr;
    word_t mrf_master;
    word_t mrf_addr;
    word_t mrf_data;

    logic read;
    logic write_addr;
    logic write_data;
    logic [MMR_DEV_ADDR_W-1:0] addr;
    logic [MMR_DATA_W-1:0] data;

    always_ff @(posedge app_clk) begin
        if (!aresetn) begin
            mmr.arready        <= 0;
            mmr.rvalid         <= 0;
            mmr.awready        <= 0;
            mmr.wready         <= 0;
            mmr.bvalid         <= 0;
            mmr.rresp          <= '0;
            mmr.bresp          <= '0;
            mmr.rdata          <= '0;
            read               <= 0;
            write_addr         <= 0;
            write_data         <= 0;
            mrf_master         <= 0;
            mrf_addr           <= 0;
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
                    SR            : mmr.rdata <= data_t'(sr);
                    CR            : mmr.rdata <= data_t'(cr);
                    MASTER        : mmr.rdata <= mrf_master[7:0];
                    ADDR          : mmr.rdata <= mrf_addr[23:0];
                    DATA          : mmr.rdata <= mrf_data;
                    default       : mmr.rdata <= '0;
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
                    CR        : cr <= cr_t'(data);
                    CR_S      : cr <= cr | cr_t'(data);
                    CR_C      : cr <= cr & ~(cr_t'(data));
                    MASTER    : mrf_master <= data;
                    ADDR      : mrf_addr <= data;
                    default;
                endcase
            end 
            
        end
    end
// MMR logic end

// MRF logic
localparam logic [7:0] MRF_TRANSFER_START = 8'h5C;
localparam logic [7:0] MRF_TRANSFER_STOP  = 8'h3C;

    typedef enum {
        RECV_HEADER0, 
        RECV_HEADER1, 
        RECV_ADDR, 
        RECV_MASTER, 
        RECV_COUNT, 
        RECV_DATA, 
        RECV_END, 
        RECV_CHSUM_MSB, 
        RECV_CHSUM_LSB,
        SUCCESS,
        RESET
    } parser_state_t;

    logic          clk_odd      = 0;
    logic [15:0]   checksum      = '1;
    logic          chsum_ena;
    word_t         mrf_cnt       = 0;
    logic [1:0]    cnt_cnt       = 0;
    word_t         mrf_data_recv;
    word_t         mrf_addr_recv;
    parser_state_t parser_state  = RESET, parser_next;

    assign chsum_ena = (parser_state == RECV_ADDR)  || (parser_state == RECV_MASTER) ||
                       (parser_state == RECV_COUNT) || (parser_state == RECV_DATA);

    always_ff @(posedge app_clk) begin
        if(!aresetn) begin
            clk_odd <= 0;
        end else begin
            if(parser_next == RECV_HEADER0) begin
                clk_odd <= 1;
            end else begin
                clk_odd <= ~clk_odd;
            end
        end
    end

    always_ff @(posedge app_clk) begin
        if(parser_state == RESET) begin
            checksum <= '1;
        end else begin
            if(clk_odd && chsum_ena) begin
                checksum <= checksum - rx_data;
            end else begin
                checksum <= checksum;
            end
        end
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn) begin
            parser_state <= RESET; 
        end else begin
            if(clk_odd) begin
                parser_state <= parser_next;
            end else begin
                parser_state <= parser_state;
            end
        end
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn || parser_state == RESET) begin
            mrf_addr_recv <= '0;
            mrf_cnt       <= '0; 
            cnt_cnt       <= '0;
            mrf_data_recv <= '0;
        end else begin
            if(parser_state == RECV_COUNT && clk_odd) begin
                cnt_cnt       <= cnt_cnt + 1;
                mrf_cnt       <= {rx_data, mrf_cnt[31:8]};
                mrf_addr_recv <= mrf_addr_recv;
            end else if(parser_state == RECV_ADDR && clk_odd) begin
                cnt_cnt       <= cnt_cnt + 1;
                mrf_cnt       <= mrf_cnt;
                mrf_addr_recv <= {rx_data, mrf_addr_recv[23:8]};
            end else if(parser_state == RECV_MASTER && clk_odd) begin
                cnt_cnt       <= '0;
                mrf_addr_recv <= mrf_addr_recv;
                mrf_cnt       <= mrf_cnt;
            end else if(parser_state == RECV_DATA && clk_odd) begin
                if(mrf_addr_recv[31:2] == mrf_addr[31:2]) begin
                    mrf_data_recv <= {rx_data, mrf_data_recv[31:8]};
                end
                mrf_addr_recv <= mrf_addr_recv + 1;
                mrf_cnt       <= mrf_cnt - 1;
            end else begin
                cnt_cnt       <= cnt_cnt;
                mrf_addr_recv <= mrf_addr_recv;
                mrf_cnt       <= mrf_cnt;
            end
        end
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn) begin
            mrf_data <= 'h1b4e81b;
        end else if(parser_state == SUCCESS) begin
            mrf_data <= mrf_data_recv;
        end
    end

    always_comb begin
    if (!aresetn) begin
        parser_next = RECV_HEADER0;
    end else begin
        case (parser_state)
            RESET:         parser_next = RECV_HEADER0;
            RECV_HEADER0:  parser_next = rx_data == MRF_TRANSFER_START && rx_is_k  ? RECV_HEADER1  : RECV_HEADER0;
            RECV_HEADER1:  parser_next = rx_data == 8'h00              && !rx_is_k ? RECV_ADDR     : RESET;
            RECV_ADDR:     parser_next = cnt_cnt == 2                              ? RECV_MASTER   : RECV_ADDR;
            RECV_MASTER:   parser_next = rx_data == mrf_master         && !rx_is_k ? RECV_COUNT    : RESET;
            RECV_COUNT:    parser_next = cnt_cnt == 3                              ? RECV_DATA     : RECV_COUNT;
            RECV_DATA:     parser_next = mrf_cnt == 1                              ? RECV_END      : RECV_DATA;
            RECV_END:      parser_next = rx_data == MRF_TRANSFER_STOP  && rx_is_k  ? RECV_CHSUM_MSB: RESET;
            RECV_CHSUM_MSB:parser_next = rx_data == checksum[15:8]     && !rx_is_k ? RECV_CHSUM_LSB: RESET;
            RECV_CHSUM_LSB:parser_next = rx_data == checksum[7:0]      && !rx_is_k ? SUCCESS: RESET;
            SUCCESS:       parser_next = RESET;
            default:       parser_next = RECV_HEADER0;
        endcase
    end
end
endmodule

module simple_parserTB();

    logic app_clk = 0;
    logic app_rst;

    logic [15:0] rx_data;
    logic [1:0]  rx_charisk;
 
    logic [7:0] ev;
    axi4_lite_if #(.AW(32), .DW(32)) mmr();

    logic [31:0] read_data;

    initial begin
        app_clk = 0;
        forever #5 app_clk = ~app_clk;
    end

    initial begin
        app_rst = 1;
        for(int i =0; i < 10; i++) begin
            @(posedge app_clk);
        end 
        app_rst = 0;
    end 

    simple_parser DUT(
        .app_clk(app_clk),
        .aresetn(!app_rst),
        .rx_data(rx_data),
        .rx_is_k(rx_charisk),
        .mmr(mmr)
    );

    frame_gen frame_gen_i(
        .tx_data(rx_data),
        .is_k(rx_charisk),
        .tx_clk(app_clk),
        .ready(!app_rst)
    );

    axi_master mmr_master(
        .axi(mmr),
        .aresetn(!app_rst),
        .aclk(app_clk)
    );

    initial begin
        #1000;
        mmr_master.write(32'h10, 32'hFB); 
        mmr_master.write(32'h14, 32'hE0);
        #1000;
        mmr_master.read(32'h18, read_data);
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
        $display("Read");
        
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
        $display("Write");
        
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

    input  logic         tx_clk,
    input  logic         ready 
); 

    localparam   WORDS_IN_BRAM = 32;
    logic [$clog2(WORDS_IN_BRAM*2) - 1:0] i = 0;

    logic [7:0] bram [0:WORDS_IN_BRAM-1] = 
    '{ 
        8'h00, 8'h00,
        8'h5C, // start
        8'h00, // 0 segment
        8'hE0, 8'h00, 8'h00, 8'hFB, // master id = FB, addr = 0xE0
        8'h04, 8'h00, 8'h00, 8'h00, // count = 4 byte
        8'h78, 8'h56, 8'h34, 8'h12, // data = 12345678
        8'h3C, // stop
        8'hFD, 8'h0C, // checksum
        8'h00, 8'h00,
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


`endif//__SIMPLE_PARSER_SV__

