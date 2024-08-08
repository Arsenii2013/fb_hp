
`include "top.svh"
`include "axi4_lite_if.svh"

module ev_mux(
    input  logic       app_clk,
    input  logic       aresetn,

    axi4_lite_if.s     mmr,
    output logic [7:0] ev,
    input  logic [7:0] ev_mrf,
    input  logic [7:0] ev_soft,
    input  logic [7:0] ev_trigger
);
    localparam EVENTS_N = 32;
//MMR logic 
    typedef logic [MMR_DEV_ADDR_W-1:0] addr_t;
    typedef logic [    MMR_DATA_W-1:0] data_t;

    typedef enum addr_t {
        SR            = addr_t'(8'h00),
        CR            = addr_t'(8'h04),
        CR_S          = addr_t'(8'h08),
        CR_C          = addr_t'(8'h0C),
        SRC           = addr_t'(8'h10)
    } tx_regs;

    typedef struct packed {
        logic none;
    } sr_t;

    typedef struct packed {
        logic none;
    } cr_t;

    sr_t sr;
    cr_t cr;
    logic [1:0]  src = 0;

    logic read;
    logic write_addr;
    logic write_data;
    logic [MMR_DEV_ADDR_W-1:0] addr;
    logic [MMR_DATA_W-1:0] data;

    always_ff @(posedge app_clk) begin
        if (!aresetn) begin
            mmr.arready        <= 0;
            mmr.rvalid         <= 0;
            mmr.awready        <= 0;
            mmr.wready         <= 0;
            mmr.bvalid         <= 0;
            mmr.rresp <= '0;
            mmr.bresp <= '0;
            mmr.rdata <= '0;
            read       <= 0;
            write_addr <= 0;
            write_data <= 0;
            src <= 0;
        end
        else begin
            mmr.arready <= 0;
            if(mmr.arvalid && !read) begin
                addr <= mmr.araddr;
                read <= 1;
                mmr.arready <= 1;
            end 

            mmr.rvalid <= read;
            if(mmr.rready && read) begin
                read <= 0;
                case (addr)
                    SR            : mmr.rdata <= data_t'(sr);
                    CR            : mmr.rdata <= data_t'(cr);
                    SRC           : mmr.rdata <= src;
                    default       : mmr.rdata <= '0;
                endcase 
            end 


            mmr.awready <= 0;
            if(mmr.awvalid && !write_addr) begin
                addr <= mmr.awaddr;
                write_addr  <= 1;
                mmr.awready <= 1;
            end 

            mmr.wready <= 0;
            if(mmr.wvalid && !write_data) begin
                data <= mmr.wdata;
                write_data <= 1;
                mmr.wready <= 1;
            end 

            mmr.bvalid <= write_addr && write_data;
            if(mmr.bready && write_addr && write_data) begin
                write_addr <= 0;
                write_data <= 0;
                case (addr)
                    CR        : cr <= cr_t'(data);
                    CR_S      : cr <= cr | cr_t'(data);
                    CR_C      : cr <= cr & ~(cr_t'(data));
                    SRC       : src <= data;
                    default;
                endcase
            end 
            
        end
    end

    assign ev = src == 'h0 ? ev_mrf : 
                src == 'h1 ? ev_trigger :
                src == 'h2 ? ev_soft : 'h0;
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


module ev_muxTB();

    logic app_clk = 0;    
    logic aresetn = 1;
    initial begin
        app_clk = 0;
        forever #5 app_clk = ~app_clk;
    end

    axi4_lite_if     axi();
    logic [7:0]      ev;

    ev_mux DUT(
        .app_clk(app_clk),
        .aresetn(aresetn),
        .mmr(axi),
        .ev(ev),
        .ev_mrf('h1),
        .ev_trigger('h2),
        .ev_soft('h3)
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

        assert (ev == 'h1) else $error("");

        axi_master_i.write(32'h10, 'h1); 
        assert (ev == 'h2) else $error("");

        axi_master_i.write(32'h10, 'h2); 
        assert (ev == 'h3) else $error("");

        axi_master_i.write(32'h10, 'h3); 
        assert (ev == 'h0) else $error("");

        axi_master_i.write(32'h10, 'h0); 
        assert (ev == 'h1) else $error("");

        #100;
        $stop();
    end

endmodule