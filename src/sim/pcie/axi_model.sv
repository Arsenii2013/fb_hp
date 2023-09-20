`timescale 1ns/1ns

`include "axi4_lite_if.svh"

module axi_pcie_model(

    axi4_lite_if.m    bar0,
    axi4_lite_if.m    bar1,
    axi4_lite_if.m    bar2,

    input  logic    REFCLK,
    input  logic    PERST,
    input  logic    bar_clk,
    input  logic    bar_aresetn
);

assign clk_out = bar_clk;

reg [255:0] testname;
reg test_failed_flag;
integer recv_data;  

initial begin
    wait((PERST && bar_aresetn) == 1);
    #1000;

    if ($value$plusargs("TESTNAME=%s", testname))
        $display("Running test {%0s}......", testname);
    else
    begin
        // $display("[%t] %m: No TESTNAME specified!", $realtime);
        // $finish(2);
        testname = "pio_writeReadBack_test0";
        $display("Running default test {%0s}......", testname);
    end

    //Test starts here
    if (testname == "dummy_test")
    begin
        $display("[%t] %m: Invalid TESTNAME: %0s", $realtime, testname);
        $finish(2);
    end
    `include "pcie_tests.vh"
    else begin
        $display("[%t] %m: Error: Unrecognized TESTNAME: %0s", $realtime, testname);
        $finish(2);
    end
end

task automatic bar0_read(input [32:0] addr, output [32:0] data);
    begin

    logic [3:0] rresp;
    
    @(posedge bar_clk)
    bar0.araddr  <= addr;
    bar0.arvalid <= 1;
    bar0.rready  <= 1;

    for(;;) begin
        @(posedge bar_clk)
        if(bar0.arready)
            break;
    end
    bar0.arvalid <= 0;

    for(;;) begin
        @(posedge bar_clk)
        if(bar0.rvalid)
            break;
    end
    data        = bar0.rdata;
    rresp       = bar0.rresp;
    bar0.rready  <= 0;

    if(rresp != 'b000)
        $display("RRESP isnt equal 0! RRESP = %x", rresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic bar0_write(input [32:0] addr, input [32:0] data);
    begin

    logic [3:0] wresp;
    
    @(posedge bar_clk)
    bar0.awaddr  <= addr;
    bar0.wdata   <= data;
    bar0.awvalid <= 1;
    bar0.wvalid  <= 1;
    bar0.wstrb   <= 'hFFFF;
    bar0.bready  <= 1;

    for(;;) begin
        @(posedge bar_clk)
        if(bar0.awready && bar0.wready)
            break;
    end
    bar0.awvalid <= 0;
    bar0.wvalid  <= 0;

    for(;;) begin
        @(posedge bar_clk)
        if(bar0.bvalid)
            break;
    end
    wresp       = bar0.bresp;
    bar0.rready  <= 0;

    if(wresp != 'b000)
        $display("BRESP isnt equal 0! BRESP = %x", wresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic bar1_read(input [32:0] addr, output [32:0] data);
    begin

    logic [3:0] rresp;
    
    @(posedge bar_clk)
    bar1.araddr  <= addr;
    bar1.arvalid <= 1;
    bar1.rready  <= 1;

    for(;;) begin
        @(posedge bar_clk)
        if(bar1.arready)
            break;
    end
    bar1.arvalid <= 0;

    for(;;) begin
        @(posedge bar_clk)
        if(bar1.rvalid)
            break;
    end
    data        = bar1.rdata;
    rresp       = bar1.rresp;
    bar1.rready  <= 0;

    if(rresp != 'b000)
        $display("RRESP isnt equal 0! RRESP = %x", rresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic bar1_write(input [32:0] addr, input [32:0] data);
    begin

    logic [3:0] wresp;
    
    @(posedge bar_clk)
    bar1.awaddr  <= addr;
    bar1.wdata   <= data;
    bar1.awvalid <= 1;
    bar1.wvalid  <= 1;
    bar1.wstrb   <= 'hFFFF;
    bar1.bready  <= 1;

    for(;;) begin
        @(posedge bar_clk)
        if(bar1.awready && bar1.wready)
            break;
    end
    bar1.awvalid <= 0;
    bar1.wvalid  <= 0;

    for(;;) begin
        @(posedge bar_clk)
        if(bar1.bvalid)
            break;
    end
    wresp       = bar1.bresp;
    bar1.rready  <= 0;

    if(wresp != 'b000)
        $display("BRESP isnt equal 0! BRESP = %x", wresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic bar2_read(input [32:0] addr, output [32:0] data);
    begin

    logic [3:0] rresp;
    
    @(posedge bar_clk)
    bar2.araddr  <= addr;
    bar2.arvalid <= 1;
    bar2.rready  <= 1;

    for(;;) begin
        @(posedge bar_clk)
        if(bar2.arready)
            break;
    end
    bar2.arvalid <= 0;

    for(;;) begin
        @(posedge bar_clk)
        if(bar2.rvalid)
            break;
    end
    data        = bar2.rdata;
    rresp       = bar2.rresp;
    bar2.rready  <= 0;

    if(rresp != 'b000)
        $display("RRESP isnt equal 0! RRESP = %x", rresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic bar2_write(input [32:0] addr, input [32:0] data);
    begin

    logic [3:0] wresp;
    
    @(posedge bar_clk)
    bar2.awaddr  <= addr;
    bar2.wdata   <= data;
    bar2.awvalid <= 1;
    bar2.wvalid  <= 1;
    bar2.wstrb   <= 'hFFFF;
    bar2.bready  <= 1;

    for(;;) begin
        @(posedge bar_clk)
        if(bar2.awready && bar2.wready)
            break;
    end
    bar2.awvalid <= 0;
    bar2.wvalid  <= 0;

    for(;;) begin
        @(posedge bar_clk)
        if(bar2.bvalid)
            break;
    end
    wresp       = bar2.bresp;
    bar2.rready  <= 0;

    if(wresp != 'b000)
        $display("BRESP isnt equal 0! BRESP = %x", wresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic pci_e_read(input [2:0] bar, input [32:0] addr, output [32:0] data);
    begin

    logic [3:0] rresp;
    $display("[%t] : Read from Memory 32 Space BAR %x", $realtime, bar);
    if(bar == 'b00)
        bar0_read(addr, data);
    else if( bar == 'b01)
        bar1_read(addr, data);
    else if( bar == 'b10)
        bar2_read(addr, data);
    end
endtask

task automatic pci_e_write(input [2:0] bar, input [32:0] addr, input [32:0] data);
    begin

    logic [3:0] wresp;
    $display("[%t] : Write to Memory 32 Space BAR %x", $realtime, bar);
    
    if(bar == 'b00)
        bar0_write(addr, data);
    else if( bar == 'b01)
        bar1_write(addr, data);
    else if( bar == 'b10)
        bar2_write(addr, data);

    end
endtask


endmodule;
