`ifndef __DDSC_IF_SV__
`define __DDSC_IF_SV__

interface ddsc_if #(
    parameter DW = 32
);

logic          tx_valid;
logic          rx_ready;
logic [DW-1:0] f;

modport out
(
    output tx_valid,
    input  rx_ready,
    output f
);
    
modport in
(
    input  tx_valid,
    output rx_ready,
    input  f
);

endinterface : ddsc_if

`endif//__DDSC_IF_SV__