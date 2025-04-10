module former(
  pc_axi_awaddr,
  pc_axi_awlen,
  pc_axi_awsize,
  pc_axi_awburst,
  pc_axi_awlock,
  pc_axi_awcache,
  pc_axi_awprot,
  pc_axi_awqos,
  pc_axi_awregion,
  pc_axi_awvalid,
  pc_axi_awready,
  pc_axi_wlast,
  pc_axi_wdata,
  pc_axi_wstrb,
  pc_axi_wvalid,
  pc_axi_wready,
  pc_axi_bresp,
  pc_axi_bvalid,
  pc_axi_bready,
  pc_axi_araddr,
  pc_axi_arlen,
  pc_axi_arsize,
  pc_axi_arburst,
  pc_axi_arlock,
  pc_axi_arcache,
  pc_axi_arprot,
  pc_axi_arqos,
  pc_axi_arregion,
  pc_axi_arvalid,
  pc_axi_arready,
  pc_axi_rlast,
  pc_axi_rdata,
  pc_axi_rresp,
  pc_axi_rvalid,
  pc_axi_rready,

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

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWADDR" *)
input wire [31 : 0] pc_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWLEN" *)
input wire [7 : 0] pc_axi_awlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWSIZE" *)
input wire [2 : 0] pc_axi_awsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWBURST" *)
input wire [1 : 0] pc_axi_awburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWLOCK" *)
input wire [0 : 0] pc_axi_awlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWCACHE" *)
input wire [3 : 0] pc_axi_awcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWPROT" *)
input wire [2 : 0] pc_axi_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWQOS" *)
input wire [3 : 0] pc_axi_awqos;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWREGION" *)
input wire [3 : 0] pc_axi_awregion;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWVALID" *)
input wire pc_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI AWREADY" *)
input wire pc_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI WLAST" *)
input wire pc_axi_wlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI WDATA" *)
input wire [63 : 0] pc_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI WSTRB" *)
input wire [7 : 0] pc_axi_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI WVALID" *)
input wire pc_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI WREADY" *)
input wire pc_axi_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI BRESP" *)
input wire [1 : 0] pc_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI BVALID" *)
input wire pc_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI BREADY" *)
input wire pc_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARADDR" *)
input wire [31 : 0] pc_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARLEN" *)
input wire [7 : 0] pc_axi_arlen;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARSIZE" *)
input wire [2 : 0] pc_axi_arsize;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARBURST" *)
input wire [1 : 0] pc_axi_arburst;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARLOCK" *)
input wire [0 : 0] pc_axi_arlock;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARCACHE" *)
input wire [3 : 0] pc_axi_arcache;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARPROT" *)
input wire [2 : 0] pc_axi_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARQOS" *)
input wire [3 : 0] pc_axi_arqos;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARREGION" *)
input wire [3 : 0] pc_axi_arregion;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARVALID" *)
input wire pc_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI ARREADY" *)
input wire pc_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI RLAST" *)
input wire pc_axi_rlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI RDATA" *)
input wire [63 : 0] pc_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI RRESP" *)
input wire [1 : 0] pc_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI RVALID" *)
input wire pc_axi_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PC_AXI, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 62500000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 4, NUM_WRITE_OUTSTANDING 4, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN pcie_axi_pcie_0_0_axi_aclk_out, NUM_READ_THREADS 1, NUM_WRITE_\
THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_MODE = "monitor" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 PC_AXI RREADY" *)
input wire pc_axi_rready;

localparam COUNT_TO = 100;
    reg [32:0] cnt = 0;
    assign pulse = cnt == COUNT_TO;

    always @(posedge clk) begin
        if(!aresetn) begin
            cnt <= 0;
        end else begin
            if(pc_axi_awvalid || pc_axi_arvalid || pc_axi_wvalid) begin
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
    logic awvalid = 0;
    logic arvalid = 0;
    logic clk = 0;    
    logic aresetn = 1;

    former DUT (
        .awvalid(awvalid),
        .arvalid(arvalid),
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
        for(int i =0; i < 100; i++) begin
            @(posedge clk);
        end 
        awvalid <= 0;
        @(posedge clk);
        arvalid <= 1;
        for(int i =0; i < 1000; i++) begin
            @(posedge clk);
        end 
        for(int i =0; i < 1000; i++) begin
            @(posedge clk);
        end 
        #1000;
        $stop();
    end
endmodule*/