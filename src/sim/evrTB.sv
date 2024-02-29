
`timescale 1ns/1ns
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
    axi4_lite_if #(.AW(32), .DW(32)) shared_data();

    initial begin
        sysclk = 0;

        forever #5 sysclk = ~sysclk;
    end
    initial begin
        refclk = 0;
        #1;
        forever #5 refclk = ~refclk;
    end
    initial begin
        tx_clk = 0;
        #2;
        forever #5 tx_clk = ~tx_clk;
    end
    initial begin
        rx_clk = 0;
        #3;
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
        8'h00, 8'h8B, 8'hFC, 8'h7B, // 0-3 byte data 
        8'h00, 8'h00, 8'h00, 8'h07, // 4-7 byte data
        8'h00, 8'h00, 8'h00, 8'h00, // 8-11 byte data
        8'h00, 8'h00, 8'h00, 8'h07, // 12-15 byte data
        8'h3C, // stop
        8'hFC, 8'hF0, // checksum
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
