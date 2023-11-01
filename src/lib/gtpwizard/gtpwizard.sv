
module gtpwizard(
    input logic Q0_CLK1_PAD_N,
    input logic Q0_CLK1_PAD_P,
);

    logic soft_reset;
    logic tx_reset_done;
    logic rx_reset_done;
    logic recived_data_valid;
    logic tx_user_clk2;
    logic rx_user_clk2;

    logic [7:0] rdata;

    assign recived_data_valid = 'b1;

    gtwizard gtwizard_i(
        .soft_reset_tx_in               (soft_reset),
        .soft_reset_rx_in               (soft_reset),
        .dont_reset_on_data_error_in    ('b0),
        .q0_clk1_gtrefclk_pad_n_in      (Q0_CLK1_PAD_N),
        .q0_clk1_gtrefclk_pad_p_in      (Q0_CLK1_PAD_P),
        .gt0_tx_fsm_reset_done_out      (tx_reset_done),
        .gt0_rx_fsm_reset_done_out      (rx_reset_done),
        .gt0_data_valid_in              (recived_data_valid),
        .gt0_txusrclk_out(),
        .gt0_txusrclk2_out(tx_user_clk2),
        .gt0_rxusrclk_out(),
        .gt0_rxusrclk2_out(rx_user_clk2),

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
        .gt0_rxdata_out                 (gt0_rxdata_i),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtprxn_in                  (RXN_IN),
        .gt0_gtprxp_in                  (RXP_IN),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxslide_in                 (gt0_rxslide_i),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt0_dmonitorout_out            (gt0_dmonitorout_i),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt0_rxlpmhfhold_in             (tied_to_ground_i),
        .gt0_rxlpmlfhold_in             (tied_to_ground_i),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt0_rxoutclkfabric_out         (gt0_rxoutclkfabric_i),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               (tied_to_ground_i),
        .gt0_rxlpmreset_in              (gt0_rxlpmreset_i),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (gt0_rxresetdone_i),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               (tied_to_ground_i),
        .gt0_txuserrdy_in               (tied_to_vcc_i),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt0_txdata_in                  (gt0_txdata_i),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt0_gtptxn_out                 (TXN_OUT),
        .gt0_gtptxp_out                 (TXP_OUT),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt0_txoutclkfabric_out         (gt0_txoutclkfabric_i),
        .gt0_txoutclkpcs_out            (gt0_txoutclkpcs_i),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt0_txresetdone_out            (gt0_txresetdone_i),
    );
endmodule