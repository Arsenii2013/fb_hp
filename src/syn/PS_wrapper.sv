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
    axi4_lite_if.s                  SLAVES[15],
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


    logic [32:0] SLAVES_ARADDR [14];
    logic [32:0] SLAVES_AWADDR [14];

    localparam SLAVES_BASE = 'hFFFC0000;
    localparam SLAVES_SIZE = 'h1000;
    genvar i;
    generate
        for(i = 0; i < 14; i++) begin
            assign SLAVES_ARADDR[i] = SLAVES[i].araddr + SLAVES_BASE + SLAVES_SIZE * i;
            assign SLAVES_AWADDR[i] = SLAVES[i].awaddr + SLAVES_BASE + SLAVES_SIZE * i;
        end
    endgenerate
   
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

        .S01_AXI_0_araddr(SLAVES_ARADDR[0]),
        .S01_AXI_0_arprot(SLAVES[0].arprot),
        .S01_AXI_0_arready(SLAVES[0].arready),
        .S01_AXI_0_arvalid(SLAVES[0].arvalid),
        .S01_AXI_0_awaddr(SLAVES_AWADDR[0]),
        .S01_AXI_0_awprot(SLAVES[0].awprot),
        .S01_AXI_0_awready(SLAVES[0].awready),
        .S01_AXI_0_awvalid(SLAVES[0].awvalid),
        .S01_AXI_0_bready(SLAVES[0].bready),
        .S01_AXI_0_bresp(SLAVES[0].bresp),
        .S01_AXI_0_bvalid(SLAVES[0].bvalid),
        .S01_AXI_0_rdata(SLAVES[0].rdata),
        .S01_AXI_0_rready(SLAVES[0].rready),
        .S01_AXI_0_rresp(SLAVES[0].rresp),
        .S01_AXI_0_rvalid(SLAVES[0].rvalid),
        .S01_AXI_0_wdata(SLAVES[0].wdata),
        .S01_AXI_0_wready(SLAVES[0].wready),
        .S01_AXI_0_wstrb(SLAVES[0].wstrb),
        .S01_AXI_0_wvalid(SLAVES[0].wvalid),
        
        .S02_AXI_0_araddr(SLAVES_ARADDR[1]),
        .S02_AXI_0_arprot(SLAVES[1].arprot),
        .S02_AXI_0_arready(SLAVES[1].arready),
        .S02_AXI_0_arvalid(SLAVES[1].arvalid),
        .S02_AXI_0_awaddr(SLAVES_AWADDR[1]),
        .S02_AXI_0_awprot(SLAVES[1].awprot),
        .S02_AXI_0_awready(SLAVES[1].awready),
        .S02_AXI_0_awvalid(SLAVES[1].awvalid),
        .S02_AXI_0_bready(SLAVES[1].bready),
        .S02_AXI_0_bresp(SLAVES[1].bresp),
        .S02_AXI_0_bvalid(SLAVES[1].bvalid),
        .S02_AXI_0_rdata(SLAVES[1].rdata),
        .S02_AXI_0_rready(SLAVES[1].rready),
        .S02_AXI_0_rresp(SLAVES[1].rresp),
        .S02_AXI_0_rvalid(SLAVES[1].rvalid),
        .S02_AXI_0_wdata(SLAVES[1].wdata),
        .S02_AXI_0_wready(SLAVES[1].wready),
        .S02_AXI_0_wstrb(SLAVES[1].wstrb),
        .S02_AXI_0_wvalid(SLAVES[1].wvalid),

        .S03_AXI_0_araddr(SLAVES_ARADDR[2]),
        .S03_AXI_0_arprot(SLAVES[2].arprot),
        .S03_AXI_0_arready(SLAVES[2].arready),
        .S03_AXI_0_arvalid(SLAVES[2].arvalid),
        .S03_AXI_0_awaddr(SLAVES_AWADDR[2]),
        .S03_AXI_0_awprot(SLAVES[2].awprot),
        .S03_AXI_0_awready(SLAVES[2].awready),
        .S03_AXI_0_awvalid(SLAVES[2].awvalid),
        .S03_AXI_0_bready(SLAVES[2].bready),
        .S03_AXI_0_bresp(SLAVES[2].bresp),
        .S03_AXI_0_bvalid(SLAVES[2].bvalid),
        .S03_AXI_0_rdata(SLAVES[2].rdata),
        .S03_AXI_0_rready(SLAVES[2].rready),
        .S03_AXI_0_rresp(SLAVES[2].rresp),
        .S03_AXI_0_rvalid(SLAVES[2].rvalid),
        .S03_AXI_0_wdata(SLAVES[2].wdata),
        .S03_AXI_0_wready(SLAVES[2].wready),
        .S03_AXI_0_wstrb(SLAVES[2].wstrb),
        .S03_AXI_0_wvalid(SLAVES[2].wvalid),

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

    logic sync;
    logic busy = 0;

    assign sync = EMIO_I[0];
    assign EMIO_O[1] = busy;

    always_ff @(posedge peripheral_clock) begin
        if(sync) begin
            if($urandom()%4 == 0) begin
                busy <= 1;
            end
        end
        if(busy) begin
            if($urandom()%10 == 0) begin
                busy <= 0;
            end
        end
    end

    genvar slaves_i;
    generate
    for(slaves_i = 0; slaves_i < 15; slaves_i++) begin
        mem_wrapper
        slave_i (
            .aclk(app_clk),
            .aresetn(aresetn),
            .axi(SLAVES[slaves_i]),
            .offset(0)
        );

        /*mem_controller mem_controller_i(
        .aclk(peripheral_clock),
        .aresetn(peripheral_aresetn),
        .bus(SLAVES[slaves_i])*/


        /*event_generator event_generator_i(
            .app_clk(app_clk),
            .aresetn(aresetn),
            .mmr(SLAVES[slaves_i])
        );*/
    end
    endgenerate

    assign GP_CONTROL.awaddr = 0;
    assign GP_CONTROL.araddr = 0;
    assign GP_CONTROL.wdata = 0;
    assign GP_CONTROL.awvalid = 0;
    assign GP_CONTROL.arvalid = 0;
    assign GP_CONTROL.wvalid = 0;
    assign GP_CONTROL.bready = 0;
    assign GP_CONTROL.rready = 0;

    assign GP_DATA.awaddr = 0;
    assign GP_DATA.araddr = 0;
    assign GP_DATA.wdata = 0;
    assign GP_DATA.awvalid = 0;
    assign GP_DATA.arvalid = 0;
    assign GP_DATA.wvalid = 0;
    assign GP_DATA.bready = 0;
    assign GP_DATA.rready = 0;

    `endif //SYNTHESIS 
        
 endmodule

 module arready_0_slave(    
    input logic         aclk,
    input logic         aresetn,
    axi4_lite_if.s      axi
    );
    axi4_lite_if #(.AW(32), .DW(32)) to_mem();

    assign to_mem.awaddr = axi.awaddr;
    assign to_mem.awprot = axi.awprot;
    assign to_mem.awvalid = axi.awvalid;
    assign to_mem.wdata = axi.wdata;
    assign to_mem.wstrb = axi.wstrb;
    assign to_mem.wvalid = axi.wvalid;
    assign to_mem.bready = axi.bready;
    assign to_mem.araddr = axi.araddr;
    assign to_mem.arprot = axi.arprot;
    assign to_mem.arvalid = axi.arvalid;
    assign to_mem.rready = axi.rready;

    assign axi.awready = to_mem.awready;
    assign axi.wready = to_mem.wready;
    assign axi.bresp = to_mem.bresp;
    assign axi.bvalid = to_mem.bvalid;
    assign axi.arready = 0;
    assign axi.rdata = to_mem.rdata;
    assign axi.rresp = to_mem.rresp;
    assign axi.rvalid = to_mem.rvalid;

    mem_wrapper mem_i(
        .aresetn(aresetn),
        .aclk(aclk),
        .axi(to_mem),
        .offset(0)
    );
endmodule

module reg_slice_wrapper(
    input logic         aclk,
    input logic         aresetn,
    axi4_lite_if.s      in,
    axi4_lite_if.m      out
);
    axi_reg_slice axi_reg_slice_i(
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_awaddr(in.awaddr),
        .s_axi_awprot(in.awprot),
        .s_axi_awvalid(in.awvalid),
        .s_axi_awready(in.awready),
        .s_axi_wdata(in.wdata),
        .s_axi_wstrb(in.wstrb),
        .s_axi_wvalid(in.wvalid),
        .s_axi_wready(in.wready),
        .s_axi_bresp(in.bresp),
        .s_axi_bvalid(in.bvalid),
        .s_axi_bready(in.bready),
        .s_axi_araddr(in.araddr),
        .s_axi_arprot(in.arprot),
        .s_axi_arvalid(in.arvalid),
        .s_axi_arready(in.arready),
        .s_axi_rdata(in.rdata),
        .s_axi_rresp(in.rresp),
        .s_axi_rvalid(in.rvalid),
        .s_axi_rready(in.rready),
        .m_axi_awaddr(out.awaddr),
        .m_axi_awprot(out.awprot),
        .m_axi_awvalid(out.awvalid),
        .m_axi_awready(out.awready),
        .m_axi_wdata(out.wdata),
        .m_axi_wstrb(out.wstrb),
        .m_axi_wvalid(out.wvalid),
        .m_axi_wready(out.wready),
        .m_axi_bresp(out.bresp),
        .m_axi_bvalid(out.bvalid),
        .m_axi_bready(out.bready),
        .m_axi_araddr(out.araddr),
        .m_axi_arprot(out.arprot),
        .m_axi_arvalid(out.arvalid),
        .m_axi_arready(out.arready),
        .m_axi_rdata(out.rdata),
        .m_axi_rresp(out.rresp),
        .m_axi_rvalid(out.rvalid),
        .m_axi_rready(out.rready)
    );
endmodule