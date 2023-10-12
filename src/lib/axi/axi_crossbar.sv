`timescale 1ns/1ns

`include "axi4_lite_if.svh"

module axi_crossbar
#(
    parameter N = 10,
    parameter AW = 32,
    parameter DW = 32
)
(    
    input  logic  aclk,
    input  logic  aresetn,
    axi_lite_if.s m,
    axi_lite_if.m s[N]
)
    localparam BASE      = $clog2(N);
    localparam SAW       = AW - BASE;
    localparam PAGE_SIZE = 2 ** AW / N;

    typedef enum  { IDLE, READ, WRITE } state_t;

    state_t state = IDLE, next_state;
    logic [BASE-1:0] id = 0;

    genvar i;
    generate
        for (i=0; i<N; i++) begin 
            assign s[i].awaddr = m.awaddr;
            assign s[i].awprot = m.awprot;
            assign s[i].wdata  = m.wdata;
            assign s[i].wstrb  = m.wstrb;

            assign s[i].araddr = m.araddr;
            assign s[i].arprot = m.arprot;
        end
    endgenerate
    
    assign s[id].awvalid = m.awvalid;
    assign m.awready     = s[id].awready;
    assign s[id].wvalid  = m.wvalid;
    assign m.wready      = s[id].wready;
    assign m.bresp       = s[id].bresp;
    assign m.bvalid      = s[id].bvalid;
    assign s[id].bready  = m.bready;

    assign s[id].arvalid = m.arvalid;
    assign m.arready     = s[id].arready;
    assign m.rresp       = s[id].rresp;
    assign m.rvalid      = s[id].rvalid;
    assign s[id].rready  = m.rready;

    always_ff @( posedge aclk ) begin 
        if(~aresetn) begin
            state <= IDLE;
            id    <= 0;
        end
        else begin
            if(next_state == READ)
                id <= m.araddr[AW-1:SAW-BASE];
            if(next_state == WRITE)
                id <= m.awaddr[AW-1:SAW-BASE];
            state <= next_state;
        end
    end

    always_comb begin 
        case(state)
        IDLE  : next_state = m.arvalid && m.rready ? READ : m.awvalid && m.wvalid ? WRITE : IDLE;
        READ  : next_state = m.rready  && m.rvalid ? IDLE : READ;
        WRITE : next_state = m.bready  && m.bvalid ? IDLE : WRITE;
        endcase;
    end

endmodule;