module hs_spi_tb;

//------------------------------------------------
`timescale 1ns / 1ps;

//------------------------------------------------
//
//      Parameters
//
localparam PRD          = 10ns;

localparam SPI_AVMM_AW  = 10;
localparam SPI_AVMM_DW  = 32;
localparam MAX_BURST    = 128;
localparam SPI_W        = 4;

//------------------------------------------------
//
//      Objects
//
logic             clk  = 1;
logic             oclk;
logic             rst  = 1;
logic             clkout;

logic             sck;
logic             cs_n;
logic [SPI_W-1:0] mosi;
logic [SPI_W-1:0] miso;

avmm_if #(
    .AW        ( SPI_AVMM_AW ),
    .DW        ( SPI_AVMM_DW ),
    .MAX_BURST ( MAX_BURST   )
) m_i();

avmm_if #(
    .AW        ( SPI_AVMM_AW ),
    .DW        ( SPI_AVMM_DW ),
    .MAX_BURST ( MAX_BURST   )
) s_i();

//------------------------------------------------
//
//      Logic
//
always #(PRD/2) clk <= ~clk;
assign          oclk = ~clk;

initial begin
    #20ns
    rst = 0;
end

//------------------------------------------------
//
//      Instances
//
hs_spi_master_avmm_m
#(
    .AW        ( SPI_AVMM_AW ),
    .DW        ( SPI_AVMM_DW ),
    .SPI_W     ( SPI_W       ),
    .MAX_BURST ( MAX_BURST   )
)
spi_master
(
    .clk       ( clk         ),
    .oclk      ( oclk        ),
    .rst       ( rst         ),
    .bus       ( m_i         ),
    .SCK       ( sck         ),
    .CSn       ( cs_n        ),
    .MISO      ( miso        ),
    .MOSI      ( mosi        )
);
//------------------------------------------------
hs_spi_slave_avmm_m
#(
    .AW        ( SPI_AVMM_AW ),
    .DW        ( SPI_AVMM_DW ),
    .SPI_W     ( SPI_W       ),
    .MAX_BURST ( MAX_BURST   )
)
spi_slave
(
    .clkout    ( clkout      ),
    .rst       ( rst         ),
    .bus       ( s_i         ),
    .SCK       ( sck         ),
    .CSn       ( cs_n        ),
    .MISO      ( miso        ),
    .MOSI      ( mosi        )
);
//------------------------------------------------
avmm_master_m
#(
    .MAX_BURST ( MAX_BURST   )
)
avmm_master
(
    .clk       ( clk         ),
    .bus       ( m_i         )
);
//------------------------------------------------
avmm_slave_stub #(
    .AW        ( SPI_AVMM_AW ),
    .DW        ( SPI_AVMM_DW ),
    .MAX_BURST ( MAX_BURST   )
)
avmm_slave
(
    .clk       ( clkout      ),
    .rst       ( rst         ),
    .bus       ( s_i         )
);
//------------------------------------------------
endmodule : hs_spi_tb



//------------------------------------------------
//
//      Test transaction generator
//
module avmm_master_m
#(
    parameter AW        = 10,
    parameter DW        = 32,
    parameter MAX_BURST = 256
)
(
    input logic    clk,
    avmm_if.master bus
);

//------------------------------------------------
`timescale 1ns / 1ps;

//------------------------------------------------
//
//      Types
//
typedef logic [DW-1:0] data_t;
typedef logic [AW-1:0] addr_t;

//------------------------------------------------
//
//      Function & Tasks
//
task automatic spi_write(input int    len,
                         input addr_t addr,
                         input data_t wdata[MAX_BURST]);

    automatic int cnt = 0;
    
    @(posedge clk)
    bus.write      <= 1;
    bus.burstcount <= len;
    bus.address    <= addr;
    bus.writedata  <= wdata[0];
    
    while (cnt < len) begin
        @(posedge clk)
        if (!bus.waitrequest) cnt++;
        bus.writedata <= wdata[cnt];
    end

    bus.write <= 0;   

endtask

//------------------------------------------------
task automatic spi_read(input  int    len,
                        input  addr_t addr,
                        output data_t rdata[MAX_BURST]);

    automatic int cnt = 0;

    @(posedge clk)
    bus.read       <= 1;
    bus.burstcount <= len;
    bus.address    <= addr;

    wait(bus.waitrequest == 0);
    
    @(posedge clk)
    bus.read <= 0;

    while (cnt < len) begin
        @(posedge clk)
        if (bus.readdatavalid) begin
            rdata[cnt] = bus.readdata;
            cnt++;
        end
    end

endtask

//------------------------------------------------
//
//      Logic
//
initial begin

    automatic int    n = 1;
    automatic data_t wdata[MAX_BURST];
    automatic data_t rdata[MAX_BURST];

    bus.write = 0;
    bus.read  = 0;

    #100ns;

    while (n <= MAX_BURST) begin
        
        automatic int i = 0;
        
        for (i=0; i<n; i++) begin
            wdata[i] = data_t'(n+i);
        end

        spi_write(n, 4*n, wdata);
        spi_read(n, 4*n, rdata);

        for (i=0; i<n; i++) begin
            if (wdata[i] != rdata[i]) begin
                $display("Error: wdata = 0x%x, rdata = 0x%x", wdata[i], rdata[i]);
                $stop();
            end
            else begin
                $display("wdata = 0x%x, rdata = 0x%x", wdata[i], rdata[i]);
            end
        end

        n++;
    end

    $display("Success");
    
    #100ns
    $stop();
end

//------------------------------------------------
endmodule : avmm_master_m
