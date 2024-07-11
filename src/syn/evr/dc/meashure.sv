//------------------------------------------------
//
//      project: llrf-hp
//
//      module:  measure_m
//
//      desc:    Delay measurement module, used to measure delay
//               between two beacon signals. Sampling clock must differ 
//               slightly from beacons clock to achieve nonius effect
//
//------------------------------------------------

`ifndef __MEASURE_SV__
`define __MEASURE_SV__

//------------------------------------------------
`timescale 1ns / 1fs

//------------------------------------------------
module measure_m #(
    parameter DELAY_WIDTH      = 32,
    parameter DELAY_INT_WIDTH  = 16,
    parameter DELAY_FRAC_FAST  = 8,
    parameter DELAY_FRAC_SLOW  = 16
)
(
    input  logic                   clk,
    input  logic                   rst,
    
    input  logic                   beacon_0,
    input  logic                   beacon_1,

    input  logic                   slow,
    
    output logic                   update,
    output logic [DELAY_WIDTH-1:0] delay
);

//------------------------------------------------
//
//      Parameters
//
initial begin
    if (DELAY_INT_WIDTH + DELAY_FRAC_SLOW > DELAY_WIDTH) begin
        $display("DELAY_INT_WIDTH + DELAY_FRAC_SLOW exceeds DELAY_WIDTH");
        $stop();
    end

    if (DELAY_INT_WIDTH + DELAY_FRAC_FAST > DELAY_WIDTH) begin
        $display("DELAY_INT_WIDTH + DELAY_FRAC_FAST exceeds DELAY_WIDTH");
        $stop();
    end
end

//------------------------------------------------
//
//      Types
//
typedef enum
{
    mfsmWAIT,
    mfsmCOUNT,
    mfsmCHECK
} state_t;

typedef logic [DELAY_INT_WIDTH-1:0] sample_t;
typedef logic [    DELAY_WIDTH-1:0] delay_t;

typedef struct packed {
    sample_t in;
    logic    load;
    delay_t  out;
} avg_ctrl_t;

//------------------------------------------------
//
//      Objects
//
state_t     state = mfsmWAIT;

sample_t    cnt   = '0;
sample_t    prev  = '0;
sample_t    res;

logic       valid;

avg_ctrl_t  avg;

//------------------------------------------------
//
//      Logic
//
assign valid = res > prev ? res - prev < sample_t'(3) : prev - res < sample_t'(3);

always_ff @(posedge clk) begin
    if (rst) begin
        state <= mfsmWAIT;
    end
    else begin
        case (state)
            mfsmWAIT: begin 
                cnt       <= '0;
                avg.load  <=  0;
                if (beacon_0)
                    state <= mfsmCOUNT;
            end
            mfsmCOUNT: begin
                cnt <= sample_t'(cnt + 1);
                if (beacon_0) 
                    cnt <= 0;
                else if (beacon_1) begin
                    state <= mfsmCHECK;
                    res   <= cnt;
                end
            end
            mfsmCHECK: begin
                if (slow) begin
                    if (valid) begin
                        avg.load <= 1;
                        prev     <= res;                            
                    end
                end
                else begin
                    avg.load <= 1;
                    prev     <= res;                    
                end
                state <= mfsmWAIT;
            end
        endcase
    end
end

//------------------------------------------------
assign delay  = avg.out;
assign avg.in = res;

always_ff @(posedge clk) update <= avg.load;

//------------------------------------------------
average_m #(
    .IN_WIDTH  ( DELAY_INT_WIDTH ),
    .OUT_WIDTH ( DELAY_WIDTH     ),
    .N_FAST    ( DELAY_FRAC_FAST ),
    .N_SLOW    ( DELAY_FRAC_SLOW )
)
delay_average
(
    .clk       ( clk             ),
    .rst       ( rst             ),
    .slow      ( slow            ),
    .in        ( avg.in          ),
    .load      ( avg.load        ),
    .out       ( avg.out         )
);
//------------------------------------------------
endmodule : measure_m

//------------------------------------------------
//
//                  Testbench
//
//------------------------------------------------

module measure_tb;

//------------------------------------------------
//
//      Parameters
//
localparam CLK_PRD      = 10.0ns;
localparam REFCLK_PRD   = 9.971ns;

localparam DELAY        = 10000ns;

localparam DELAY_WIDTH  = 32;
localparam SAMPLE_WIDTH = 16;

//------------------------------------------------
//
//      Objects
//
logic                   clk      = 0;
logic                   refclk   = 0;
logic                   beacon_0 = 0;
logic                   beacon_1 = 0;
logic [DELAY_WIDTH-1:0] delay;

logic                   beacon_0_sync = 0;
logic                   beacon_1_sync = 0;

logic                   slow     = 0;

int                     timer    = 0;

//------------------------------------------------
//
//      Tasks
//
task automatic beacon(int n);
    
    localparam BEACON_W = 10ns;
    
    case (n)
        0: begin
            beacon_0 = 1;
            #BEACON_W;
            beacon_0 = 0;                    
        end
        1: begin
            beacon_1 = 1;
            #BEACON_W;
            beacon_1 = 0;                    
        end
        default;
    endcase

endtask : beacon

//------------------------------------------------
//
//      Logic
//
always #(CLK_PRD/2)    clk    = ~clk;
always #(REFCLK_PRD/2) refclk = ~refclk;

initial begin
    forever begin
        #10us
        timer++;
        @(posedge clk) begin
            beacon(0);
            //#DELAY
            //beacon(1);
        end
    end
end

always @(*) beacon_1 <= #DELAY beacon_0;

initial begin
    slow = 0;
    #1000us
    slow = 1;
end

always @(delay) $display("time = %f, measured delay = %f", timer/1000000.0, $itor(delay) / $itor(2**16) * REFCLK_PRD);

always @(posedge refclk) begin
    beacon_0_sync <= beacon_0;
    beacon_1_sync <= beacon_1;
end

//------------------------------------------------
//
//      Instances
//
measure_m #(
    .DELAY_WIDTH      ( DELAY_WIDTH  ),
    .DELAY_FRAC_SLOW  ( 14           ),
    .DELAY_FRAC_FAST  ( 8            ),
    .DELAY_INT_WIDTH  ( SAMPLE_WIDTH )
)
measure_dut
(
    .clk              ( refclk        ),
    .rst              ( 0             ),
    .slow             ( slow          ),
    .beacon_0         ( beacon_0_sync ),
    .beacon_1         ( beacon_1_sync ),
    .delay            ( delay         )
);

endmodule : measure_tb

`endif//__MEASURE_SV__