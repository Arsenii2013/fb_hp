`timescale 1ns/1ns

module gtpwizard(
    input  logic        refclk,
    input  logic        sysclk,
    input  logic        soft_reset,
    output logic        tx_reset_done,
    output logic        rx_reset_done,
    output logic        tx_clk,
    output logic        rx_clk,
    //input  logic       data_valid_in,

    output logic [15:0] rx_data,
    input  logic [15:0] tx_data,
    input  logic [1:0]  txcharisk,
    output logic [1:0]  rxcharisk,

    input  logic        rx_n,
    input  logic        rx_p,
    output logic        tx_n,
    output logic        tx_p,

    //____________________________COMMON PORTS________________________________
    input  logic        qpll0outclk,
    input  logic        qpll0outrefclk,
    output logic        qpll1reset,
    output logic        qpll1pd,
    input  logic        qpll1lock,
    input  logic        qpll1refclklost,    
    input  logic        qpll1outclk,
    input  logic        qpll1outrefclk
);
//Resetdone logic
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


//Reset logic
    logic commonreset;
    logic qpll1reset_iternal;
    logic cpll_reset;

    gtwizard_common_reset gtwizard_common_reset_i(
        .STABLE_CLOCK(sysclk),
        .SOFT_RESET(soft_reset),
        .COMMON_RESET(commonreset)
    );

    gtwizard_cpll_railing gtwizard_cpll_railing_i(
        .cpll_reset_out(cpll_reset),
        .cpll_pd_out(qpll1pd),
        .refclk_out(),
        
        .refclk_in(refclk)
    );

    assign qpll1reset = commonreset | qpll1reset_iternal | cpll_reset;
//Clock logic
    logic txoutclk;
    logic rxoutclk;
    logic gt0_txmmcm_lock_i;
    logic gt0_txmmcm_reset_i;

    gtwizard_CLOCK_MODULE #
    (
        .MULT                           (28.0),
        .DIVIDE                         (5),
        .CLK_PERIOD                     (8.0),
        .OUT0_DIVIDE                    (7.0),
        .OUT1_DIVIDE                    (1),
        .OUT2_DIVIDE                    (1),
        .OUT3_DIVIDE                    (1)
    )
    txoutclk_mmcm0_i
    (
        .CLK0_OUT                       (tx_clk),
        .CLK1_OUT                       (),
        .CLK2_OUT                       (),
        .CLK3_OUT                       (),
        .CLK_IN                         (txoutclk),
        .MMCM_LOCKED_OUT                (gt0_txmmcm_lock_i),
        .MMCM_RESET_IN                  (gt0_txmmcm_reset_i)
    );

    BUFG rxoutclk_bufg1_i
    (
        .I                              (rxoutclk),
        .O                              (rx_clk)
    );
//Beacon logic
    logic       beacon_pulse_rx;
    logic       beacon_pulse_rx_expand;
    logic [1:0] beacon_cnt;
    logic       beacon_pulse_tx;

    assign beacon_pulse_rx        = rx_data[7:0] == 8'h7E;
    assign beacon_pulse_rx_expand = beacon_cnt != 'b0;

    always_ff @(posedge rx_clk) begin
        if(beacon_pulse_rx) 
            beacon_cnt <= 2'b11;
        else
            if(beacon_cnt != 2'b0)
                beacon_cnt <= beacon_cnt-1;         
    end

    xpm_cdc_pulse XPM_CDC_PULSE_i(
        .dest_clk(tx_clk),
        .dest_pulse(beacon_pulse_tx),
        .dest_rst('b0),
        .src_clk(rx_clk),
        .src_pulse(beacon_pulse_rx_expand),
        .src_rst('b0)
    );

    logic [15:0] tx_data_i;
    assign tx_data_i = {tx_data[15:8], beacon_pulse_tx ? 8'h7E : tx_data[7:0]};

//Core instanse
    gtwizard gtwizard_i(
        .soft_reset_tx_in               (soft_reset),
        .soft_reset_rx_in               (soft_reset),
        .dont_reset_on_data_error_in    ('b0),
        .gt0_tx_mmcm_lock_in            (gt0_txmmcm_lock_i),
        .gt0_tx_mmcm_reset_out          (gt0_txmmcm_reset_i),
        .gt0_tx_fsm_reset_done_out      (txfsmresetdone),
        .gt0_rx_fsm_reset_done_out      (rxfsmresetdone),
        .gt0_data_valid_in              (data_valid_in),
        .gt0_txoutclk_out               (txoutclk),
        .gt0_rxoutclk_out               (rxoutclk),

        .gt0_rxusrclk_in                (rx_clk), 
        .gt0_rxusrclk2_in               (rx_clk), 
        .gt0_txusrclk_in                (tx_clk), 
        .gt0_txusrclk2_in               (tx_clk), 

        //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpclk_in                  (sysclk),
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
        .gt0_rxdisperr_out              (gt0_rxdisperr_out),
        .gt0_rxnotintable_out           (gt0_rxnotintable_out),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtprxn_in                  (rx_n),
        .gt0_gtprxp_in                  (rx_p),
        //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        //.gt0_rxphmonitor_out            (gt0_rxphmonitor_i),
        //.gt0_rxphslipmonitor_out        (gt0_rxphslipmonitor_i),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxbyteisaligned_out        (gt0_rxbyteisaligned_out),
        .gt0_rxbyterealign_out          (gt0_rxbyterealign_out),
        .gt0_rxcommadet_out             (gt0_rxcommadet_out),
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
        .gt0_txdata_in                  (tx_data_i),
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
        .gt0_pll0outclk_in(qpll0outclk),
        .gt0_pll0outrefclk_in(qpll0outrefclk),
        .gt0_pll1reset_out(qpll1reset_iternal),
        .gt0_pll1lock_in(qpll1lock),
        .gt0_pll1refclklost_in(qpll1refclklost),    
        .gt0_pll1outclk_in(qpll1outclk),
        .gt0_pll1outrefclk_in(qpll1outrefclk),

        .sysclk_in(sysclk)

    );
//Resetdone logic
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



// From example project

`define DLY #1

module gtwizard_common_reset  #
   (
      parameter     STABLE_CLOCK_PERIOD      = 8        // Period of the stable clock driving this state-machine, unit is [ns]
   )
   (    
      input  wire      STABLE_CLOCK,             //Stable Clock, either a stable clock from the PCB
      input  wire      SOFT_RESET,               //User Reset, can be pulled any time
      output reg      COMMON_RESET = 1'b0             //Reset QPLL
   );


  localparam integer  STARTUP_DELAY    = 500;//AR43482: Transceiver needs to wait for 500 ns after configuration
  localparam integer WAIT_CYCLES      = STARTUP_DELAY / STABLE_CLOCK_PERIOD; // Number of Clock-Cycles to wait after configuration
  localparam integer WAIT_MAX         = WAIT_CYCLES + 10;                    // 500 ns plus some additional margin

  reg [7:0] init_wait_count = 0;
  reg       init_wait_done = 1'b0;
  wire      common_reset_i;
  reg       common_reset_asserted = 1'b0;

  localparam INIT = 1'b0;
  localparam ASSERT_COMMON_RESET = 1'b1;
    
  reg state = INIT;

  always @(posedge STABLE_CLOCK)
  begin
      // The counter starts running when configuration has finished and 
      // the clock is stable. When its maximum count-value has been reached,
      // the 500 ns from Answer Record 43482 have been passed.
      if (init_wait_count == WAIT_MAX) 
          init_wait_done <= `DLY  1'b1;
      else
        init_wait_count <= `DLY  init_wait_count + 1;
  end


  always @(posedge STABLE_CLOCK)
  begin
      if (SOFT_RESET == 1'b1)
       begin
         state <= INIT;
         COMMON_RESET <= 1'b0;
         common_reset_asserted <= 1'b0;
       end
      else
       begin
        case (state)
         INIT :
          begin
            if (init_wait_done == 1'b1) state <= ASSERT_COMMON_RESET;
          end
         ASSERT_COMMON_RESET :
          begin
            if(common_reset_asserted == 1'b0)
              begin
                COMMON_RESET <= 1'b1;
                common_reset_asserted <= 1'b1;
              end
            else
                COMMON_RESET <= 1'b0;
          end
          default:
              state <=  INIT; 
        endcase
       end
   end 


endmodule 

(* X_CORE_INFO = "gtwizard,gtwizard_v3_6_14,{protocol_file=Start_from_scratch}" *)
(* CORE_GENERATION_INFO = "clk_wiz_v2_1,clk_wiz_v2_1,{component_name=clk_wiz_v2_1,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,feedback_source=FDBK_AUTO,primtype_sel=MMCM_ADV,num_out_clk=1,clkin1_period=10.0,clkin2_period=10.0,use_power_down=false,use_reset=true,use_locked=true,use_inclk_stopped=false,use_status=false,use_freeze=false,use_clk_valid=false,feedback_type=SINGLE,clock_mgr_type=MANUAL,manual_override=false}" *)
module gtwizard_CLOCK_MODULE #
(
    parameter   MULT            =   2,
    parameter   DIVIDE          =   2,
    parameter   CLK_PERIOD      =   6.4,
    parameter   OUT0_DIVIDE     =   2,
    parameter   OUT1_DIVIDE     =   2,
    parameter   OUT2_DIVIDE     =   2,
    parameter   OUT3_DIVIDE     =   2    
)
 (// Clock in ports
  input         CLK_IN,
  // Clock out ports
  output        CLK0_OUT,
  output        CLK1_OUT,
  output        CLK2_OUT,
  output        CLK3_OUT,
  // Status and control signals
  input         MMCM_RESET_IN,
  output        MMCM_LOCKED_OUT
 );

  wire clkin1;
  // Input buffering
  //------------------------------------
  BUFG clkin1_buf
  (.O (clkin1),
   .I (CLK_IN));

  // Clocking primitive
  //------------------------------------
  // Instantiation of the MMCM primitive
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        clkfbout;
  wire        clkfbout_buf;
  wire        clkfboutb_unused;
  wire        clkout0b_unused;
  wire        clkout0;
  wire        clkout1;
  wire        clkout1b_unused;
  wire        clkout2;
  wire        clkout2b_unused;
  wire        clkout3;
  wire        clkout3b_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (DIVIDE),
    .CLKFBOUT_MULT_F      (MULT),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (OUT0_DIVIDE),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (CLK_PERIOD),
    .CLKOUT1_DIVIDE       (OUT1_DIVIDE),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (OUT2_DIVIDE),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKOUT3_DIVIDE       (OUT3_DIVIDE),
    .CLKOUT3_PHASE        (0.000),
    .CLKOUT3_DUTY_CYCLE   (0.500),
    .CLKOUT3_USE_FINE_PS  ("FALSE"),
    .REF_JITTER1          (0.010))
  mmcm_adv_inst
    // Output clocks
   (.CLKFBOUT            (clkfbout),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clkout0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clkout1),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout),
    .CLKIN1              (clkin1),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (MMCM_LOCKED_OUT),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (MMCM_RESET_IN));

  // Output buffering
  //-----BUFG in feedback not necessary as a known phase relationship is not needed between the outclk and the usrclk------
  //BUFG clkf_buf
  // (.O (clkfbout_buf),
  //  .I (clkfbout));


  BUFG clkout0_buf
   (.O   (CLK0_OUT),
    .I   (clkout0));

  BUFG clkout1_buf
   (.O   (CLK1_OUT),
    .I   (clkout1));

  //BUFG clkout2_buf
  // (.O   (CLK2_OUT),
  //  .I   (clkout2));

  //BUFG clkout3_buf
  // (.O   (CLK3_OUT),
  //  .I   (clkout3));
 assign CLK2_OUT = 1'b0;
 assign CLK3_OUT = 1'b0;
endmodule

module gtwizard_cpll_railing #
(
       parameter     USE_BUFG            = 0 //set it to 1 if you want to use BUFG
)
(
        output cpll_reset_out,
        output cpll_pd_out,
        output refclk_out,
        
        input refclk_in
);



(* equivalent_register_removal="no" *) reg [95:0]   cpllpd_wait    =  96'hFFFFFFFFFFFFFFFFFFFFFFFF;
(* equivalent_register_removal="no" *) reg [127:0]  cpllreset_wait = 128'h000000000000000000000000000000FF;
  wire    refclk_i;

generate
 if(USE_BUFG == 1)
 begin
  BUFG refclk_buf
   (.O   (refclk_i),
    .I   (refclk_in));
 end

 else
 begin
  BUFH refclk_buf
   (.O   (refclk_i),
    .I   (refclk_in));
 end 
endgenerate


assign refclk_out = refclk_i;

always @(posedge refclk_i)
begin
  cpllpd_wait <= {cpllpd_wait[94:0], 1'b0};
  cpllreset_wait <= {cpllreset_wait[126:0], 1'b0};
end

assign cpll_pd_out = cpllpd_wait[95];
assign cpll_reset_out = cpllreset_wait[127];


endmodule
