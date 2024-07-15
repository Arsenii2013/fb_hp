
`timescale 1ns/1ps
`include "top.svh"
`include "axi4_lite_if.svh"

module event_fifoTB();

    logic app_clk = 0;    
    logic aresetn = 1;
    initial begin
        app_clk = 0;
        forever #5 app_clk = ~app_clk;
    end

    logic       wr_en;
    logic [7:0] data_in;

    axi4_lite_if     axi();

    event_fifo DUT(
        .aclk(app_clk),
        .aresetn(aresetn),
        .wr_en(wr_en),
        .data_in(data_in),

        .axi(axi)
    );

    axi_master axi_master_i(
        .axi(axi),
        .aclk(app_clk),
        .aresetn(aresetn)
    );

    logic [31:0] read_data;

    initial begin
        wr_en   <= 0;
        aresetn <= 0;
        for(int i =0; i < 10; i++) begin
            @(posedge app_clk);
        end 
        aresetn <= 1;
        @(posedge app_clk);


        axi_master_i.read(32'h00, read_data); 
        assert (read_data == 'h1) else $error(""); // empty

        @(posedge app_clk);
        wr_en   <= 1;
        data_in <= 'h1;
        @(posedge app_clk);
        data_in <= 'h2;
        @(posedge app_clk);
        data_in <= 'h3;
        @(posedge app_clk);
        data_in <= 'h4;
        @(posedge app_clk);
        wr_en   <= 0;
         

        axi_master_i.read(32'h00, read_data); 
        assert (read_data == 'h0) else $error(""); // not empty not full

        axi_master_i.read(32'h14, read_data); 
        assert (read_data == 'h1) else $error("");
        axi_master_i.read(32'h14, read_data); 
        assert (read_data == 'h2) else $error("");
        axi_master_i.read(32'h14, read_data); 
        assert (read_data == 'h3) else $error("");
        axi_master_i.read(32'h14, read_data); 
        assert (read_data == 'h4) else $error("");

        axi_master_i.read(32'h00, read_data); 
        assert (read_data == 'h1) else $error(""); // empty

        @(posedge app_clk);
        wr_en   <= 1;
        data_in <= 'hF;
        #100000;
        @(posedge app_clk);
        wr_en   <= 0;

        axi_master_i.read(32'h00, read_data); 
        assert (read_data == 'h2) else $error(""); // full

        axi_master_i.read(32'h14, read_data); 
        assert (read_data == 'hF) else $error("");
        #100

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