`timescale 1ns/1ns

module gtpwizardTB(

    );

    logic refclk;
    logic sysclk;
    logic reset;
    logic reset_done;
    logic tx_clk;
    logic rx_clk;
    logic [7:0] rx_data;
    logic [7:0] tx_data;

    logic rx_n;
    logic rx_p;
    logic tx_n;
    logic tx_p;
    assign rx_n = tx_n;
    assign rx_p = tx_p;

    gtpwizard DUT(
        .refclk_n(!refclk),
        .refclk_p(refclk),
        .sysclk(sysclk),
        .reset_done(reset_done),
        .tx_clk(tx_clk),
        .rx_clk(rx_clk),
        .reset(reset),
        .rx_slide('b0),

        .rx_data(rx_data),
        .tx_data(tx_data),

        .rx_n(rx_n),
        .rx_p(rx_p),
        .tx_n(tx_n),
        .tx_p(tx_p)
    );

    frame_gen frame_gen_i(
        .tx_data(tx_data),
        .tx_clk(tx_clk),
        .reset(!reset_done)
    );

    sys_clk_gen
    #(
        .halfcycle (5000),
        .offset    (1000)
    ) REFCLK_GEN (
        .sys_clk (refclk)
    );

    sys_clk_gen
    #(
        .halfcycle (5000),
        .offset    (0)
    ) SYSCLK_GEN (
        .sys_clk (sysclk)
    );

    initial begin
        reset = 'b1;
        #100;
        reset = 'b0;
        #100000;
        $stop();
    end 

endmodule;


module frame_gen (
    output logic  [7:0]  tx_data,

    input  logic         tx_clk,
    input  logic         reset 
); 

    localparam   WORDS_IN_BRAM = 8;
    //                                           D0          D1           D2            K28.1       D3              D4         D5          K28.1
    logic [7:0] bram [0:WORDS_IN_BRAM-1] = '{8'b00000000, 8'b00000001, 8'b00000010, 8'b00111100, 8'b00000011, 8'b00000100, 8'b00000101, 8'b00111100};
    logic [$clog2(WORDS_IN_BRAM)-1:0] i = 0;

    always_ff @( tx_clk ) begin 
        if(reset)
            tx_data <= 0;
        else
        begin
            tx_data <= bram[i];
            i <= i+1;
        end

    end

endmodule;