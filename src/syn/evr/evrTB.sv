
`timescale 1ns/1ps
`include "top.svh"
`include "axi4_lite_if.svh"

module evrTB();
    logic aligned = 0;
    logic tx_resetdone;
    logic rx_resetdone;

    logic sysclk = 0;
    logic refclk = 0;
    logic tx_clk = 0;
    logic rx_clk = 0;
    logic app_rst;

    logic [15:0] tx_data;
    logic [15:0] rx_data;
    logic [1:0]  rx_charisk;
 
    logic [7:0] ev;
    axi4_lite_if #(.AW(32), .DW(32)) mmr();
    axi4_lite_if #(.AW(32), .DW(32)) tx();
    axi4_lite_if #(.AW(32), .DW(32)) shared_data();

    logic [31:0] read_data;

    initial begin
        sysclk = 0;

        forever #5 sysclk = ~sysclk;
    end
    initial begin
        refclk = 0;
        #1ps;
        forever #5 refclk = ~refclk;
    end
    initial begin
        tx_clk = 0;
        #2ps;
        forever #5 tx_clk = ~tx_clk;
    end
    initial begin
        rx_clk = 0;
        #3ps;
        forever #5 rx_clk = ~rx_clk;
    end
    initial begin
        app_rst = 0;
        @(posedge DUT.mmcm_locked)
        for(int i =0; i < 100; i++) begin
            @(posedge sysclk);
        end 
        app_rst = 1;
        for(int i =0; i < 100; i++) begin
            @(posedge sysclk);
        end 
        app_rst = 0;
        for(int i =0; i < 1000; i++) begin
            @(posedge sysclk);
        end
        @(posedge rx_clk);
        aligned = 1;
    end 

    evr DUT(
        .sysclk(sysclk),
        .refclk(refclk),

        //------GTP signals-------
        .aligned(aligned),

        .tx_resetdone(tx_resetdone),
        .tx_clk(tx_clk),
        .tx_data(tx_data),
        .tx_charisk(tx_charisk),

        .rx_resetdone(rx_resetdone),
        .rx_clk(rx_clk),
        .rx_data(rx_data),
        .rx_charisk(rx_charisk),

        //------Application signals-------
        .app_clk(app_clk),
        .app_rst(app_rst),
        .ev(ev),
        .mmr(mmr),
        .tx(tx),
        .shared_data_out(shared_data)
    );

    mem_wrapper
    mem_i (
        .aclk(app_clk),
        .aresetn(app_rst),
        .axi(shared_data),
        .offset(0)
    );

    frame_gen frame_gen_i(
        .tx_data(rx_data),
        .is_k(rx_charisk),
        .tx_clk(rx_clk),
        .ready(aligned)
    );

    axi_master mmr_master(
        .axi(mmr),
        .aresetn(!app_rst),
        .aclk(app_clk)
    );
    axi_master tx_master(
        .axi(tx),
        .aresetn(!app_rst),
        .aclk(app_clk)
    );

    initial begin
        @(posedge aligned);
        #1000;
        mmr_master.write(32'h04, 32'h01); // DC enable
        //wait(DUT.parser_delay != '0);
        mmr_master.write(32'h18, DUT.parser_delay + 32'h00080500); //  tgt delay = 8 clock cycles + 195 ps
        
        @(posedge app_clk);
         
        tx_master.read(32'h00, read_data); 
        tx_master.write(32'h14, 32'h89ABCDEF); 
        tx_master.write(32'h18, 32'b1001); 
        tx_master.write(32'h14, 32'h76543210); 
        tx_master.write(32'h18, 32'b0101); 
        tx_master.read(32'h00, read_data); 
        tx_master.write(32'h04, 32'b1); 
        tx_master.read(32'h00, read_data); 
        #100;
        tx_master.read(32'h00, read_data); 
        tx_master.write(32'h04, 32'b1); 
    end

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