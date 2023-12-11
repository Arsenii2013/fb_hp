`timescale 1ns/1ns
`include "top.svh"

module topTB(

    );    

    logic             REFCLK_PCIE;
    logic             REFCLK_SFP;
    logic             reset_n;
    logic             reset;

    `ifdef MGT_FULL_STACK
    logic loop = 1'b1;
    logic sfp_loss = 1'b0;
    logic tx_p;
    logic tx_n;
    logic rx_p;
    logic rx_n;

    assign rx_p = tx_p ? loop : 1'b0;
    assign rx_n = tx_n ? loop : 1'b0;
    `endif //MGT_FULL_STACK
    
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

    logic             sck;
    logic             cs_n;
    logic [SPI_W-1:0] mosi;
    logic [SPI_W-1:0] miso;
        
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
        .REFCLK_PCIE_p(REFCLK_PCIE),
        .REFCLK_PCIE_n(~REFCLK_PCIE),
        .PERST_PCIE(reset_n),

        `ifdef MGT_FULL_STACK
        .REFCLK_SFP_n(~REFCLK_SFP),
        .REFCLK_SFP_p(REFCLK_SFP),
        .sfp_rx_n(rx_n),
        .sfp_rx_p(rx_p),
        .sfp_tx_n(tx_n),
        .sfp_tx_p(tx_p),
        .sfp_tx_dis(),
        .sfp_loss(sfp_loss),
        `endif //MGT_FULL_STACK

        .SCK(sck),
        .CSn(cs_n),
        .MISO(miso),
        .MOSI(mosi)
    );
    
    `ifdef PCIE_PIPE_STACK
    //defparam topTB.RP.rport.EXT_PIPE_SIM = "TRUE";
    xilinx_pcie_2_1_rport_7x
    #(
        .REF_CLK_FREQ                   ( 0                          ), // 0 = 100 MHZ, 1 = 125 MHZ, 2 = 250 MHZ
        .PL_FAST_TRAIN                  ( "TRUE"                     ),
        .ALLOW_X8_GEN2                  ( "TRUE"                     ),
        .C_DATA_WIDTH                   ( 128                        ),
        .LINK_CAP_MAX_LINK_WIDTH        ( 6'h8                       ),
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
        .USER_CLK_FREQ                  ( 4                          ),
        .USER_CLK2_DIV2                 ( "TRUE"                     )
    ) RP (
        .sys_clk(REFCLK_PCIE),
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
    `endif //PCIE_PIPE_STACK


    localparam SPI_AVMM_AW  = 10;
    localparam SPI_AVMM_DW  = 32;
    localparam MAX_BURST    = 1;
    localparam SPI_W        = 4;

    logic             spi_slave_clk;

    avmm_if #(
        .AW        ( SPI_AVMM_AW ),
        .DW        ( SPI_AVMM_DW ),
        .MAX_BURST ( MAX_BURST   )
    ) s_i();

    hs_spi_slave_avmm_m
    #(
        .AW        ( 10 ),
        .DW        ( 32 ),
        .SPI_W     ( 4  ),
        .MAX_BURST ( 1  )
    )
    spi_slave
    (
        .clkout    ( clkout      ),
        .rst       ( reset       ),
        .bus       ( s_i         ),
        .SCK       ( sck         ),
        .CSn       ( cs_n        ),
        .MISO      ( miso        ),
        .MOSI      ( mosi        )
    );

    avmm_slave_stub #(
        .AW        ( SPI_AVMM_AW ),
        .DW        ( SPI_AVMM_DW ),
        .MAX_BURST ( MAX_BURST   )
    )
    avmm_slave
    (
        .clk       ( clkout      ),
        .rst       ( reset       ),
        .bus       ( s_i         )
    );
        
    sys_clk_gen
    #(
        .halfcycle (5000), // 5000 ps = 100 MHz
        .offset    (0)
    ) CLK_GEN (
        .sys_clk (REFCLK_PCIE)
    );

    sys_clk_gen
    #(
        .halfcycle (4000), // 4000 ps = 125 MHz
        .offset    (0)
    ) REFCLK_SFP_GEN (
        .sys_clk (REFCLK_SFP)
    );
    
    integer i;
    initial begin
        $display("[%t] : System Reset Asserted...", $realtime);
        
        reset_n = 1'b0;
        reset = 1'b1;
        
        for (i = 0; i < 500; i = i + 1) begin
        
        @(posedge REFCLK_PCIE);
        
        end
        
        $display("[%t] : System Reset De-asserted...", $realtime);
        
        reset_n = 1'b1;
        reset = 1'b0;
    end
    
    
    
    initial 
    begin   
        @(posedge DUT.gtpwizard_i.rx_reset_done) 
        # 10000;
        loop = 'b0;
        sfp_loss = 1'b1;
        # 10005;
        loop = 'b1;
        sfp_loss = 1'b0;
        //DUT.gtpwizard_i.test <= 'b1;
        @(posedge DUT.gtpwizard_i.rx_reset_done) 
        # 10000;
        $finish;
    end
    
endmodule
