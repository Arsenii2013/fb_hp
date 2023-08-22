`timescale 1ns/1ns
`include "system.svh"

module topTB(

    );
    parameter REF_CLK_FREQ               = 1;
    parameter USER_CLK_FREQ_RP           = 4;
    parameter USER_CLK2_DIV2_RP          = "TRUE";
    parameter LINK_CAP_MAX_LINK_WIDTH_RP = 6'h8;
    
    //defparam topTB.RP.rport.EXT_PIPE_SIM = "TRUE";
    
    logic clock;
    logic reset_n;
    
    `ifdef PCIE_PIPE_STACK
    //------------------- EP ------------------------------------
    wire  [11:0]  common_commands_out;
    wire  [24:0]  xil_tx0_sigs_ep;
    wire  [24:0]  xil_tx1_sigs_ep;
    wire  [24:0]  xil_tx2_sigs_ep;
    wire  [24:0]  xil_tx3_sigs_ep;
    wire  [24:0]  xil_tx4_sigs_ep;
    wire  [24:0]  xil_tx5_sigs_ep;
    wire  [24:0]  xil_tx6_sigs_ep;
    wire  [24:0]  xil_tx7_sigs_ep;
    
    wire  [24:0]  xil_rx0_sigs_ep;
    wire  [24:0]  xil_rx1_sigs_ep;
    wire  [24:0]  xil_rx2_sigs_ep;
    wire  [24:0]  xil_rx3_sigs_ep;
    wire  [24:0]  xil_rx4_sigs_ep;
    wire  [24:0]  xil_rx5_sigs_ep;
    wire  [24:0]  xil_rx6_sigs_ep;
    wire  [24:0]  xil_rx7_sigs_ep;
    
    //------------------- RP ----------------------------------
    wire  [24:0]  xil_tx0_sigs_rp;
    wire  [24:0]  xil_tx1_sigs_rp;
    wire  [24:0]  xil_tx2_sigs_rp;
    wire  [24:0]  xil_tx3_sigs_rp;
    wire  [24:0]  xil_tx4_sigs_rp;
    wire  [24:0]  xil_tx5_sigs_rp;
    wire  [24:0]  xil_tx6_sigs_rp;
    wire  [24:0]  xil_tx7_sigs_rp;
    
    
    assign xil_rx0_sigs_ep  = {3'b0,xil_tx0_sigs_rp[22:0]};
    assign xil_rx1_sigs_ep  = {3'b0,xil_tx1_sigs_rp[22:0]};
    assign xil_rx2_sigs_ep  = {3'b0,xil_tx2_sigs_rp[22:0]};
    assign xil_rx3_sigs_ep  = {3'b0,xil_tx3_sigs_rp[22:0]};
    assign xil_rx4_sigs_ep  = {3'b0,xil_tx4_sigs_rp[22:0]};
    assign xil_rx5_sigs_ep  = {3'b0,xil_tx5_sigs_rp[22:0]};
    assign xil_rx6_sigs_ep  = {3'b0,xil_tx6_sigs_rp[22:0]};
    assign xil_rx7_sigs_ep  = {3'b0,xil_tx7_sigs_rp[22:0]}; 
    `endif //PCIE_FULL_STACK
        
    top DUT(
        `ifdef PCIE_PIPE_STACK
        .common_commands_in ( 4'b0  ),
        .pipe_rx_0_sigs     (xil_rx0_sigs_ep),
        .pipe_rx_1_sigs     (xil_rx1_sigs_ep),
        .pipe_rx_2_sigs     (xil_rx2_sigs_ep),
        .pipe_rx_3_sigs     (xil_rx3_sigs_ep),
        .pipe_rx_4_sigs     (xil_rx4_sigs_ep),
        .pipe_rx_5_sigs     (xil_rx5_sigs_ep),
        .pipe_rx_6_sigs     (xil_rx6_sigs_ep),
        .pipe_rx_7_sigs     (xil_rx7_sigs_ep),
        .common_commands_out(common_commands_out),
        .pipe_tx_0_sigs     (xil_tx0_sigs_ep),
        .pipe_tx_1_sigs     (xil_tx1_sigs_ep),
        .pipe_tx_2_sigs     (xil_tx2_sigs_ep),
        .pipe_tx_3_sigs     (xil_tx3_sigs_ep),
        .pipe_tx_4_sigs     (xil_tx4_sigs_ep),
        .pipe_tx_5_sigs     (xil_tx5_sigs_ep),
        .pipe_tx_6_sigs     (xil_tx6_sigs_ep),
        .pipe_tx_7_sigs     (xil_tx7_sigs_ep),
        `endif //PCIE_FULL_STACK
        
        .clock,
        .reset_n
    );
    
    `ifdef PCIE_PIPE_STACK
    xilinx_pcie_2_1_rport_7x
    #(
        .REF_CLK_FREQ                   ( REF_CLK_FREQ               ),
        .PL_FAST_TRAIN                  ( "TRUE"                     ),
        .ALLOW_X8_GEN2                  ( "TRUE"                     ),
        .C_DATA_WIDTH                   ( 128                        ),
        .LINK_CAP_MAX_LINK_WIDTH        ( LINK_CAP_MAX_LINK_WIDTH_RP ),
        .DEVICE_ID                      ( 16'h7100                   ),
        .LINK_CAP_MAX_LINK_SPEED        ( 4'h2                       ),
        .LINK_CTRL2_TARGET_LINK_SPEED   ( 4'h2                       ),
        .DEV_CAP_MAX_PAYLOAD_SUPPORTED  ( 1                          ),
        .TRN_DW                         ( "TRUE"                     ),
        .PCIE_EXT_CLK                   ( "TRUE"                     ),
        .VC0_TX_LASTPACKET              ( 29                         ),
        .VC0_RX_RAM_LIMIT               ( 13'h7FF                    ),
        .VC0_CPL_INFINITE               ( "TRUE"                     ),
        .VC0_TOTAL_CREDITS_PD           ( 437                        ),
        .VC0_TOTAL_CREDITS_CD           ( 461                        ),
        .USER_CLK_FREQ                  ( USER_CLK_FREQ_RP           ),
        .USER_CLK2_DIV2                 ( USER_CLK2_DIV2_RP          )
    ) RP (
        .sys_clk(clock),
        .sys_rst_n(reset_n),
        
        .common_commands_in ({11'b0,common_commands_out[0]} ), // pipe_clk from EP
        .pipe_rx_0_sigs     ({2'b0,xil_tx0_sigs_ep[22:0]}),
        .pipe_rx_1_sigs     ({2'b0,xil_tx1_sigs_ep[22:0]}),
        .pipe_rx_2_sigs     ({2'b0,xil_tx2_sigs_ep[22:0]}),
        .pipe_rx_3_sigs     ({2'b0,xil_tx3_sigs_ep[22:0]}),
        .pipe_rx_4_sigs     ({2'b0,xil_tx4_sigs_ep[22:0]}),
        .pipe_rx_5_sigs     ({2'b0,xil_tx5_sigs_ep[22:0]}),
        .pipe_rx_6_sigs     ({2'b0,xil_tx6_sigs_ep[22:0]}),
        .pipe_rx_7_sigs     ({2'b0,xil_tx7_sigs_ep[22:0]}),
        .common_commands_out(),
        
        .pipe_tx_0_sigs     (xil_tx0_sigs_rp),
        .pipe_tx_1_sigs     (xil_tx1_sigs_rp),
        .pipe_tx_2_sigs     (xil_tx2_sigs_rp),
        .pipe_tx_3_sigs     (xil_tx3_sigs_rp),
        .pipe_tx_4_sigs     (xil_tx4_sigs_rp),
        .pipe_tx_5_sigs     (xil_tx5_sigs_rp),
        .pipe_tx_6_sigs     (xil_tx6_sigs_rp),
        .pipe_tx_7_sigs     (xil_tx7_sigs_rp)
    
    );
    `endif //PCIE_FULL_STACK
    
    sys_clk_gen
    #(
        .halfcycle (4000),
        .offset    (0)
    ) CLK_GEN (
        .sys_clk (clock)
    );
    
    integer i;
    initial begin
        $display("[%t] : System Reset Asserted...", $realtime);
        
        reset_n = 1'b0;
        
        for (i = 0; i < 500; i = i + 1) begin
        
        @(posedge clock);
        
        end
        
        $display("[%t] : System Reset De-asserted...", $realtime);
        
        reset_n = 1'b1;
    end
    
    
    
    initial 
    begin    
        # 1000000;
        $finish;
    end
    
endmodule
