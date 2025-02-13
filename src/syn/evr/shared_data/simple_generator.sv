`ifndef __SIMPLE_GENERATOR_SV__
`define __SIMPLE_GENERATOR_SV__

`include "top.svh"
`include "axi4_lite_if.svh"

module simple_generator(
    input  logic       app_clk,
    input  logic       aresetn,

    output logic [7:0] tx_data,
    output logic       tx_is_k,

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
    logic  mrf_start;

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
            mrf_start          <= 0;
        end
        else begin
            mrf_start          <= 0;

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
                    ADDR      : mrf_addr   <= data;
                    DATA      : begin mrf_data <= data; mrf_start <= 1; end
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
        SEND_HEADER0, 
        SEND_HEADER1, 
        SEND_ADDR, 
        SEND_MASTER, 
        SEND_COUNT, 
        SEND_DATA, 
        SEND_END, 
        SEND_CHSUM_MSB, 
        SEND_CHSUM_LSB,
        WAIT
    } generator_state_t;

    logic          clk_even      = 0;
    logic [15:0]   checksum      = '1;
    logic          chsum_ena     = 0;
    logic [1:0]    cnt_cnt       = 0;
    generator_state_t generator_state  = WAIT, generator_next;

    always_ff @(posedge app_clk) begin
        chsum_ena <= (generator_state == SEND_ADDR)  || (generator_state == SEND_MASTER) ||
                     (generator_state == SEND_COUNT) || (generator_state == SEND_DATA);
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn) begin
            clk_even <= 0;
        end else begin
            clk_even <= ~clk_even;
        end
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn) begin
            checksum <= '1;
        end else begin
            if(!clk_even && chsum_ena) begin
                checksum <= checksum - tx_data;
            end else begin
                checksum <= checksum;
            end
        end
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn) begin
            generator_state <= WAIT; 
        end else begin
            if(clk_even)
                generator_state <= generator_next;
        end
    end

    always_ff @(posedge app_clk) begin
        if(!aresetn || generator_state == WAIT) begin
            cnt_cnt       <= '0;
            tx_data <= '0;
            tx_is_k <= 0;
        end else begin
            if(clk_even) begin 
                case (generator_state)
                    WAIT:           begin tx_data <= '0;                        tx_is_k <= 0; end
                    SEND_HEADER0:   begin tx_data <= MRF_TRANSFER_START;        tx_is_k <= 1; end
                    SEND_HEADER1:   begin tx_data <= '0;                        tx_is_k <= 0; end
                    SEND_ADDR:      begin tx_data <= mrf_addr[cnt_cnt * 8+: 8]; cnt_cnt <= cnt_cnt + 1; tx_is_k <= 0; end
                    SEND_MASTER:    begin tx_data <= mrf_master; cnt_cnt <= '0; tx_is_k <= 0; end
                    SEND_COUNT:     begin tx_data <= cnt_cnt == 0 ? 4 : 0; cnt_cnt <= cnt_cnt + 1;      tx_is_k <= 0; end
                    SEND_DATA:      begin tx_data <= mrf_data[cnt_cnt * 8+: 8]; cnt_cnt <= cnt_cnt + 1; tx_is_k <= 0; end
                    SEND_END:       begin tx_data <= MRF_TRANSFER_STOP;         tx_is_k <= 1; end
                    SEND_CHSUM_MSB: begin tx_data <= checksum[15:8];            tx_is_k <= 0; end
                    SEND_CHSUM_LSB: begin tx_data <= checksum[7:0];             tx_is_k <= 0; end
                endcase
            end else begin
                tx_data <= '0;
                tx_is_k <= 0;
            end
        end
    end

    always_comb begin
    if (!aresetn) begin
        generator_next = WAIT;
    end else begin
        case (generator_state)
            WAIT:           generator_next = mrf_start ? SEND_HEADER0 : WAIT;
            SEND_HEADER0:   generator_next = SEND_HEADER1;
            SEND_HEADER1:   generator_next = SEND_ADDR;
            SEND_ADDR:      generator_next = cnt_cnt == 2 ? SEND_MASTER : SEND_ADDR;
            SEND_MASTER:    generator_next = SEND_COUNT;
            SEND_COUNT:     generator_next = cnt_cnt == 3 ? SEND_DATA : SEND_COUNT;
            SEND_DATA:      generator_next = cnt_cnt == 3 ? SEND_END : SEND_DATA;
            SEND_END:       generator_next = SEND_CHSUM_MSB;
            SEND_CHSUM_MSB: generator_next = SEND_CHSUM_LSB;
            SEND_CHSUM_LSB: generator_next = WAIT;
        endcase
    end
end
endmodule

module simple_generatorTB();

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

    simple_generator DUT(
        .app_clk(app_clk),
        .aresetn(!app_rst),
        .tx_data(rx_data),
        .tx_is_k(rx_charisk),
        .mmr(mmr)
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
        mmr_master.write(32'h18, 32'h12345678);
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


`endif//__SIMPLE_GENERATOR_SV__

