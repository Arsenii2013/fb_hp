module mmcm_wrapper(
        input         clk_in1,
        input         clk_in2,
        input         clk_in_sel,
        
        output        clk_out1,

        // Dynamic phase shift ports
        input         psclk,
        input         psen,
        input         psincdec,
        output        psdone,

        // Status and control signals
        input         resetn,
        output        locked
    );
    logic clk_in1_clk_wiz;
    logic clk_in2_clk_wiz;
    IBUF clkin1_ibufg
    (.O (clk_in1_clk_wiz), .I (clk_in1));

    IBUF clkin2_ibufg
    (.O (clk_in2_clk_wiz), .I (clk_in2));


    logic        clk_out1_clk_wiz;

    logic        clkfbout;
    logic        clkfbout_buf;

    logic        locked_int;
    logic        reset_high;

    MMCME2_ADV
    #(.BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (1),
        .CLKFBOUT_MULT_F      (10.000),
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (10.000),
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKOUT0_USE_FINE_PS  ("TRUE"),
        .CLKIN1_PERIOD        (10.000),
        .CLKIN2_PERIOD        (10.000))
    mmcm_adv_inst
    (
        .CLKFBOUT            (clkfbout),
        .CLKFBOUTB           (),
        .CLKOUT0             (clk_out1_clk_wiz),
        .CLKOUT0B            (),
        .CLKOUT1             (),
        .CLKOUT1B            (),
        .CLKOUT2             (),
        .CLKOUT2B            (),
        .CLKOUT3             (),
        .CLKOUT3B            (),
        .CLKOUT4             (),
        .CLKOUT5             (),
        .CLKOUT6             (),
        .CLKFBIN             (clkfbout_buf),
        .CLKIN1              (clk_in1_clk_wiz),
        .CLKIN2              (clk_in2_clk_wiz),
        .CLKINSEL            (clk_in_sel),
        .DADDR               (7'h0),
        .DCLK                (1'b0),
        .DEN                 (1'b0),
        .DI                  (16'h0),
        .DO                  (),
        .DRDY                (),
        .DWE                 (1'b0),
        .PSCLK               (psclk),
        .PSEN                (psen),
        .PSINCDEC            (psincdec),
        .PSDONE              (psdone),
        .LOCKED              (locked_int),
        .CLKINSTOPPED        (),
        .CLKFBSTOPPED        (),
        .PWRDWN              (1'b0),
        .RST                 (reset_high)
    );
    assign reset_high = ~resen; 

    assign locked = locked_int;

    BUFG clkf_buf
    (.O (clkfbout_buf),
        .I (clkfbout));

    BUFG clkout1_buf
    (.O   (clk_out1),
        .I   (clk_out1_clk_wiz));

endmodule