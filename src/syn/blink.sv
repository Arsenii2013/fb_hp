`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2023 02:09:41 PM
// Design Name: 
// Module Name: blink
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module blink
#(
    parameter FREQ_HZ=100000000,
    parameter LED_PERIOD=1000000000
)
(
    input  logic reset,
    input  logic clk,
    output logic led
);
    localparam CLK_PERIOD = 1000000000/FREQ_HZ;
    localparam COUNT_TO = LED_PERIOD/CLK_PERIOD;
    
    logic [32:0] current=0;
    always_ff @(posedge clk) begin
        if(reset) begin
            current <= 0;
            led <= 0;
        end
        else
            if(current == COUNT_TO) begin
                led <= !led;
                current <= 0;
            end
            else 
                current <= current+1;
    end
endmodule
