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
    
    input  logic        REFCLK_n,
    input  logic        REFCLK_p,
    input  logic        PERST,

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

    //-------------MRF---------------\\
    input  logic       mrf_refclk_n,
    input  logic       mrf_refclk_p,

    input  logic       mrf_rx_n,
    input  logic       mrf_rx_p,
    output logic       mrf_tx_n,
    output logic       mrf_tx_p,

    //-------------GPIO--------------\\
    output logic [4:0] led

    );

    logic REFCLK;
    logic PS_aresetn;
    logic PS_clk;
    logic spi_aclk;
    logic spi_oclk;
    logic spi_aresetn;
    logic [HP0_ADDR_W-1:0] HP0_offset;
     
    //-------Processing System-------\\
    axi4_lite_if #(.DW(GP0_DATA_W), .AW(GP0_ADDR_W)) GP0();
    axi4_lite_if #(.DW(HP0_DATA_W), .AW(HP0_ADDR_W)) HP0();

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
        .HP0(HP0),
        .HP0_offset(HP0_offset),
        
        .peripheral_clock(PS_clk),
        .peripheral_aresetn(PS_aresetn),
        .peripheral_reset()
    );

    //-------------PCI-E-------------\\ 
    axi4_lite_if #(.DW(BAR0_DATA_W), .AW(BAR0_ADDR_W)) bar0();
    axi4_lite_if #(.DW(BAR1_DATA_W), .AW(BAR1_ADDR_W)) bar1();
    axi4_lite_if #(.DW(BAR2_DATA_W), .AW(BAR2_ADDR_W)) bar2();

    IBUFDS_GTE2 REFCLK_ibuf_i (.O(REFCLK), .ODIV2(), .I(REFCLK_p), .CEB(1'b0), .IB(REFCLK_n));
    
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
        
        `ifdef SYNTHESIS
        .pcie_7x_mgt_rxn,
        .pcie_7x_mgt_rxp,
        .pcie_7x_mgt_txn,
        .pcie_7x_mgt_txp,
        `endif //SYNTHESIS 
        
        .REFCLK(REFCLK),
        .PERST(PERST),
        
        .bar0(bar0),
        .bar1(bar1),
        .bar2(HP0),
        .bar_clk(PS_clk),
        .bar_aresetn(PS_aresetn)
    );

    //-------------MMR--------------\\
    localparam MMR_DEV_COUNT2 = 2 ** ($clog2(MMR_DEV_COUNT) + 1);

    
    axi4_lite_if #(.AW(MMR_ADDR_W), .DW(MMR_DATA_W)) mmr[MMR_DEV_COUNT2]();
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
        .m(bar1),
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
    qspi_wrapper 
    #(
        .SPI_W(SPI_W)
    ) qspi_wrapper_i (
        .aclk(PS_clk),
        .aresetn(PS_aresetn),
        .ps_bus(GP0),
        .pcie_bus(mmr[MMR_QSPI]),

        .spi_aclk(spi_aclk),
        .spi_oclk(spi_oclk),
        .spi_aresetn(spi_aresetn),
        
        .SCK(SCK),
        .CSn(CSn),
        .MISO(MISO),
        .MOSI(MOSI)
    );


    //-------------MRF---------------\\
    logic        mrf_reset;
    logic        mrf_tx_clk;
    logic [15:0] mrf_tx_data;
    logic [15:0] mrf_rx_data;
    logic [1:0]  mrf_tx_is_k;
    logic [1:0]  mrf_rx_is_k;
    logic        tx_reset_done;
    logic        rx_reset_done;

    assign led[1] = tx_reset_done;
    assign led[2] = rx_reset_done;
    assign led[3] = mrf_rx_is_k[0] || mrf_rx_is_k[1];


    gtpwizard
    gtpwizard_i (
        .refclk_n(mrf_refclk_n),
        .refclk_p(mrf_refclk_p),
        .sysclk(PS_clk), 
        .soft_reset(mrf_reset),
        .tx_reset_done(tx_reset_done),
        .rx_reset_done(rx_reset_done),
        .tx_clk(mrf_tx_clk),
        .rx_clk(),
        .tx_data(mrf_tx_data),
        .rx_data(mrf_rx_data),
        .txcharisk(mrf_tx_is_k),
        .rxcharisk(mrf_rx_is_k),
        .rx_n(mrf_rx_n),
        .rx_p(mrf_rx_p),
        .tx_n(mrf_tx_n),
        .tx_p(mrf_tx_p),
    );

    frame_gen
    frame_gen_i (
        .tx_data(mrf_tx_data),
        .is_k(mrf_tx_is_k),
        .tx_clk(mrf_tx_clk),
        .ready(tx_reset_done)
    );

    //-------------GPIO--------------\\
    blink
    blink_i (
        .reset(PS_aresetn),
        .clk(REFCLK),
        .led(led[0])
    );

endmodule

module frame_gen (
    output logic  [15:0]  tx_data,
    output logic  [2 :0]  is_k,

    input  logic         tx_clk,
    input  logic         ready 
); 

    localparam   WORDS_IN_BRAM = 8;

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