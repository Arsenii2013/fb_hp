
`include "top.svh"
`include "axi4_lite_if.svh"

module event_generator(
    input  logic       app_clk,
    input  logic       aresetn,

    axi4_lite_if.s     mmr,
    output logic [7:0] ev
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
        EV            = addr_t'(8'h10),
        DELAY         = addr_t'(8'h14)
    } tx_regs;

    typedef struct packed {
        logic error;
        logic idle;
    } sr_t;

    typedef struct packed {
        logic cr_repeat;
        logic start;
        logic write;
        logic clear;
    } cr_t;

    sr_t sr;
    cr_t cr;
    logic [7:0]  ev_to_write;
    logic [31:0] delay_to_write;

    logic [7:0]  events[EVENTS_N] = '{default:0};
    logic [31:0] delays[EVENTS_N] = '{default:0};
    logic [$clog2(EVENTS_N) - 1:0] write_ptr = 0;

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
                    EV            : mmr.rdata <= ev_to_write;
                    DELAY         : mmr.rdata <= delay_to_write;
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
                    EV        : ev_to_write <= data;
                    DELAY     : delay_to_write <= data;
                    default;
                endcase
            end 
            
        end
    end


    logic [$clog2(EVENTS_N) - 1:0] read_ptr = 0;
    logic [31:0] cnt = 0;

    always_ff @(posedge app_clk) begin
        if (!aresetn || cr.clear) begin
            events <= '{default:0};
            delays <= '{default:0};
            cr     <= 0;
            cnt    <= 0;
            read_ptr <= 0;
            write_ptr <= 0;
        end else begin
            if(cr.write) begin
                events[write_ptr] <= ev_to_write;
                delays[write_ptr] <= delay_to_write;
                write_ptr += 1;
                cr.write <= 0;
            end

            if(!sr.idle)
                cnt += 1;

            if(read_ptr == 0) begin
                if(cr.start) begin
                    sr.idle  <= 0;
                    cr.start <= 0;
                end
                if(cr.cr_repeat) begin 
                    sr.idle  <= 0;
                end
                if(!cr.start && !cr.cr_repeat) begin
                    sr.idle  <= 1;
                end
            end

            if(cnt >= delays[read_ptr]) begin
                read_ptr += 1;
                ev <= events [read_ptr];
                cnt <= 0;
            end else begin
                ev <= 0;
            end
        end
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


module event_generatorTB();

    logic app_clk = 0;    
    logic aresetn = 1;
    initial begin
        app_clk = 0;
        forever #5 app_clk = ~app_clk;
    end

    axi4_lite_if     axi();
    logic [7:0]      ev;

    event_generator DUT(
        .app_clk(app_clk),
        .aresetn(aresetn),
        .mmr(axi),
        .ev(ev)
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
        assert (read_data == 'h1) else $error(""); 
         

        axi_master_i.write(32'h10, 'h15); 
        axi_master_i.write(32'h14, 10);
        axi_master_i.write(32'h04, 'h2);

        axi_master_i.write(32'h10, 'h16); 
        axi_master_i.write(32'h14, 12);
        axi_master_i.write(32'h04, 'h2);

        axi_master_i.write(32'h10, 'h14); 
        axi_master_i.write(32'h14, 8);
        axi_master_i.write(32'h04, 'h2);


        axi_master_i.write(32'h04, 'h4);


        #100000;

        @(posedge app_clk);
        axi_master_i.write(32'h04, 'h8);
        #100000;

        $stop();
    end

endmodule