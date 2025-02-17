module mrf_txrxTB();

    logic app_clk = 0;
    logic app_rst;

    logic [15:0] rx_data;
    logic [15:0] tx_data;
    logic [1:0]  rx_charisk;
    logic [1:0]  tx_charisk;

    logic [15:0] mx_data;
    logic [1:0]  mx_charisk;
    logic        mx_ena;
 
    logic [7:0] ev;
    axi4_lite_if #(.AW(32), .DW(32)) mmr1();
    axi4_lite_if #(.AW(32), .DW(32)) mmr2();

    logic [31:0] read_data;

    initial begin
        app_clk = 0;
        forever #5 app_clk = ~app_clk;
    end

    initial begin
        app_rst = 1;
        for(int i =0; i < 10; i++) begin
            @(posedge app_clk);
        end 
        app_rst = 0;
    end 

    simple_parser simple_parser_i(
        .app_clk(app_clk),
        .aresetn(!app_rst),
        .rx_data(rx_data),
        .rx_is_k(rx_charisk),
        .mmr(mmr1)
    );


    simple_generator simple_generator_i(
        .tx_clk(app_clk),
        .app_clk(app_clk),
        .aresetn(!app_rst),
        .tx_data(tx_data),
        .tx_is_k(tx_charisk),
        .mmr(mmr2)
    );


    axi_master mmr1_master(
        .axi(mmr1),
        .aresetn(!app_rst),
        .aclk(app_clk)
    );
    axi_master mmr2_master(
        .axi(mmr2),
        .aresetn(!app_rst),
        .aclk(app_clk)
    );

    assign rx_data    = mx_data;
    assign rx_charisk = mx_charisk;

    always_ff @(posedge app_clk) begin
        mx_data    <= mx_ena ? tx_data    : 0;
        mx_charisk <= mx_ena ? tx_charisk : 0;
    end

    initial begin
        mx_ena <= 1;
        #1000;
        mmr1_master.write(32'h10, 32'hFB); 
        mmr1_master.write(32'h14, 32'hE0);
        mmr2_master.write(32'h10, 32'hFB); 
        mmr2_master.write(32'h14, 32'hE0);
        mmr2_master.write(32'h18, 32'h12345678);
        #1000;
        mmr1_master.read(32'h18, read_data);

        mmr2_master.write(32'h18, 32'h87654321);
        wait(simple_parser_i.mrf_data_recv != 0);
        mx_ena <= 0;
        #100;
        mmr1_master.read(32'h18, read_data);
        mx_ena <= 1;
        mmr2_master.write(32'h18, 32'h87654321);
        #1000;
        mmr1_master.read(32'h18, read_data);

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