`timescale 1ns/1ns

`include "axi4_lite_if.svh"
`include "top.svh"

module top(
    //-------------PCI-E-------------\\
    `ifndef SYNTHESIS
    `ifdef PCIE_PIPE_STACK
    input  logic [11:0] common_commands_in,
    input  logic [24:0] pipe_rx_0_sigs,
    input  logic [24:0] pipe_rx_1_sigs,
    input  logic [24:0] pipe_rx_2_sigs,
    input  logic [24:0] pipe_rx_3_sigs,
    input  logic [24:0] pipe_rx_4_sigs,
    input  logic [24:0] pipe_rx_5_sigs,
    input  logic [24:0] pipe_rx_6_sigs,
    input  logic [24:0] pipe_rx_7_sigs,
    output logic [11:0] common_commands_out,
    output logic [24:0] pipe_tx_0_sigs,
    output logic [24:0] pipe_tx_1_sigs,
    output logic [24:0] pipe_tx_2_sigs,
    output logic [24:0] pipe_tx_3_sigs,
    output logic [24:0] pipe_tx_4_sigs,
    output logic [24:0] pipe_tx_5_sigs,
    output logic [24:0] pipe_tx_6_sigs,
    output logic [24:0] pipe_tx_7_sigs,
    `endif //PCIE_FULL_STACK 
    `endif //SYNTHESIS      
    
    `ifdef SYNTHESIS
    input  logic [PCIE_LANE-1:0]  pcie_7x_mgt_rxn,
    input  logic [PCIE_LANE-1:0]  pcie_7x_mgt_rxp,
    output logic [PCIE_LANE-1:0]  pcie_7x_mgt_txn,
    output logic [PCIE_LANE-1:0]  pcie_7x_mgt_txp,
    `endif //SYNTHESIS 
    
    input  logic        REFCLK_PCIE_n,
    input  logic        REFCLK_PCIE_p,
    input  logic        PERST_PCIE,

    //-------Processing System-------\\
    `ifdef SYNTHESIS
    inout wire [14:0]   DDR_addr,
    inout wire [2:0]    DDR_ba,
    inout wire          DDR_cas_n,
    inout wire          DDR_ck_n,
    inout wire          DDR_ck_p,
    inout wire          DDR_cke,
    inout wire          DDR_cs_n,
    inout wire [3:0]    DDR_dm,
    inout wire [31:0]   DDR_dq,
    inout wire [3:0]    DDR_dqs_n,
    inout wire [3:0]    DDR_dqs_p,
    inout wire          DDR_odt,
    inout wire          DDR_ras_n,
    inout wire          DDR_reset_n,
    inout wire          DDR_we_n,
    inout wire          FIXED_IO_ddr_vrn,
    inout wire          FIXED_IO_ddr_vrp,
    inout wire [53:0]   FIXED_IO_mio,
    inout wire          FIXED_IO_ps_clk,
    inout wire          FIXED_IO_ps_porb,
    inout wire          FIXED_IO_ps_srstb,
    `endif //SYNTHESIS 

    //-------------QSPI--------------\\
    output logic              SCK,
    output logic              CSn,
    input  logic [SPI_W-1:0]  MISO,
    output logic [SPI_W-1:0]  MOSI,

    //-------------SFP---------------\\
    `ifdef MGT_FULL_STACK
    input  logic       REFCLK_SFP_n,
    input  logic       REFCLK_SFP_p,

    input  logic       sfp_rx_n,
    input  logic       sfp_rx_p,
    output logic       sfp_tx_n,
    output logic       sfp_tx_p,
    output logic       sfp_tx_dis,
    input  logic       sfp_loss,
    `endif // MGT_FULL_STACK

    //-------------GPIO--------------\\
    output logic [3:0] led

    //(* IOB = "TRUE" *) output logic [3:0] test_out

    );
    assign sfp_tx_dis = 'b0;

    logic PS_clk;
    logic PS_aresetn;
    logic PS_reset;
    logic app_clk;
    logic app_reset;
    logic app_aresetn;
    logic PS_sync;

    xpm_cdc_async_rst #(
        .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .RST_ACTIVE_HIGH(0)  // DECIMAL; 0=active low reset, 1=active high reset
    )
    xpm_cdc_aresetn_inst (
        .dest_arst(app_aresetn), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                                // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                                // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                                // (DEST_SYNC_FF*dest_clk) period.

        .dest_clk(app_clk),   // 1-bit input: Destination clock.
        .src_arst(PS_aresetn)    // 1-bit input: Source asynchronous reset signal.
    );

    xpm_cdc_async_rst #(
        .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
    )
    xpm_cdc_areset_inst (
        .dest_arst(app_reset), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                                // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                                // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                                // (DEST_SYNC_FF*dest_clk) period.

        .dest_clk(app_clk),   // 1-bit input: Destination clock.
        .src_arst(PS_reset)    // 1-bit input: Source asynchronous reset signal.
    );
    //---------GTP_COMMON------------\\
    logic REFCLK_PCIE;
    logic REFCLK_SFP;

    IBUFDS_GTE2 REFCLK_PCIE_ibuf_i (.O(REFCLK_PCIE), .ODIV2(), .I(REFCLK_PCIE_p), .CEB(1'b0), .IB(REFCLK_PCIE_n));
    IBUFDS_GTE2 REFCLK_SFP_ibuf_i (.O(REFCLK_SFP), .ODIV2(), .I(REFCLK_SFP_p), .CEB(1'b0), .IB(REFCLK_SFP_n));

    logic QPLL0OUTCLK;
    logic QPLL1OUTCLK;
    logic QPLL0OUTREFCLK;
    logic QPLL1OUTREFCLK;

    logic QPLL0PD;
    logic QPLL1PD;
    logic QPLL0RESET;
    logic QPLL1RESET;
    logic QPLL0LOCK;
    logic QPLL1LOCK;
    logic QPLL0REFCLKLOST;
    logic QPLL1REFCLKLOST;

    logic        DRP_CLK;
    logic [15:0] DRP_DO;
    logic        DRP_RDY;
    logic [ 7:0] DRP_ADDR;
    logic        DRP_EN;
    logic [15:0] DRP_DI;   
    logic        DRP_WE;

    gt_common_wrapper gt_common_wrapper_i(
        .REFCLK0(REFCLK_PCIE),
        .REFCLK1(REFCLK_SFP),

        .PLL0LOCKDETCLK(PS_clk),
        .PLL1LOCKDETCLK(PS_clk),
        .PLL0PD(QPLL0PD),
        .PLL1PD(QPLL1PD),
        .PLL0RESET(QPLL0RESET),
        .PLL1RESET(QPLL1RESET),

        .PLL0OUTCLK(QPLL0OUTCLK),
        .PLL1OUTCLK(QPLL1OUTCLK),
        .PLL0OUTREFCLK(QPLL0OUTREFCLK),
        .PLL1OUTREFCLK(QPLL1OUTREFCLK),
        .PLL0LOCK(QPLL0LOCK),
        .PLL1LOCK(QPLL1LOCK),
        .PLL0REFCLKLOST(QPLL0REFCLKLOST),
        .PLL1REFCLKLOST(QPLL1REFCLKLOST)//,

        //.DRP_CLK(DRP_CLK),
        //.DRP_DO(DRP_DO),
        //.DRP_RDY(DRP_RDY),
        //.DRP_ADDR(DRP_ADDR),
        //.DRP_EN(DRP_EN),
        //.DRP_DI(DRP_DI),
        //.DRP_WE(DRP_WE)
    );


    /*ila_0 ila_tx(
        .clk(DRP_CLK),
        .probe0(DRP_DO),
        .probe1(DRP_RDY),
        .probe2(DRP_ADDR),
        .probe3(DRP_EN),
        .probe4(DRP_DI),
        .probe5(DRP_WE),
        .probe6(QPLL0PD),
        .probe7(QPLL1PD),
        .probe8(QPLL0RESET),
        .probe9(QPLL1RESET),
        .probe10(QPLL0LOCK),
        .probe11(QPLL1LOCK),
        .probe12(QPLL0REFCLKLOST),
        .probe13(QPLL1REFCLKLOST)
    );*/


    //-----------Interfaces----------\\
    axi4_lite_if #(.DW(GP0_DATA_W), .AW(GP0_ADDR_W)) GP_CONTROL();
    axi4_lite_if #(.DW(GP0_DATA_W), .AW(GP0_ADDR_W)) GP_DATA();
    axi4_lite_if #(.DW(HP0_DATA_W), .AW(HP0_ADDR_W)) HP0();

    axi4_lite_if #(.DW(BAR0_DATA_W), .AW(FB_DW)) bar0();
    axi4_lite_if #(.DW(BAR1_DATA_W), .AW(BAR1_ADDR_W)) bar1();
    axi4_lite_if #(.DW(BAR2_DATA_W), .AW(BAR2_ADDR_W)) bar2();    
    
    //localparam MMR_DEV_COUNT2 = 2 ** ($clog2(MMR_DEV_COUNT) + 1);
    localparam MMR_DEV_COUNT2 = 64;
    axi4_lite_if #(.AW(MMR_DEV_ADDR_W), .DW(MMR_DATA_W)) mmr[MMR_DEV_COUNT2]();
     
    //-------Processing System-------\\
    logic spi_aclk;
    logic spi_oclk;
    logic spi_aresetn;
    logic [HP0_ADDR_W-1:0] HP0_offset;
    logic [EMIO_SIZE-1:0]  emio_o;
    logic [EMIO_SIZE-1:0]  emio_i;
    logic [EMIO_SIZE-1:0]  emio_t;

    test_fifo test_fifo_i(
        .clk(app_clk),
        .rst(app_reset),
        .clear(emio_o[0]),
        .presc(emio_o[31:1]),
        .axi(mmr[MMR_PSEVENT])
    );

    PS_wrapper_ 
    PS_wrapper_i (
        `ifdef SYNTHESIS
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        `endif // SYNTHESIS

        .GP_CONTROL(GP_CONTROL),
        .GP_DATA(GP_DATA),
        .HP0(bar2),
        .HP0_offset(HP0_offset),

        .EMIO_I(emio_i),
        .EMIO_O(emio_o),
        .EMIO_T(emio_t),
        
        .peripheral_clock(PS_clk),
        .peripheral_aresetn(PS_aresetn),
        .peripheral_reset(PS_reset),
        .app_clk(app_clk),
        .app_aresetn(app_aresetn)
    );

    //-------------PCI-E-------------\\     
    pcie_wrapper_ pcie_i(
        `ifndef SYNTHESIS
        `ifdef PCIE_PIPE_STACK
        .common_commands_in,
        .pipe_rx_0_sigs,
        .pipe_rx_1_sigs,
        .pipe_rx_2_sigs,
        .pipe_rx_3_sigs,
        .pipe_rx_4_sigs,
        .pipe_rx_5_sigs,
        .pipe_rx_6_sigs,
        .pipe_rx_7_sigs,
        .common_commands_out,
        .pipe_tx_0_sigs,
        .pipe_tx_1_sigs,
        .pipe_tx_2_sigs,
        .pipe_tx_3_sigs,
        .pipe_tx_4_sigs,
        .pipe_tx_5_sigs,
        .pipe_tx_6_sigs,
        .pipe_tx_7_sigs,
        `endif //PCIE_FULL_STACK 
        `endif //SYNTHESIS   

        .pcie_qpll_drp_qplld(QPLL0PD),
        .pcie_qpll_drp_qplllock(QPLL0LOCK),
        .pcie_qpll_drp_qplloutclk(QPLL0OUTCLK),
        .pcie_qpll_drp_qplloutrefclk(QPLL0OUTREFCLK),
        .pcie_qpll_drp_qpllreset(QPLL0RESET),

        .DRP_CLK(DRP_CLK),
        .DRP_DO(DRP_DO),
        .DRP_RDY(DRP_RDY),
        .DRP_ADDR(DRP_ADDR),
        .DRP_EN(DRP_EN),
        .DRP_DI(DRP_DI),
        .DRP_WE(DRP_WE),
        
        `ifdef SYNTHESIS
        .pcie_7x_mgt_rxn(pcie_7x_mgt_rxn),
        .pcie_7x_mgt_rxp(pcie_7x_mgt_rxp),
        .pcie_7x_mgt_txn(pcie_7x_mgt_txn),
        .pcie_7x_mgt_txp(pcie_7x_mgt_txp),
        `endif //SYNTHESIS 
        
        .REFCLK(REFCLK_PCIE),
        .PERST(PERST_PCIE),
        
        .bar0(bar0),
        .bar1(bar1),
        .bar2(bar2),
        .bar_clk(app_clk),
        .bar_aresetn(app_aresetn)
    );

    //-------------MMR--------------\\

    axi4_lite_if #(.AW(GP0_ADDR_W), .DW(MMR_DATA_W)) un();

    axi_2master 
    axi_interconnect_i(
        .aresetn(app_aresetn),
        .aclk(app_clk),
        .m1(GP_CONTROL),
        .m2(bar0),
        .s(un)
    );

    axi_crossbar
    #(
        .N(MMR_DEV_COUNT2),
        .AW(MMR_ADDR_W),
        .DW(MMR_DATA_W)
    ) 
    mmr_crossbar 
    (
        .aresetn(app_aresetn),
        .aclk(app_clk),
        .m(un),
        .s(mmr)
    );

    mem_wrapper
    mem_i (
        .aclk(app_clk),
        .aresetn(app_aresetn),
        .axi(mmr[MMR_SYS]),
        .offset(0)
    );

    mem_controller mem_controller_i(
        .aclk(app_clk),
        .aresetn(app_aresetn),
        .bus(mmr[MMR_MEM]),
        .offset(HP0_offset)
    );

    //-------------QSPI--------------\\
    `ifndef SYNTHESIS
    sys_clk_gen
    #(
        .halfcycle (CLK_PRD / 2 * 1000), // in ps
        .offset    (0)  // 
    ) CLK_GEN (
        .sys_clk (spi_aclk)
    );
    assign spi_oclk = ~spi_aclk;
    `else // SYNTHESIS
    
    assign spi_aresetn = app_aresetn;
    qspi_pll (
        .clk_out1(spi_aclk),
        .clk_out2(spi_oclk),
        .resetn(spi_aresetn),
        .locked(),
        .clk_in1(app_clk)
    );
    `endif // SYNTHESIS

    axi4_lite_if #(.DW(BAR0_DATA_W), .AW(BAR0_ADDR_W)) plug();

    qspi_wrapper 
    #(
        .SPI_W(SPI_W)
    ) qspi_wrapper_i (
        .aclk(app_clk),
        .aresetn(app_aresetn),
        .ps_bus(plug),
        .pcie_bus(mmr[MMR_QSPI]),
        //.pcie_bus(plug),

        .spi_aclk(spi_aclk),
        .spi_oclk(spi_oclk),
        .spi_aresetn(spi_aresetn),
        
        .SCK(SCK),
        .CSn(CSn),
        .MISO(MISO),
        .MOSI(MOSI)
    );

    //-------------SFP---------------\\
    logic        sfp_reset;
    logic        sfp_tx_clk;
    logic        sfp_rx_clk;
    logic [15:0] sfp_tx_data;
    logic [15:0] sfp_rx_data;
    logic [1:0]  sfp_tx_is_k;
    logic [1:0]  sfp_rx_is_k;
    logic        tx_reset_done;
    logic        rx_reset_done;
    logic        gnd = 0;
    
    logic        pll_reset;
    logic        pll_lock;
    logic        gt0_rxdisperr_out;
    logic        gt0_rxnotintable_out;
    logic        gt0_rxbyteisaligned_out;
    logic        gt0_rxbyterealign_out;
    logic        gt0_rxcommadet_out;
    logic        sfp_aligned;

    assign sfp_reset = ~PS_aresetn | sfp_loss;
    assign led[1]    = tx_reset_done;
    assign led[2]    = rx_reset_done;
    assign led[3]    = sfp_rx_is_k[0] || sfp_rx_is_k[1];

   
    `ifdef MGT_FULL_STACK
    gtpwizard
    gtpwizard_i (
        .refclk(REFCLK_SFP),
        .sysclk(PS_clk), 
        .soft_reset(sfp_reset),
        .tx_reset_done(tx_reset_done),
        .rx_reset_done(rx_reset_done),
        .tx_clk(sfp_tx_clk),
        .rx_clk(sfp_rx_clk),
        .tx_data(sfp_tx_data),
        .rx_data(sfp_rx_data),
        .txcharisk(sfp_tx_is_k),
        .rxcharisk(sfp_rx_is_k),
        .aligned(sfp_aligned),
        .rx_n(sfp_rx_n),
        .rx_p(sfp_rx_p),
        .tx_n(sfp_tx_n),
        .tx_p(sfp_tx_p),    
        .qpll0outclk(QPLL0OUTCLK),
        .qpll0outrefclk(QPLL0OUTREFCLK),
        .qpll1reset(QPLL1RESET),
        .qpll1pd(QPLL1PD),
        .qpll1lock(QPLL1LOCK),
        .qpll1refclklost(QPLL1REFCLKLOST),    
        .qpll1outclk(QPLL1OUTCLK),
        .qpll1outrefclk(QPLL1OUTREFCLK)

    );
    `else 
    gtp_model gtp_model_i(
        .refclk(REFCLK_SFP),
        .sysclk(PS_clk), 
        .soft_reset(sfp_reset),
        .tx_reset_done(tx_reset_done),
        .rx_reset_done(rx_reset_done),
        .tx_clk(sfp_tx_clk),
        .rx_clk(sfp_rx_clk),
        .tx_data(sfp_tx_data),
        .rx_data(sfp_rx_data),
        .txcharisk(sfp_tx_is_k),
        .rxcharisk(sfp_rx_is_k)
    );
    `endif // MGT_FULL_STACK

    //--------------EVR--------------\\
    logic [7:0] ev;
    axi4_lite_if #(.AW(32), .DW(32)) shared_data();
    evr evr_i
    (
        .refclk(PS_clk),

        //------GTP signals-------
        .aligned(sfp_aligned),

        .tx_resetdone(tx_reset_done),
        .rx_resetdone(rx_reset_done),

        .tx_clk(sfp_tx_clk),
        .rx_clk(sfp_rx_clk),
        .tx_data(sfp_tx_data),
        .rx_data(sfp_rx_data),
        .tx_charisk(sfp_tx_is_k),
        .rx_charisk(sfp_rx_is_k),

        //------Application signals-------
        .app_clk(app_clk),
        .app_rst(app_reset),
        .ev(ev),
        .mmr(mmr[MMR_EVR]),
        .tx(mmr[MMR_TX]),
        .shared_data_out(shared_data)
    );

    //ddsc_if #( .DW        ( 32              )) ddsc_out_i();
    axi4_lite_if #(.AW(TBL_MEM_ADDR_W), .DW(TBL_DATA_W)) ddsc_shared();

    /*axi4_lite_if #(.AW(TBL_MEM_ADDR_W), .DW(TBL_DATA_W)) conv_tbl_i();
    axi4_lite_if #(.AW(TBL_MEM_ADDR_W), .DW(TBL_DATA_W)) desc_tbl_i();
    axi4_lite_if #(.AW(TBL_MEM_ADDR_W), .DW(TBL_DATA_W)) ddsc_shared();
    ddsc_if #( .DW        ( 32              )) ddsc_out_i();


    ddsc_m #(
        .NUMBER         (0              ),
        .AW             (TBL_MEM_ADDR_W ),
        .DW             (TBL_DATA_W     ),
        .EVENT_BUS_W    (EV_W           ),
        .DESC_ITEM_DW   (DESC_ITEM_DW   ),
        .DESC_ITEM_COUNT(DESC_ITEM_COUNT),
        .B_FIELD_W      (B_FIELD_W      ),
        .CLK_PRD        (CLK_PRD        )
    ) ddsc_avmm (
        .clk        (app_clk         ),
        .rst        (app_reset       ),
        .mmr_i      (mmr[MMR_DDSC]   ),
        .conv_tbl_i (conv_tbl_i      ),
        .desc_tbl_i (desc_tbl_i      ),
        .sync       (sync            ),
        .sync_prd   (sync_prd        ),
        .ev         (ev              ),
        .b_field    (b_field         ),
        .b_ready    (b_ready         ),
        .out        (ddsc_out_i      ),
        .shared_in_i(shared_data     )
    );*/

    /*ila_0 ila_tx(
        .clk(sfp_tx_clk),
        .probe0(sfp_tx_data),
        .probe1(sfp_tx_is_k)
    );*/

    shared_data_mem shared_data_mem_i
    (
        .clk(app_clk),
        .aresetn(app_aresetn),
        .mmr(mmr[MMR_SHARED]),
        .shared_data_in(ddsc_shared)
    );

    scc_m ssc_i(
        .clk(app_clk),
        .aresetn(),
        .cdr_locked(sfp_aligned),

        .mmr(mmr[MMR_SCC]),

        .ev(ev),
        .sync(sync),
        .align(),
        .log_start(),

        .dds_clk_ena(),

        .sync_x2(), 
        .align_x2(),

        .test_out(test_out),

        .sync_prd(sync_prd),
        .sync_PS(PS_sync)
    );

    //-------------GPIO--------------\\
    blink #(
        .FREQ_HZ(100000000) // 1s
    )
    blink_i (
        .reset(~app_aresetn),
        .clk(app_clk),
        .led(led[0])
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
    /*logic [7:0] bram [0:WORDS_IN_BRAM-1] = 
    '{ 
        8'h5C, // start
        8'h04, // addr = 4 segment
        8'hAD, 8'h74, 8'hAD, 8'h74, // 0-3 byte data 
        8'h7A, 8'h34, 8'h74, 8'hAD, // 4-7 byte data
        8'hAD, 8'h74, 8'hAD, 8'h74, // 8-11 byte data
        8'h7A, 8'h34, 8'h74, 8'hAD, // 12-15 byte data
        8'h3C, // stop
        8'hF7, 8'hd9, // checksum
        8'h00, 8'h00,
        8'h00, 8'h00,
        8'h00, 8'h00,
        8'h00, 8'h00,
        8'h00, 8'h00, 
        8'h00
    };*/

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

    //assign tx_data = {MSB, LSB};    
   // assign is_k    = {isk_msb, isk_lsb};


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

module test_fifo(
    input  logic        clk,
    input  logic        rst,
    input  logic        clear,

    axi4_lite_if.s     axi,

    input  logic [32:0] presc
);
    logic wr_en;
    logic [7:0] data_in;
    logic [32:0] cnt;
    logic full;

    assign wr_en = cnt == presc;
    always_ff @(posedge clk) begin
        if(rst || clear)
        begin
            data_in <= 0;
            cnt     <= 0;
        end
        else 
        begin
            if(!full)
                cnt <= cnt + 1;
            if(cnt >= presc)
                cnt <= 0;

            if(cnt == presc)
            begin
                data_in <= data_in+1;
            end
        end
    end


    event_fifo event_fifo_i(
        .aclk(clk),
        .aresetn(!rst && !clear),
        .wr_en(wr_en),
        .data_in(data_in),
        .axi(axi),
        .full(full)
    );

endmodule