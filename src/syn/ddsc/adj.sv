`ifndef __ADJ_SV__
`define __ADJ_SV__

module adj_m #(
    parameter DW = 32
)
(
    input  logic          clk,
    input  logic          rst,

    input  logic          sync,
    input  logic [DW-1:0] sync_prd,
    input  logic          start,
    output logic          done,

    input  logic          mode,
    input  logic [DW-1:0] fstart,
    input  logic [DW-1:0] target,
    input  logic [DW-1:0] dt,

    output logic [DW-1:0] out,
    output logic          valid
);

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
//
//      Types
//
typedef logic [DW-1:0] data_t;

typedef enum {
    IDLE,
    CALC_COUNT,
    CALC_INCR,
    ADJ_F,
    ADJ_PH,
    WAIT_SYNC
} state_t;

typedef struct {
    logic  start;
    logic  ready;
    data_t n;
    data_t d;
    data_t q;
    data_t r;
} div_t;

//------------------------------------------------
//
//      Objects
//
state_t state = IDLE, next;

div_t   count_div;
data_t  count;
data_t  cnt = '0;

div_t   incr_div;
logic   sign;
data_t  acc = '0;

//------------------------------------------------
//
//      Logic
//
assign count_div.start = start && state == IDLE;
assign count_div.n     = dt;
assign count_div.d     = sync_prd;
assign count           = count_div.q;

assign incr_div.start  = state == CALC_COUNT && count_div.ready;

always_comb begin
    if (mode == 0) begin
        incr_div.n = (target >= fstart) ? target - fstart : fstart - target;
        incr_div.d = count;
    end
    else begin
        incr_div.n = '0;
        incr_div.d = '0;        
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        valid <= 0;
        done  <= 1;
    end
    else begin
        state <= next;
        case (state)
            IDLE: begin
                valid <= 0;
                done  <= 1;
                if (start) begin
                    sign <= target >= fstart;
                    done <= 0;
                end
            end
            CALC_INCR: begin
                if (incr_div.ready) begin
                    cnt <= '0;
                    acc <= '0;
                    out <= fstart;
                    if (incr_div.q == 0) valid <= 1;
                end
            end
            ADJ_F: begin
                automatic data_t d = incr_div.d;
                automatic data_t q = incr_div.q;
                automatic data_t r = incr_div.r;
                
                valid <= 1;

                acc <= (acc+r < d) ? acc+r : acc+r-d;
                if (sign) out <= (acc+r < d) ? out+q : out+q+1;
                else      out <= (acc+r < d) ? out-q : out-q-1;
                
                cnt <= data_t'(cnt + 1);    
            end
            ADJ_PH: begin
            end
            WAIT_SYNC: begin
                valid <= 0;
            end
        endcase
    end
end

always_comb begin
    if (rst) begin
        next = IDLE;
    end
    else begin
        case(state)
            IDLE:       next = start ? CALC_COUNT : IDLE;
            CALC_COUNT: next = count_div.ready ? CALC_INCR : CALC_COUNT;
            CALC_INCR:  next = incr_div.ready ? (incr_div.q ? ADJ_F : IDLE) : CALC_INCR;
            ADJ_F:      next = WAIT_SYNC;
            ADJ_PH:     next = IDLE;
            WAIT_SYNC:  next = cnt == count ? IDLE : sync ? ADJ_F : WAIT_SYNC;
        endcase
    end
end

//------------------------------------------------
//
//      Instances
//
div_m #(
    .DW    ( DW              )
)
calc_count
(
    .clk   ( clk             ),
    .rst   ( rst             ),
    .start ( count_div.start ),
    .ready ( count_div.ready ),
    .n     ( count_div.n     ),
    .d     ( count_div.d     ),
    .q     ( count_div.q     ),
    .r     ( count_div.r     )
);
//------------------------------------------------
div_m #(
    .DW    ( DW              )
)
calc_incr
(
    .clk   ( clk             ),
    .rst   ( rst             ),
    .start ( incr_div.start  ),
    .ready ( incr_div.ready  ),
    .n     ( incr_div.n      ),
    .d     ( incr_div.d      ),
    .q     ( incr_div.q      ),
    .r     ( incr_div.r      )
);
//------------------------------------------------
endmodule : adj_m

`endif//__ADJ_SV__