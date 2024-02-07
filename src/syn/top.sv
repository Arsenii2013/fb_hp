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
    input  logic [1:0]  pcie_7x_mgt_rxn,
    input  logic [1:0]  pcie_7x_mgt_rxp,
    output logic [1:0]  pcie_7x_mgt_txn,
    output logic [1:0]  pcie_7x_mgt_txp,
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

    );
    assign sfp_tx_dis = 'b0;

    logic PS_clk;
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
    axi4_lite_if #(.DW(GP0_DATA_W), .AW(GP0_ADDR_W)) GP0();
    axi4_lite_if #(.DW(HP0_DATA_W), .AW(HP0_ADDR_W)) HP0();

    axi4_lite_if #(.DW(BAR0_DATA_W), .AW(BAR0_ADDR_W)) bar0();
    axi4_lite_if #(.DW(BAR1_DATA_W), .AW(BAR1_ADDR_W)) bar1();
    axi4_lite_if #(.DW(BAR2_DATA_W), .AW(BAR2_ADDR_W)) bar2();    
    
    //localparam MMR_DEV_COUNT2 = 2 ** ($clog2(MMR_DEV_COUNT) + 1);
    localparam MMR_DEV_COUNT2 = 64;
    axi4_lite_if #(.AW(MMR_DEV_ADDR_W), .DW(MMR_DATA_W)) mmr[MMR_DEV_COUNT2]();
     
    //-------Processing System-------\\
    logic PS_aresetn;
    logic spi_aclk;
    logic spi_oclk;
    logic spi_aresetn;
    logic [HP0_ADDR_W-1:0] HP0_offset;

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

        .GP0(GP0),
        .HP0(bar2),
        .HP0_offset(HP0_offset),
        
        .peripheral_clock(PS_clk),
        .peripheral_aresetn(PS_aresetn),
        .peripheral_reset()
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
        .pcie_7x_mgt_rxn,
        .pcie_7x_mgt_rxp,
        .pcie_7x_mgt_txn,
        .pcie_7x_mgt_txp,
        `endif //SYNTHESIS 
        
        .REFCLK(REFCLK_PCIE),
        .PERST(PERST_PCIE),
        
        .bar0(bar0),
        .bar1(bar1),
        .bar2(bar2),
        .bar_clk(PS_clk),
        .bar_aresetn(PS_aresetn)
    );

    //-------------MMR--------------\\
    axi_crossbar
    #(
        .N(MMR_DEV_COUNT2),
        .AW(MMR_ADDR_W),
        .DW(MMR_DATA_W)
    ) 
    mmr_crossbar 
    (
        .aresetn(PS_aresetn),
        .aclk(PS_clk),
        .m(bar0),
        .s(mmr)
    );

    mem_wrapper
    mem_i (
        .aclk(PS_clk),
        .aresetn(PS_aresetn),
        .axi(mmr[MMR_SYS]),
        .offset(0)
    );

    mem_controller mem_controller_i(
        .aclk(PS_clk),
        .aresetn(PS_aresetn),
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
    assign spi_aresetn = PS_aresetn;
    `else // SYNTHESIS
    
    assign spi_aresetn = PS_aresetn;
    qspi_pll (
        .clk_out1(spi_aclk),
        .clk_out2(spi_oclk),
        .resetn(spi_aresetn),
        .locked(),
        .clk_in1(PS_clk)
    );
    `endif // SYNTHESIS

    axi4_lite_if #(.DW(BAR0_DATA_W), .AW(BAR0_ADDR_W)) plug();

    qspi_wrapper 
    #(
        .SPI_W(SPI_W)
    ) qspi_wrapper_i (
        .aclk(PS_clk),
        .aresetn(PS_aresetn),
        .ps_bus(GP0),
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
        .refclk(sfp_refclk_p),
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

    /*ila_0 ila_rx(
        .clk(rx_clk),
        .probe0(tx_reset_done),
        .probe1(rx_reset_done),
        .probe2(sfp_tx_data),
        .probe3(sfp_rx_data),
        .probe4(sfp_tx_is_k),
        .probe5(sfp_rx_is_k),
        .probe6(gnd),
        .probe7(gnd)
    );*/
    
    /*ila_0 ila_tx(
        .clk(sfp_tx_clk),
        .probe0(tx_reset_done),
        .probe1(rx_reset_done),
        .probe2(gtpwizard_i.tx_data_i),
        .probe3(sfp_rx_data),
        .probe4(sfp_tx_is_k),
        .probe5(sfp_rx_is_k),
        .probe6(pll_reset),
        .probe7(pll_lock)
    );*/


    /*ila_0 ila_tx(
        .clk(pcie_i.pcie_qpll_drp_clk),
        .probe0(!pcie_i.pcie_qpll_drp_rst_n),
        .probe1(pcie_i.pcie_qpll_drp_ovrd),
        .probe2(&pcie_i.pcie_qpll_drp_gen3),
        .probe3(pcie_i.pcie_qpll_drp_qplllock),
        .probe4(pcie_i.pcie_qpll_drp_start),
        .probe5(pcie_i.DRP_DO),
        .probe6(pcie_i.DRP_RDY),
        .probe7(pcie_i.DRP_ADDR),
        .probe8(pcie_i.DRP_EN),
        .probe9(pcie_i.DRP_DI),
        .probe10(pcie_i.pcie_qpll_drp_done),
        .probe11(pcie_i.pcie_qpll_drp_reset),
        .probe12(pcie_i.pcie_qpll_drp_crscode),
        .probe13(pcie_i.pcie_qpll_drp_fsm)
    );*/

    //`ifndef SYNTHESIS
    frame_gen
    frame_gen_i (
        .tx_data(sfp_tx_data),
        .is_k(sfp_tx_is_k),
        .tx_clk(sfp_tx_clk),
        .ready(tx_reset_done)
    );
    //`else 
    //    assign sfp_tx_data = '0;
    //    assign sfp_tx_is_k = '0;
    //`endif // SYNTHESIS


    shared_data_rx_wrapper
    shared_data_rx_wrapper_i(
        .clk(sfp_rx_clk),
        .rst(sfp_reset),
        .aresetn(PS_aresetn),
        .rx_data_in(sfp_rx_data[15:8]),
        .rx_isk_in(sfp_rx_is_k[1]),
        .pci_clk(PS_clk),
        .axi_pci(bar1)
    );

    //-------------GPIO--------------\\
    blink #(
        .FREQ_HZ(100000000) // 1s
    )
    blink_i (
        .reset(~PS_aresetn),
        .clk(PS_clk),
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

/*
logic [15:0] bram [0:WORDS_IN_BRAM*2-1] = 
    '{  8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h005C, // event - D00.0, data - start = K28.2
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h0004, // event - D00.0, data - addr  = 4 segment
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h00AD, // event - D00.0, data - AD
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h0074, // event - D00.0, data - 74
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h00AD, // event - D00.0, data - AD
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h0074, // event - D00.0, data - 74
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h007A, // event - D00.0, data - 7A
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h0034, // event - D00.0, data - 34
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h0074, // event - D00.0, data - 74
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h00AD, // event - D00.0, data - AD
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h00AD, // event - D00.0, data - AD
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h0074, // event - D00.0, data - 74
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0
        8'h00AD, // event - D00.0, data - AD
        8'h0000, // event - D00.0, data - dustributed bus = D00.0
        8'h007A, // event - D00.0, data - 7A
        8'hBC00, // event - K28.5, data - dustributed bus = D00.0

    8'h7A, 
    8'h00, 
    8'h34, 
    8'h00, 
    8'h74, 
    8'h00, 
    8'hAD, 
    8'h00,
    8'h3C,
    8'hF7, 8'hd9,
    8'h00,
    8'h00,
    8'h00};
    */