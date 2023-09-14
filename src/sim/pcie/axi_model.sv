`timescale 1ns/1ns

`include "axi4_lite_if.svh"

module axi_pcie_model(
    input  logic    REFCLK,
    input  logic    aresetn,
    output logic    clk_out,
    axi4_lite_if.m  axi
);

assign clk_out = REFCLK;

reg [255:0] testname;
reg test_failed_flag;
integer recv_data;  

initial begin
    wait(aresetn == 1);
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

task automatic pci_e_read(input [2:0] bar, input [32:0] addr, output [32:0] data);
    begin

    logic [3:0] rresp;
    $display("[%t] : Read from Memory 32 Space BAR %x", $realtime, bar);
    
    @(posedge REFCLK)
    axi.araddr  <= addr;
    axi.arvalid <= 1;
    axi.rready  <= 1;

    for(;;) begin
        @(posedge REFCLK)
        if(axi.arready)
            break;
    end
    axi.arvalid <= 0;

    for(;;) begin
        @(posedge REFCLK)
        if(axi.rvalid)
            break;
    end
    data        = axi.rdata;
    rresp       = axi.rresp;
    axi.rready  <= 0;

    if(rresp != 'b000)
        $display("RRESP isnt equal 0! RRESP = %x", rresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask

task automatic pci_e_write(input [2:0] bar, input [32:0] addr, input [32:0] data);
    begin

    logic [3:0] wresp;
    $display("[%t] : Write to Memory 32 Space BAR %x", $realtime, bar);
    
    @(posedge REFCLK)
    axi.awaddr  <= addr;
    axi.wdata   <= data;
    axi.awvalid <= 1;
    axi.wvalid  <= 1;
    axi.wstrb   <= 'hFFFF;
    axi.bready  <= 1;

    for(;;) begin
        @(posedge REFCLK)
        if(axi.awready && axi.wready)
            break;
    end
    axi.awvalid <= 0;
    axi.wvalid  <= 0;

    for(;;) begin
        @(posedge REFCLK)
        if(axi.bvalid)
            break;
    end
    wresp       = axi.bresp;
    axi.rready  <= 0;

    if(wresp != 'b000)
        $display("BRESP isnt equal 0! BRESP = %x", wresp);

    $display("[%t] : Address: %x, Data: %x", $realtime, addr, data);
    end
endtask


endmodule;
