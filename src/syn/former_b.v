module former_b(
    S00_AXI_awaddr,
    S00_AXI_awlen,
    S00_AXI_awsize,
    S00_AXI_awburst,
    S00_AXI_awlock,
    S00_AXI_awcache,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awvalid,
    S00_AXI_awready,
    S00_AXI_wdata,
    S00_AXI_wstrb,
    S00_AXI_wlast,
    S00_AXI_wvalid,
    S00_AXI_wready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_bready,
    S00_AXI_araddr,
    S00_AXI_arlen,
    S00_AXI_arsize,
    S00_AXI_arburst,
    S00_AXI_arlock,
    S00_AXI_arcache,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arvalid,
    S00_AXI_arready,
    S00_AXI_rdata,
    S00_AXI_rresp,
    S00_AXI_rlast,
    S00_AXI_rvalid,
    S00_AXI_rready,

    S00_AXI_awid,
    S00_AXI_arid,

    pulse,

    clk,
    aresetn
);
    output pulse;
    input  clk;
    input  aresetn;
    wire   pulse;
    wire   clk;
    wire   aresetn;

  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWID" *) input wire [5:0]S00_AXI_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARID" *) input wire [5:0]S00_AXI_arid;

  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWADDR" *) input wire [31:0]S00_AXI_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWLEN" *) input wire [3:0]S00_AXI_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWSIZE" *) input wire [2:0]S00_AXI_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWBURST" *) input wire [1:0]S00_AXI_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWLOCK" *) input wire [1:0]S00_AXI_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWCACHE" *) input wire [3:0]S00_AXI_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWPROT" *) input wire [2:0]S00_AXI_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWQOS" *) input wire [3:0]S00_AXI_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWVALID" *) input wire S00_AXI_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI AWREADY" *) input wire S00_AXI_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WDATA" *) input wire [63:0]S00_AXI_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WSTRB" *) input wire [7:0]S00_AXI_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WLAST" *) input wire S00_AXI_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WVALID" *) input wire S00_AXI_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI WREADY" *) input wire S00_AXI_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BRESP" *) input wire [1:0]S00_AXI_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BVALID" *) input wire S00_AXI_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI BREADY" *) input wire S00_AXI_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARADDR" *) input wire [31:0]S00_AXI_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARLEN" *) input wire [3:0]S00_AXI_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARSIZE" *) input wire [2:0]S00_AXI_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARBURST" *) input wire [1:0]S00_AXI_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARLOCK" *) input wire [1:0]S00_AXI_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARCACHE" *) input wire [3:0]S00_AXI_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARPROT" *) input wire [2:0]S00_AXI_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARQOS" *) input wire [3:0]S00_AXI_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARVALID" *) input wire S00_AXI_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI ARREADY" *) input wire S00_AXI_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RDATA" *) input wire [63:0]S00_AXI_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RRESP" *) input wire [1:0]S00_AXI_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RLAST" *) input wire S00_AXI_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RVALID" *) input wire S00_AXI_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S00_AXI RREADY" *) (* X_INTERFACE_MODE = "monitor" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXI, DATA_WIDTH 64, PROTOCOL AXI3, FREQ_HZ 10000000, ID_WIDTH 6, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN PS_app_clk, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input wire S00_AXI_rready;


localparam COUNT_TO = 100;
    reg [32:0] cnt = 0;
    assign pulse = cnt == COUNT_TO;

    reg aw_hand = 0, w_hand = 0;
    always @(posedge clk) begin
        if(!aresetn) begin
            aw_hand <= 0;
            w_hand <= 0;
        end else begin
            if(S00_AXI_awvalid & S00_AXI_awready) begin
                aw_hand <= 1;
            end
            if(S00_AXI_wvalid & S00_AXI_wready) begin
                w_hand <= 1;
            end
            if(S00_AXI_bvalid & S00_AXI_bready) begin
                aw_hand <= 0;
                w_hand <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if(!aresetn) begin
            cnt <= 0;
        end else begin
            if(aw_hand | w_hand) begin
                if(cnt < COUNT_TO) begin
                    cnt <= cnt+1;
                end else begin
                    cnt <= cnt;
                end
            end else begin
                cnt <= 0;
            end
        end
    end

endmodule

/*
module formerTB();
    reg awvalid = 0;
    reg awready = 0;
    reg wvalid = 0;
    reg wready = 0;
    reg bready = 0;
    reg bvalid = 0;
    reg clk = 0;    
    reg aresetn = 1;

    former_b DUT (
        .S00_AXI_awvalid(awvalid),
        .S00_AXI_awready(awready),
        .S00_AXI_wvalid(wvalid),
        .S00_AXI_wready(wready),
        .S00_AXI_bvalid(bvalid),
        .S00_AXI_bready(bready),
        .clk(clk),
        .aresetn(aresetn)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        aresetn <= 0;
        for(int i =0; i < 10; i++) begin
            @(posedge clk);
        end 
        aresetn <= 1;
        @(posedge clk);
        for(int i =0; i < 100; i++) begin
            @(posedge clk);
        end 

        awvalid <= 1;
        awready <= 1;
        @(posedge clk);
        awvalid <= 0;
        awready <= 0;
        for(int i =0; i < 100; i++) begin
            @(posedge clk);
        end 
        bvalid <= 1;
        bready <= 1;
        @(posedge clk);
        bvalid <= 0;
        bready <= 0;

        wvalid <= 1;
        wready <= 1;
        @(posedge clk);
        wvalid <= 0;
        wready <= 0;
        for(int i =0; i < 100; i++) begin
            @(posedge clk);
        end 
        bvalid <= 1;
        bready <= 1;
        @(posedge clk);
        bvalid <= 0;
        bready <= 0;
        #1000;
        $stop();
    end
endmodule*/