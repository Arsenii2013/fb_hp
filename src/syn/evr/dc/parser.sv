//------------------------------------------------
//
//      project: llrf-hp
//
//      module:  parser_m
//
//      desc:    parse mrf protocol dbus/data slot
//               to obtain link propagation delay
//               value and status and topology ID
//
//------------------------------------------------

`ifndef __PARSER_SV__
`define __PARSER_SV__

//------------------------------------------------
`timescale 1ns / 1ps

//------------------------------------------------
module parser_m
#(
    DELAY_WIDTH = 32
)
(
    input  logic                   clk,
    input  logic                   rst,

    input  logic                   valid,
    input  logic [            7:0] rx_data,
    input  logic                   rx_isk,

    output logic [DELAY_WIDTH-1:0] delay,
    output logic [            2:0] status,
    output logic [           31:0] topoid
);

//------------------------------------------------
//
//      Parameters
//
localparam DC_SEGMENT_ADDR      = 8'hFF;

localparam SEGMENT_BYTES_COUNT  = 16;
localparam CHECKSUM_BYTES_COUNT = 2;

localparam SEGMENT_CNT_WIDTH    = $clog2(SEGMENT_BYTES_COUNT);
localparam CHECKSUM_CNT_WIDTH   = $clog2(CHECKSUM_BYTES_COUNT);

//------------------------------------------------
//
//      Types
//
typedef struct packed {
    logic [31:0] delay;
    logic [31:0] status;
    logic [31:0] reserved;
    logic [31:0] topoid;
} parsed_data_t;

typedef logic [ SEGMENT_BYTES_COUNT-1:0][7:0] mrf_data_t;
typedef logic [   SEGMENT_CNT_WIDTH-1:0]      data_cnt_t;
typedef logic [CHECKSUM_BYTES_COUNT-1:0][7:0] sum_t;
typedef logic [  CHECKSUM_CNT_WIDTH-1:0]      sum_cnt_t;

typedef enum {
    pfsmWAIT,
    pfsmRECV_ADDR,
    pfsmRECV_DATA,
    pfsmRECV_SUM,
    pfsmUPDATE
} state_t;

//------------------------------------------------
//
//      Objects
//
mrf_data_t  mrf_data;
data_cnt_t  data_cnt;

sum_t       calc_sum;
sum_t       recv_sum;
sum_cnt_t   sum_cnt;
logic       sum_valid;

state_t     state = pfsmWAIT;
state_t     next;

logic       start;
logic       stop;

logic       dbus;

//------------------------------------------------
//
//      Logic
//
assign start = valid ? rx_isk && rx_data == 8'h5C : 0;
assign stop  = valid ? rx_isk && rx_data == 8'h3C : 0;

always_ff @(posedge clk) begin
    if (rst) begin
        state  <=  pfsmWAIT;
        delay  <= '0;
        status <= '0;
        topoid <= '0;
    end
    else begin

        if (state != pfsmWAIT) dbus <= ~dbus;
        
        state <= next;
        case (state)
            pfsmWAIT: begin
                if (start) begin
                    data_cnt <= data_cnt_t'(SEGMENT_BYTES_COUNT - 1);
                    sum_cnt  <= sum_cnt_t'(CHECKSUM_BYTES_COUNT - 1);
                    calc_sum <= '1;
                    dbus     <=  1;
                end
            end
            pfsmRECV_ADDR: begin
                if (!dbus) begin
                    calc_sum <= sum_t'(calc_sum - rx_data);
                end
            end
            pfsmRECV_DATA: begin
                if (!dbus && !stop) begin
                    mrf_data[data_cnt] <= rx_data;
                    calc_sum <= sum_t'(calc_sum - rx_data);
                    data_cnt <= data_cnt_t'(data_cnt - 1);
                end
            end
            pfsmRECV_SUM: begin
                if (!dbus) begin
                    recv_sum[sum_cnt] <= rx_data;
                    sum_cnt <= sum_cnt_t'(sum_cnt - 1);                            
                end
            end
            pfsmUPDATE: begin
                if (calc_sum == recv_sum) begin
                    automatic parsed_data_t parsed_data = parsed_data_t'(mrf_data);
                    delay  <= parsed_data.delay;
                    status <= parsed_data.status[2:0];
                    topoid <= parsed_data.topoid;
                end        
            end
            default;
        endcase
    end   
end

always_comb begin
    case (state)
        pfsmWAIT:      next = start ? pfsmRECV_ADDR : pfsmWAIT;
        pfsmRECV_ADDR: begin
            if (!dbus) next = rx_data == DC_SEGMENT_ADDR ? pfsmRECV_DATA : pfsmWAIT;
            else       next = pfsmRECV_ADDR;
        end
        pfsmRECV_DATA: begin
            if (!dbus) next = stop ? pfsmRECV_SUM : pfsmRECV_DATA;
            else       next = pfsmRECV_DATA;
        end
        pfsmRECV_SUM:  begin
            if (!dbus) next = sum_cnt == '0 ? pfsmUPDATE : pfsmRECV_SUM;
            else       next = pfsmRECV_SUM;
        end
        default:       next = pfsmWAIT;
    endcase
end

//------------------------------------------------
endmodule : parser_m

`endif//__PARSER_SV__