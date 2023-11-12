
module gtpwizard(
    input  logic       refclk_n,
    input  logic       refclk_p,
    input  logic       sysclk,
    output logic       reset_done,
    output logic       tx_clk,
    output logic       rx_clk,

    input  logic       reset,
    input  logic       rx_slide,

    output logic [15:0] rx_data,
    input  logic [15:0] tx_data,
    input  logic        tx_is_k,

    input  logic       rx_n,
    input  logic       rx_p,
    output logic       tx_n,
    output logic       tx_p
);
    logic tx_reset_done;
    logic rx_reset_done;
    logic data_valid_in;

    assign data_valid_in = 'b1;
    assign soft_reset = 'b0;
    assign reset_done = tx_reset_done;

    gtwizard gtwizard_i(
        .soft_reset_tx_in               (reset),
        .soft_reset_rx_in               (reset),
        .dont_reset_on_data_error_in    ('b1),
        .q0_clk1_gtrefclk_pad_n_in      (refclk_n),
        .q0_clk1_gtrefclk_pad_p_in      (refclk_p),
        .gt0_tx_fsm_reset_done_out      (tx_reset_done),
        .gt0_rx_fsm_reset_done_out      (rx_reset_done),
        .gt0_data_valid_in              (data_valid_in),
        .gt0_txusrclk_out               (),
        .gt0_txusrclk2_out              (tx_clk),
        .gt0_rxusrclk_out               (),
        .gt0_rxusrclk2_out              (rx_clk),

        //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpaddr_in                 ('b0),
        .gt0_drpdi_in                   ('b0),
        .gt0_drpdo_out                  (),
        .gt0_drpen_in                   ('b0),
        .gt0_drprdy_out                 (),
        .gt0_drpwe_in                   ('b0),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt0_eyescanreset_in            ('b0),
        .gt0_rxuserrdy_in               ('b1),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt0_eyescandataerror_out       (),
        .gt0_eyescantrigger_in          ('b0),
        //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt0_rxdata_out                 (rx_data),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtprxn_in                  (rx_n),
        .gt0_gtprxp_in                  (rx_p),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        //.gt0_rxslide_in                 (rx_slide),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt0_dmonitorout_out            (),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt0_rxlpmhfhold_in             ('b0),
        .gt0_rxlpmlfhold_in             ('b0),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt0_rxoutclkfabric_out         (),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               (reset),
        .gt0_rxlpmreset_in              ('b0),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (),


        .gt0_rxmcommaalignen_in         ('b1),
        .gt0_rxpcommaalignen_in         ('b1),



        //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               ('b0),
        .gt0_txuserrdy_in               ('b1),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt0_txdata_in                  (tx_data),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt0_gtptxn_out                 (tx_n),
        .gt0_gtptxp_out                 (tx_p),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt0_txoutclkfabric_out         (),
        .gt0_txoutclkpcs_out            (),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt0_txresetdone_out            (),
        .gt0_txcharisk_in               (tx_is_k),
        .gt0_tx8b10ben_in               ('b1),

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
endmodule