`timescale 1ns/1ns

module gtpwizard(
    input  logic       refclk_n,
    input  logic       refclk_p,
    input  logic       sysclk,
    input  logic       soft_reset,
    output logic       tx_reset_done,
    output logic       rx_reset_done,
    output logic       tx_clk,
    output logic       rx_clk,
    //input  logic       data_valid_in,

    output logic [15:0] rx_data,
    input  logic [15:0] tx_data,
    input  logic [1:0]  txcharisk,
    output logic [1:0]  rxcharisk,

    input  logic       rx_n,
    input  logic       rx_p,
    output logic       tx_n,
    output logic       tx_p
);
    logic txfsmresetdone;
    logic rxfsmresetdone;
    //logic data_valid_in;
    logic rxmcommaalignen;
    logic rxpcommaalignen;

    logic rxresetdone;
    logic txresetdone;

    logic rxresetdone_r;
    logic rxresetdone_r2;
    logic rxresetdone_r3;

    logic rxfsmresetdone_r;
    logic rxfsmresetdone_r2; 

    logic txfsmresetdone_r;
    logic txfsmresetdone_r2;

    assign data_valid_in = rxresetdone;
    assign tx_reset_done = txfsmresetdone_r2 && txresetdone;
    assign rx_reset_done = rxfsmresetdone_r2 && rxresetdone_r3;
    assign rxmcommaalignen = rxresetdone;
    assign rxpcommaalignen = rxresetdone;

    gtwizard gtwizard_i(
        .soft_reset_tx_in               (soft_reset),
        .soft_reset_rx_in               (soft_reset),
        .dont_reset_on_data_error_in    ('b0),
        .q0_clk1_gtrefclk_pad_n_in      (refclk_n),
        .q0_clk1_gtrefclk_pad_p_in      (refclk_p),
        .gt0_tx_fsm_reset_done_out      (txfsmresetdone),
        .gt0_rx_fsm_reset_done_out      (rxfsmresetdone),
        .gt0_data_valid_in              (data_valid_in),
        .gt0_txusrclk_out               (),
        .gt0_txusrclk2_out              (tx_clk),
        .gt0_rxusrclk_out               (),
        .gt0_rxusrclk2_out              (rx_clk),

        //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpaddr_in                 (9'd0),
        .gt0_drpdi_in                   (16'd0),
        .gt0_drpdo_out                  (),
        .gt0_drpen_in                   (1'b0),
        .gt0_drprdy_out                 (),
        .gt0_drpwe_in                   (1'b0),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt0_eyescanreset_in            ('b0),
        .gt0_rxuserrdy_in               ('b1),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt0_eyescandataerror_out       (),
        .gt0_eyescantrigger_in          ('b0),
        //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt0_rxdata_out                 (rx_data),
        //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        //.gt0_rxchariscomma_out          (),
        .gt0_rxcharisk_out              (rxcharisk),
        .gt0_rxdisperr_out              (),
        .gt0_rxnotintable_out           (),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtprxn_in                  (rx_n),
        .gt0_gtprxp_in                  (rx_p),
        //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        //.gt0_rxphmonitor_out            (gt0_rxphmonitor_i),
        //.gt0_rxphslipmonitor_out        (gt0_rxphslipmonitor_i),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxbyteisaligned_out        (),
        .gt0_rxbyterealign_out          (),
        .gt0_rxcommadet_out             (),
        .gt0_rxmcommaalignen_in         (rxmcommaalignen),
        .gt0_rxpcommaalignen_in         (rxpcommaalignen),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt0_dmonitorout_out            (),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt0_rxlpmhfhold_in             ('b0),
        .gt0_rxlpmlfhold_in             ('b0),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt0_rxoutclkfabric_out         (),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               ('b0),
        .gt0_rxlpmreset_in              ('b0),
        //.gt0_rxpcsreset_in              ('b0),
        //.gt0_rxpmareset_in              ('b0),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        //.gt0_rxpolarity_in              ('b0),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (rxresetdone),

        //---------------------- TX Configurable Driver Ports ----------------------
        //.gt0_txpostcursor_in            ('b0),
        //.gt0_txprecursor_in             ('b0),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               ('b0),
        .gt0_txuserrdy_in               ('b1),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt0_txdata_in                  (tx_data),
        //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
        //.gt0_txchardispmode_in          (gt0_txchardispmode_i),
        //.gt0_txchardispval_in           (gt0_txchardispval_i),
        .gt0_txcharisk_in               (txcharisk),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt0_gtptxn_out                 (tx_n),
        .gt0_gtptxp_out                 (tx_p),
        //.gt0_txdiffctrl_in              ('b0),
        //.gt0_txinhibit_in               ('b0),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt0_txoutclkfabric_out         (),
        .gt0_txoutclkpcs_out            (),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        //.gt0_txpcsreset_in              ('b0),
        //.gt0_txpmareset_in              ('b0),
        .gt0_txresetdone_out            (txresetdone),
        //--------------- Transmit Ports - TX Polarity Control Ports ---------------
        //.gt0_txpolarity_in              ('b0),

        //____________________________COMMON PORTS________________________________
        .gt0_pll0reset_out(),
        .gt0_pll0outclk_out(),
        .gt0_pll0outrefclk_out(),
        .gt0_pll0lock_out(),
        .gt0_pll0refclklost_out(),    
        .gt0_pll1outclk_out(),
        .gt0_pll1outrefclk_out(),

        .sysclk_in(sysclk)

    );

    always @(posedge  rx_clk or negedge rxresetdone)
    begin
        if (!rxresetdone)
        begin
            rxresetdone_r    <=   #1 1'b0;
            rxresetdone_r2   <=   #1 1'b0;
            rxresetdone_r3   <=   #1 1'b0;
        end
        else
        begin
            rxresetdone_r    <=   #1 rxresetdone;
            rxresetdone_r2   <=   #1 rxresetdone_r;
            rxresetdone_r3   <=   #1 rxresetdone_r2;
        end
    end

    always @(posedge rx_clk or negedge rxfsmresetdone)
    begin
    if (!rxfsmresetdone)
        begin
            rxfsmresetdone_r    <=   #1 1'b0;
            rxfsmresetdone_r2   <=   #1 1'b0;
        end
        else
        begin
            rxfsmresetdone_r    <=   #1 rxfsmresetdone;
            rxfsmresetdone_r2   <=   #1 rxfsmresetdone_r;
        end
    end

    always @(posedge tx_clk or negedge txfsmresetdone)
    begin
        if (!txfsmresetdone)
        begin
            txfsmresetdone_r    <=   #1 1'b0;
            txfsmresetdone_r2   <=   #1 1'b0;
        end
        else
        begin
            txfsmresetdone_r    <=   #1 txfsmresetdone;
            txfsmresetdone_r2   <=   #1 txfsmresetdone_r;
        end
    end

endmodule