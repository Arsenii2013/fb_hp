`timescale 1ns/1ns

module gtp_model #(
    parameter rx_reset_delay = 50000  
)
(  
    input  logic       refclk,
    input  logic       sysclk,
    input  logic       soft_reset,
    output logic       tx_reset_done,
    output logic       rx_reset_done,
    output logic       tx_clk,
    output logic       rx_clk,

    output logic [15:0] rx_data,
    input  logic [15:0] tx_data,
    input  logic [1:0]  txcharisk,
    output logic [1:0]  rxcharisk
);
    logic [15:0] rx_current;
    logic [1:0]  rxisk_current;

    logic        tx_clk_bmux;
    logic        rx_clk_bmux;

    assign  tx_clk = tx_clk_bmux && tx_reset_done;
    assign  rx_clk = rx_clk_bmux && rx_reset_done;

    int i;

    always_ff @(posedge sysclk) begin
        if(soft_reset) begin
            tx_reset_done <= 0;
            rx_reset_done <= 0;
            i <= 0;
        end
        else begin
            if(i == 10)
                tx_reset_done <= 1;
            if(i == rx_reset_delay)
                rx_reset_done <= 1;
            i <= i+1;
        end
    end

    always_ff @(posedge rx_clk) begin
        rx_data       <= rx_current;
        rxcharisk     <= rxisk_current;
        rx_current    <= 'b0;
        rxisk_current <= 'b0;
    end

    always_ff @(posedge tx_clk) begin
        //$display("MGT transciever transmit %d is k %d", tx_data, txcharisk);
    end

    sys_clk_gen
    #(
        .halfcycle (5000), // 100 MHz
        .offset    (1234)  // 
    ) TX_GEN (
        .sys_clk (tx_clk_bmux)
    );

    sys_clk_gen
    #(
        .halfcycle (5000), // 100 MHz
        .offset    (3718)  // 
    ) RX_GEN (
        .sys_clk (rx_clk_bmux)
    );


    initial begin
        `include "gtp_tests.svh"
    end

    
task automatic receive(input [15:0] data, input [1:0] is_k);
    begin
    if(rx_current != 'b0)
        $display("MGT transciever failed to recieve %d", rx_current);
    rx_current <= data;
    rxisk_current <= is_k;
    end
endtask

endmodule