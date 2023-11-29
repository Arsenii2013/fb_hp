`timescale 1ns/1ns

module gt_common_wrapper(
    input  logic REFCLK0,
    input  logic REFCLK1,

    input  logic PLL0LOCKDETCLK,
    input  logic PLL1LOCKDETCLK,
    input  logic PLL0PD,
    input  logic PLL1PD,
    input  logic PLL0RESET,
    input  logic PLL1RESET,

    output logic PLL0OUTCLK,
    output logic PLL1OUTCLK,
    output logic PLL0OUTREFCLK,
    output logic PLL1OUTREFCLK,
    output logic PLL0LOCK,
    output logic PLL1LOCK,
    output logic PLL0REFCLKLOST,
    output logic PLL1REFCLKLOST
);


    GTPE2_COMMON #
    (
       
        //---------- Simulation Attributes -------------------------------------                                                     
        .SIM_PLL0REFCLK_SEL             (3'b001),                               //    pcie - 001, sfp - 010                                               
        .SIM_PLL1REFCLK_SEL             (3'b001),                               //      
        `ifndef SYNTHESIS                                             
        .SIM_RESET_SPEEDUP              ("True"),                        //     
        `endif //SYNTHESIS                                               
        .SIM_VERSION                    ("1.0"),                        //   pcie - 1.0, spf - 2.0                                                
                                                                                                                                     
        //---------- Clock Attributes ------------------------------------------                                                     
        .PLL0_CFG                       (27'h01F024C),                          // PCIE                                               
        .PLL1_CFG                       (27'h01F03DC),                          // SFP                                                
        .PLL_CLKOUT_CFG                 (8'd0),                                                                                  
        .PLL0_DMON_CFG                  (1'b0),                                                                                
        .PLL1_DMON_CFG                  (1'b0),                                                                      
        .PLL0_FBDIV                     (5),                                    // PCIE                                                  
        .PLL1_FBDIV                     (4),                                    // SFP                                                   
        .PLL0_FBDIV_45                  (5),                                    // PCIE                                                  
        .PLL1_FBDIV_45                  (4),                                    // SFP                                                  
        .PLL0_INIT_CFG                  (24'h00001E),                                                                            
        .PLL1_INIT_CFG                  (24'h00001E),                                                                            
        .PLL0_LOCK_CFG                  ( 9'h1E8),                                 
        .PLL1_LOCK_CFG                  ( 9'h1E8),                                                                                                                                                
        .PLL0_REFCLK_DIV                (1),                                    // PCIE                                                  
        .PLL1_REFCLK_DIV                (1),                                    // SFP                                                 
                                                                                                                                     
        //---------- MISC ------------------------------------------------------                                                     
        .BIAS_CFG                       (64'h0000000000050001),                                                                 
      //.COMMON_CFG                     (32'd0),                                                                                                                                
        .RSVD_ATTR0                     (16'd0),                                                                                  
        .RSVD_ATTR1                     (16'd0)                                                                                   
    
    )
    gtpe2_common_i 
    (
           
        //---------- Clock -----------------------------------------------------                         
        .GTGREFCLK0                     ( 1'd0),                                //                       
        .GTGREFCLK1                     ( 1'd0),                                //                       
        .GTREFCLK0                      (REFCLK0),                              //                       
        .GTREFCLK1                      (REFCLK1),                              //                       
        .GTEASTREFCLK0                  ( 1'd0),                                //                       
        .GTEASTREFCLK1                  ( 1'd0),                                //                       
        .GTWESTREFCLK0                  ( 1'd0),                                //                       
        .GTWESTREFCLK1                  ( 1'd0),                                //                       
        .PLL0LOCKDETCLK                 (PLL0LOCKDETCLK),                       //                       
        .PLL1LOCKDETCLK                 (PLL1LOCKDETCLK),                       //                       
        .PLL0LOCKEN                     ( 1'd1),                                //                       
        .PLL1LOCKEN                     ( 1'd1),                                //                       
        .PLL0REFCLKSEL                  ( 3'd1),                                // PCIE - REFCLK0                      
        .PLL1REFCLKSEL                  ( 3'd2),                                // SFP  - REFCLK1                      
        .PLLRSVD1                       (16'd0),                                //                    
        .PLLRSVD2                       ( 5'd0),                                //                 
        
        .PLL0OUTCLK                     (PLL0OUTCLK),                           //                       
        .PLL1OUTCLK                     (PLL1OUTCLK),                           //                       
        .PLL0OUTREFCLK                  (PLL0OUTREFCLK),                        //                       
        .PLL1OUTREFCLK                  (PLL1OUTREFCLK),                        //                       
        .PLL0LOCK                       (PLL0LOCK),                             //                       
        .PLL1LOCK                       (PLL1LOCK),                             //                       
        .PLL0FBCLKLOST                  (),                                     //                       
        .PLL1FBCLKLOST                  (),                                     //                       
        .PLL0REFCLKLOST                 (PLL0REFCLKLOST),                       //                       
        .PLL1REFCLKLOST                 (PLL1REFCLKLOST),                       //                       
        .DMONITOROUT                    (),                                     // 
                                                                                                         
        //---------- Reset -----------------------------------------------------                         
        .PLL0PD                         (PLL0PD),                               //                       
        .PLL1PD                         (PLL1PD),                               //                       
        .PLL0RESET                      (PLL0RESET),                            //                       
        .PLL1RESET                      (PLL1RESET),                            //                       
                                                                                                   
        //---------- DRP -------------------------------------------------------                         
        /*.DRPCLK                         (QPLL_DRPCLK),                          //                       
        .DRPADDR                        (QPLL_DRPADDR),                         //                       
        .DRPEN                          (QPLL_DRPEN),                           //                       
        .DRPDI                          (QPLL_DRPDI),                           //                       
        .DRPWE                          (QPLL_DRPWE),                           //                       
                                                                                                         
        .DRPDO                          (QPLL_DRPDO),                           //                       
        .DRPRDY                         (QPLL_DRPRDY),                          //   */   
        .DRPADDR                        (8'b0),
        .DRPCLK                         (1'b0),
        .DRPDI                          (16'b0),
        .DRPDO                          (),
        .DRPEN                          (1'b0),
        .DRPRDY                         (),
        .DRPWE                          (1'b0),                 
                                                                                                         
        //---------- Band Gap --------------------------------------------------                         
        .BGBYPASSB                      ( 1'd1),                                //                    
        .BGMONITORENB                   ( 1'd1),                                //                     
        .BGPDB                          ( 1'd1),                                // 
        .BGRCALOVRD                     ( 5'd31),                               // 
        .BGRCALOVRDENB                  ( 1'd1),                                // 
        
        //---------- MISC ------------------------------------------------------
        .PMARSVD                        ( 8'd0),                                //
        .RCALENB                        ( 1'd1),                                //
                                                                               
        .REFCLKOUTMONITOR0              (),                                     //
        .REFCLKOUTMONITOR1              (),                                     //
        .PMARSVDOUT                     ()                                      //  
    
    );

endmodule