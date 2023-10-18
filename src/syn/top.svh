
`ifndef __TOP_SVH__
`define __TOP_SVH__

localparam CLK_PRD         = 10;

//      PCI Express
`define PCIE_PIPE_STACK
localparam PCIE_DATA_W     = 32;

localparam BAR0_ADDR_W     = 16;
localparam BAR0_DATA_W     = PCIE_DATA_W;

localparam BAR1_ADDR_W     = 17;
localparam BAR1_DATA_W     = PCIE_DATA_W;

localparam BAR2_ADDR_W     = 20;
localparam BAR2_DATA_W     = PCIE_DATA_W;

//      Memory mapped registers
localparam MMR_ADDR_W      = BAR0_ADDR_W;
localparam MMR_DATA_W      = 32;
localparam MMR_BASE_ADDR_W = 6;
localparam MMR_DEV_ADDR_W  = MMR_ADDR_W - MMR_BASE_ADDR_W;

localparam MMR_SYS         = '0;
localparam MMR_SCC         = MMR_SYS   + 1;
localparam MMR_MEM         = MMR_SCC   + 1;
localparam MMR_QSPI        = MMR_MEM   + 1;
localparam MMR_DEV_COUNT   = MMR_QSPI + 1;

//      Processing system
localparam GP0_ADDR_W      = 32;
localparam GP0_DATA_W      = 32;

localparam HP0_ADDR_W      = 32;
localparam HP0_DATA_W      = 32;

`endif //__TOP_SVH__