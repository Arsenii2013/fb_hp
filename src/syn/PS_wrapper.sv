`include "axi4_lite_if.svh"
`include "top.svh"

module PS_wrapper_(
    `ifdef SYNTHESIS
    inout wire [14:0]  DDR_addr,
    inout wire [2:0]   DDR_ba,
    inout wire         DDR_cas_n,
    inout wire         DDR_ck_n,
    inout wire         DDR_ck_p,
    inout wire         DDR_cke,
    inout wire         DDR_cs_n,
    inout wire [3:0]   DDR_dm,
    inout wire [31:0]  DDR_dq,
    inout wire [3:0]   DDR_dqs_n,
    inout wire [3:0]   DDR_dqs_p,
    inout wire         DDR_odt,
    inout wire         DDR_ras_n,
    inout wire         DDR_reset_n,
    inout wire         DDR_we_n,
    inout wire         FIXED_IO_ddr_vrn,
    inout wire         FIXED_IO_ddr_vrp,
    inout wire [53:0]  FIXED_IO_mio,
    inout wire         FIXED_IO_ps_clk,
    inout wire         FIXED_IO_ps_porb,
    inout wire         FIXED_IO_ps_srstb,
    `endif //SYNTHESIS 

    output logic       peripheral_aresetn,
    output logic       peripheral_clock,
    output logic       peripheral_reset,
    axi4_lite_if.m                  GP_DATA,
    axi4_lite_if.m                  GP_CONTROL,
    axi4_lite_if.s                  HP0,
    input  logic [HP0_ADDR_W-1:0]   HP0_offset,
    input  logic [EMIO_SIZE-1:0]    EMIO_I,
    output logic [EMIO_SIZE-1:0]    EMIO_O,
    output logic [EMIO_SIZE-1:0]    EMIO_T,
    input  logic                    app_aresetn,
    input  logic                    app_clk
   );
    logic [HP0_ADDR_W-1:0]   HP0_offset_sync;


    xpm_cdc_gray #(
        .WIDTH(HP0_ADDR_W)
    )
    xpm_cdc_gray_inst (
        .dest_out_bin(HP0_offset_sync),
        .dest_clk(dest_clk),
        .src_clk(app_clk),
        .src_in_bin(HP0_offset)
    );


    logic [HP0_ADDR_W-1:0]   HP0_araddr, HP0_awaddr;
    assign HP0_araddr = HP0.araddr + HP0_offset;
    assign HP0_awaddr = HP0.awaddr + HP0_offset;
   
    `ifdef SYNTHESIS
    PS PS_i   (
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
        .GP_DATA_araddr(GP_DATA.araddr),
        .GP_DATA_arprot(GP_DATA.arprot),
        .GP_DATA_arready(GP_DATA.arready),
        .GP_DATA_arvalid(GP_DATA.arvalid),
        .GP_DATA_awaddr(GP_DATA.awaddr),
        .GP_DATA_awprot(GP_DATA.awprot),
        .GP_DATA_awready(GP_DATA.awready),
        .GP_DATA_awvalid(GP_DATA.awvalid),
        .GP_DATA_bready(GP_DATA.bready),
        .GP_DATA_bresp(GP_DATA.bresp),
        .GP_DATA_bvalid(GP_DATA.bvalid),
        .GP_DATA_rdata(GP_DATA.rdata),
        .GP_DATA_rready(GP_DATA.rready),
        .GP_DATA_rresp(GP_DATA.rresp),
        .GP_DATA_rvalid(GP_DATA.rvalid),
        .GP_DATA_wdata(GP_DATA.wdata),
        .GP_DATA_wready(GP_DATA.wready),
        .GP_DATA_wstrb(GP_DATA.wstrb),
        .GP_DATA_wvalid(GP_DATA.wvalid),


        .GP_CONTROL_araddr(GP_CONTROL.araddr),
        .GP_CONTROL_arprot(GP_CONTROL.arprot),
        .GP_CONTROL_arready(GP_CONTROL.arready),
        .GP_CONTROL_arvalid(GP_CONTROL.arvalid),
        .GP_CONTROL_awaddr(GP_CONTROL.awaddr),
        .GP_CONTROL_awprot(GP_CONTROL.awprot),
        .GP_CONTROL_awready(GP_CONTROL.awready),
        .GP_CONTROL_awvalid(GP_CONTROL.awvalid),
        .GP_CONTROL_bready(GP_CONTROL.bready),
        .GP_CONTROL_bresp(GP_CONTROL.bresp),
        .GP_CONTROL_bvalid(GP_CONTROL.bvalid),
        .GP_CONTROL_rdata(GP_CONTROL.rdata),
        .GP_CONTROL_rready(GP_CONTROL.rready),
        .GP_CONTROL_rresp(GP_CONTROL.rresp),
        .GP_CONTROL_rvalid(GP_CONTROL.rvalid),
        .GP_CONTROL_wdata(GP_CONTROL.wdata),
        .GP_CONTROL_wready(GP_CONTROL.wready),
        .GP_CONTROL_wstrb(GP_CONTROL.wstrb),
        .GP_CONTROL_wvalid(GP_CONTROL.wvalid),

        .HP0_araddr(HP0_araddr),
        .HP0_arprot(HP0.arprot),
        .HP0_arready(HP0.arready),
        .HP0_arvalid(HP0.arvalid),
        .HP0_awaddr(HP0_awaddr),
        .HP0_awprot(HP0.awprot),
        .HP0_awready(HP0.awready),
        .HP0_awvalid(HP0.awvalid),
        .HP0_bready(HP0.bready),
        .HP0_bresp(HP0.bresp),
        .HP0_bvalid(HP0.bvalid),
        .HP0_rdata(HP0.rdata),
        .HP0_rready(HP0.rready),
        .HP0_rresp(HP0.rresp),
        .HP0_rvalid(HP0.rvalid),
        .HP0_wdata(HP0.wdata),
        .HP0_wready(HP0.wready),
        .HP0_wstrb(HP0.wstrb),
        .HP0_wvalid(HP0.wvalid),

        .GPIO_I_0(EMIO_I),
        .GPIO_O_0(EMIO_O),
        .GPIO_T_0(EMIO_T),

        .peripheral_aresetn(peripheral_aresetn),
        .peripheral_clock(peripheral_clock),
        .peripheral_reset(peripheral_reset),
        .app_aresetn(app_aresetn),
        .app_clk(app_clk)
    );
    `endif //SYNTHESIS 

    `ifndef SYNTHESIS
    assign EMIO_O = '0;
    sys_clk_gen
    #(
        .halfcycle (CLK_PRD / 2 * 1000), 
        .offset    (CLK_PRD / 4 * 1000) // for simulate async with PCIE clock signal
    ) CLK_GEN (
        .sys_clk (peripheral_clock)
    );

    mem_wrapper
    PS_mem_i (
        .aclk(peripheral_clock),
        .aresetn(peripheral_aresetn),
        .axi(HP0),
        .offset(HP0_offset)
    );

    initial begin
        peripheral_aresetn <= 0;
        peripheral_reset   <= 1;
        for(int i = 0; i < 500; i++) begin
            @(posedge peripheral_clock);
        end
        peripheral_aresetn <= 1;
        peripheral_reset   <= 0;
    end
    `endif //SYNTHESIS 
        
 endmodule