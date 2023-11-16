`timescale 1ns/1ns

module gtpwizardTB(

    );

    logic refclk;
    logic sysclk;
    logic reset;
    logic tx_reset_done;
    logic rx_reset_done;
    logic tx_clk;
    logic rx_clk;
    logic [15:0] rx_data;
    logic [15:0] tx_data;
    logic [2 :0] txcharisk;
    logic [2 :0] rxcharisk;

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
        .soft_reset(reset),
        .rx_reset_done(rx_reset_done),
        .tx_reset_done(tx_reset_done),
        .tx_clk(tx_clk),
        .rx_clk(rx_clk),
        //.reset(reset),

        .rx_data(rx_data),
        .tx_data(tx_data),
        .txcharisk(txcharisk),
        .rxcharisk(rxcharisk),

        .rx_n(rx_n),
        .rx_p(rx_p),
        .tx_n(tx_n),
        .tx_p(tx_p)
    );

    frame_gen frame_gen_i(
        .tx_data(tx_data),
        .tx_clk(tx_clk),
        .is_k(txcharisk),
        .ready(tx_reset_done)
    );

    sys_clk_gen
    #(
        .halfcycle (4000),
        .offset    (0)
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
        @(posedge rx_reset_done);
        #1000000;
        reset = 'b1;
        #10000;
        reset = 'b0;
        @(posedge rx_reset_done);
        #100000;
        $stop();
    end 

endmodule


module frame_gen (
    output logic  [15:0]  tx_data,
    output logic  [2 :0]  is_k,

    input  logic         tx_clk,
    input  logic         ready 
); 

    localparam   WORDS_IN_BRAM = 8;
    //                                           D24.2D20.2                 D0.2D20.1                D3.1D7.5                   K28.5K28.5
    //logic [19:0] bram [0:WORDS_IN_BRAM-1] = '{20'b11001101010010110101, 20'b10011101010010111001, 20'b11000110011110001010, 20'b00111110100011111010,
    //                                          20'b11001101010010110101, 20'b10011101010010111001, 20'b11000110011110001010, 20'b00111110100011111010};

    //                                           D24.2D20.2               D0.2D20.1           D3.1D7.5              K28.5K28.5
    logic [15:0] bram [0:WORDS_IN_BRAM-1] = '{16'b0101100001010100, 16'b0100000000110100, 16'b0010001110100111, 16'b1011110010111100,
                                              16'b0101100001010100, 16'b0100000000110100, 16'b0010001110100111, 16'b1011110010111100};

    logic [$clog2(WORDS_IN_BRAM):0] i = 0;

    assign is_k = (tx_data == 16'b1011110010111100) ? 'b1 : 'b0;

    always_ff @( tx_clk ) begin 
        if(!ready) 
        begin
            tx_data <= 0;
            i <= 0;
        end
        else
        begin
            tx_data <= bram[i[$clog2(WORDS_IN_BRAM):1]];
            i <= i+1;
        end

    end

endmodule;