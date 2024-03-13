
`timescale 1ns/1ps
`include "top.svh"
`include "axi4_lite_if.svh"

module tx_bufferTB();

    logic app_clk = 0;    
    initial begin
        app_clk = 0;
        forever #5 app_clk = ~app_clk;
    end

    logic tx_clk = 0;    
    logic tx_odd = 0;
    initial begin
        tx_clk = 0;
        #2;
        forever #5 tx_clk = ~tx_clk;
    end
    always_ff @(posedge tx_clk) tx_odd = ~tx_odd;

    logic       tx_ready;
    logic [7:0] tx_data;
    logic       tx_charisk;

    logic       aresetn;


    axi4_lite_if     axi();

    tx_buffer DUT(
        .tx_clk(tx_clk),
        .tx_ready(tx_ready),
        .tx_data(tx_data),
        .tx_charisk(tx_charisk),
        .tx_odd(tx_odd),

        .app_clk(app_clk),
        .aresetn(aresetn),
        .axi(axi)
    );

    axi_master axi_master_i(
        .axi(axi),
        .aclk(app_clk),
        .aresetn(aresetn)
    );

    logic [31:0] read_data;

    initial begin
        aresetn <= 0;
        for(int i =0; i < 10; i++) begin
            @(posedge app_clk);
        end 
        aresetn <= 1;
        @(posedge app_clk);
         
        axi_master_i.read(32'h00, read_data); 
        axi_master_i.write(32'h14, 32'h89ABCDEF); 
        axi_master_i.write(32'h18, 32'b1001); 
        axi_master_i.write(32'h14, 32'h76543210); 
        axi_master_i.write(32'h18, 32'b0101); 
        axi_master_i.read(32'h00, read_data); 
        axi_master_i.write(32'h04, 32'b1); 
        axi_master_i.read(32'h00, read_data); 
        #100;
        axi_master_i.read(32'h00, read_data); 
        axi_master_i.write(32'h04, 32'b1); 

        #1000;
        $stop();
    end

endmodule


module axi_master(
    axi4_lite_if.m  axi,
    input  logic    aclk,
    input  logic    aresetn
);
    task automatic read(input [32:0] addr, output [32:0] data);
        begin

        logic [3:0] rresp;
        $display("Read");
        
        @(posedge aclk)
        axi.araddr  <= addr;
        axi.arvalid <= 1;
        axi.rready  <= 1;

        for(;;) begin
            @(posedge aclk)
            if(axi.arready)
                break;
        end
        axi.arvalid <= 0;

        for(;;) begin
            @(posedge aclk)
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

    task automatic write(input [32:0] addr, input [32:0] data);
        begin

        logic [3:0] wresp;
        $display("Write");
        
        @(posedge aclk)
        axi.awaddr  <= addr;
        axi.wdata   <= data;
        axi.awvalid <= 1;
        axi.wvalid  <= 1;
        axi.wstrb   <= 'hFFFF;
        axi.bready  <= 1;

        for(;;) begin
            @(posedge aclk)
            if(axi.awready && axi.wready)
                break;
        end
        axi.awvalid <= 0;
        axi.wvalid  <= 0;

        for(;;) begin
            @(posedge aclk)
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

endmodule