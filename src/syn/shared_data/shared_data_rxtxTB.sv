`include "top.svh"
`include "axi4_lite_if.svh"

module shared_data_rxtx_tb;
//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Parameters
//
localparam CLK_PRD    = 10ns;
localparam TX_CLK_PRD = 10.001ns;

localparam BUF_SIZE  = SHARED_MEM_SEG_SIZE / (FB_DW / 8);

//------------------------------------------------
//
//      Objects
//
logic               clk = 0;
logic               rst = 1;

logic               tx_clk = 0;
logic               tx_rst = 1;

logic               data_tx_ena = 0;
logic               data_tx_req;
logic               is_k;
logic               tx_enable;

//xcvr_tx_data_word_t tx_data_out;
//xcvr_rx_data_word_t rx_data_in;
logic [7:0]         rx_data_in;

//------------------------------------------------
axi4_lite_if #(
    .AW        ( SHARED_MEM_AW ),
    .DW        ( FB_DW       )
)
shared_data_in_i();

axi4_lite_if #(
    .AW        ( SHARED_MEM_AW ),
    .DW        ( FB_DW       )
)
shared_data_out_i[DDSC_COUNT]();

//------------------------------------------------
//
//      Tasks
//
task automatic send(input logic [FB_DW-1:0] data[BUF_SIZE], input int n);
/*    
    automatic int i = 0;

    @(posedge clk) begin
        shared_data_in_i.write      <= 1;
        shared_data_in_i.address    <= 11'd1024;
        shared_data_in_i.burstcount <= n;
        shared_data_in_i.writedata  <= data[0];
    end

    while(i<n) begin
        wait(shared_data_in_i.waitrequest == 0);
        i++;
        @(posedge clk)
        shared_data_in_i.writedata <= data[i];
    end
    
    shared_data_in_i.write <= 0;
*/
endtask

task automatic recv();


    wait(shared_data_out_i[0].awvalid && shared_data_out_i[0].wvalid);
    @(posedge tx_clk)
    $display("received 0x%x", shared_data_out_i[0].wdata);
    shared_data_out_i[0].awready <= 1;
    shared_data_out_i[0].wready  <= 1;
    @(posedge tx_clk)
    shared_data_out_i[0].awready <= 0;
    shared_data_out_i[0].wready  <= 0;
    wait(shared_data_out_i[0].bready);
    @(posedge tx_clk)
    shared_data_out_i[0].bvalid <= 1;
    @(posedge tx_clk)
    shared_data_out_i[0].bvalid <= 0;
    

endtask


//------------------------------------------------
//
//      Logic
//
always #(CLK_PRD/2)      clk    = ~clk;
always #(TX_CLK_PRD/2)   tx_clk = ~tx_clk;

always @(posedge tx_clk) data_tx_ena <= ~data_tx_ena;

initial begin

    logic [FB_DW-1:0] data[BUF_SIZE];
    
    #100ns
    rst    = 0;
    tx_rst = 0;
    tx_enable = 1;

    #100ns
    data[0] = 32'hDEAD_BEEF;
    data[1] = 32'h5555_AAAA;
    data[2] = 32'h1111_2222;
    data[3] = 32'h3333_4444;
    send(data, 4);
end

initial begin

    recv();
    #100ns
    $stop();
end

//------------------------------------------------
//
//      Instances
//
//assign rx_data_in.data  = tx_data_out.data;
//assign rx_data_in.iskey = tx_data_out.iskey;
//------------------------------------------------
mem_wrapper
mem_i (
    .aclk(clk),
    .aresetn(!rst),
    .axi(shared_data_out_i[1]),
    .offset(0)
);

traffic_generator traffic_generator_i
( 
    .clk               ( clk               ),
    .rst               ( rst               ),

    .tx_data           ( rx_data_in        ),
    .is_k              ( is_k              ),
    .en                ( tx_enable         )

);
//------------------------------------------------
stream_decoder_m stream_decoder
( 
    .clk               ( tx_clk            ),
    .rst               ( tx_rst            ),

    .shared_data_out_i ( shared_data_out_i ),

    .rx_data_in        ( rx_data_in        ),
    .rx_isk_in         ( is_k              )
);
endmodule : shared_data_rxtx_tb

module traffic_generator(
    input  logic               clk,
    input  logic               rst,
    input  logic               en,

    output logic [7:0]         tx_data,
    output logic               is_k
);
    localparam   WORDS_IN_BRAM = 32;
    //                                           D24.2D20.2                 D0.2D20.1                D3.1D7.5                   K28.5K28.5
    //logic [19:0] bram [0:WORDS_IN_BRAM-1] = '{20'b11001101010010110101, 20'b10011101010010111001, 20'b11000110011110001010, 20'b00111110100011111010,
    //                                          20'b11001101010010110101, 20'b10011101010010111001, 20'b11000110011110001010, 20'b00111110100011111010};

    //                                           D24.2D20.2               D0.2D20.1           D3.1D7.5              K28.5K28.5
    logic [15:0] bram [0:WORDS_IN_BRAM*2-1] = '{ 8'h00, 8'h5C, 8'h00,
                                              8'h04, 8'h00,
                                              8'hAD, 8'h00, 8'h74, 8'h00, 8'hAD, 8'h00, 8'h74, 8'h00,
                                              8'h7A, 8'h00, 8'h34, 8'h00, 8'h74, 8'h00, 8'hAD, 8'h00,
                                              8'hAD, 8'h00, 8'h74, 8'h00, 8'hAD, 8'h00, 8'h74, 8'h00,
                                              8'h7A, 8'h00, 8'h34, 8'h00, 8'h74, 8'h00, 8'hAD, 8'h00,
                                              8'h3C, 8'h00,
                                              8'hF7, 8'h00, 8'hd9, 8'h00,
                                              8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
                                              8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
                                              8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};

    logic [$clog2(WORDS_IN_BRAM*2) - 1:0] i = 0;

    assign is_k = (tx_data == 8'h5C || tx_data == 8'hBC || tx_data == 8'h3C) ? 'b1 : 'b0;

    always_ff @( posedge clk ) begin 
        if(rst) 
        begin
            tx_data <= 0;
            i <= 0;
        end
        else
        begin
            if(en) begin 
                tx_data <= bram[i];
                i <= i+1;
            end
        end

    end

endmodule