
`ifndef __TOP_SVH__
`define __TOP_SVH__

//      Common
localparam CLK_PRD         = 10;
localparam SYNC_PRD_DEF    = 1000;
localparam FB_DW           = 32;


//      PCI Express
//`define PCIE_PIPE_STACK
localparam PCIE_DATA_W     = 32;

localparam BAR0_ADDR_W     = 16;
localparam BAR0_DATA_W     = PCIE_DATA_W;

localparam BAR1_ADDR_W     = 17;
localparam BAR1_DATA_W     = PCIE_DATA_W;

localparam BAR2_ADDR_W     = 20;
localparam BAR2_DATA_W     = PCIE_DATA_W;


//      MGT transciever
`define MGT_FULL_STACK

`ifdef SYNTHESIS
`define MGT_FULL_STACK
`endif //SYNTHESIS

//      Memory mapped registers
localparam MMR_ADDR_W      = BAR0_ADDR_W;
localparam MMR_DATA_W      = 32;
localparam MMR_BASE_ADDR_W = 6;
localparam MMR_DEV_ADDR_W  = MMR_ADDR_W - MMR_BASE_ADDR_W;

localparam MMR_SYS         = '0;
localparam MMR_SCC         = MMR_SYS   + 1;
localparam MMR_MEM         = MMR_SCC   + 1;
localparam MMR_QSPI        = MMR_MEM   + 1;
localparam MMR_DEV_COUNT   = MMR_QSPI  + 1;

//      Processing system
localparam GP0_ADDR_W      = 32;
localparam GP0_DATA_W      = 32;

localparam HP0_ADDR_W      = 32;
localparam HP0_DATA_W      = 32;

//      High speed SPI axi wrapper
localparam SPI_W           = 2;
localparam SPI_AXI_AW      = 10;
localparam SPI_AXI_DW      = 32;

//      Shared Memory parameters
localparam SHARED_MEM_SIZE     = 2048;
localparam SHARED_MEM_SEG_SIZE = 16;
localparam SHARED_MEM_AW       = $clog2(SHARED_MEM_SIZE);
localparam SHARED_MEM_SEG_AW   = $clog2(SHARED_MEM_SIZE/SHARED_MEM_SEG_SIZE);
localparam DDSC_COUNT      = 4;

`endif //__TOP_SVH__