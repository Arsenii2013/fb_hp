
`ifndef __TOP_SVH__
`define __TOP_SVH__

//      Common
localparam CLK_PRD         = 10;
localparam SYNC_PRD_DEF    = 1000;
localparam FB_DW           = 32;
localparam EMIO_SIZE       = 64;


//      PCI Express
localparam PCIE_LANE       = 1;
`define PCIE_PIPE_STACK
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
localparam MMR_IC          = MMR_SCC   + 1;
localparam MMR_EVR         = MMR_IC    + 1;
localparam MMR_EVMUX       = MMR_EVR   + 1;
localparam MMR_MEM         = MMR_EVMUX + 1;
localparam MMR_QSPI        = MMR_MEM   + 1;
localparam MMR_LOG         = MMR_QSPI  + 1;
localparam MMR_TX          = MMR_LOG   + 1;
localparam MMR_SHARED      = MMR_TX    + 1;
localparam MMR_DEV_COUNT   = MMR_SHARED+ 1;

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
localparam SHARED_MEM_COUNT    = 1;

//      DDS/RIO/MFM controller tables
localparam TBL_ADDR_W      = BAR1_ADDR_W;
localparam TBL_DATA_W      = BAR1_DATA_W;
localparam TBL_BASE_ADDR_W = 4;
localparam TBL_MEM_ADDR_W  = TBL_ADDR_W - TBL_BASE_ADDR_W;

localparam RIOC_CONV        = '0;
localparam RIOC_DESC        = RIOC_CONV  + 1;
localparam MFMC_CONV        = RIOC_DESC  + 1;
localparam MFMC_DESC        = MFMC_CONV  + 1;
localparam DDSC0_CONV       = MFMC_DESC  + 1;
localparam DDSC0_DESC       = DDSC0_CONV + 1;
localparam DDSC1_CONV       = DDSC0_DESC + 1;
localparam DDSC1_DESC       = DDSC1_CONV + 1;
localparam DDSC2_CONV       = DDSC1_DESC + 1;
localparam DDSC2_DESC       = DDSC2_CONV + 1;
localparam DDSC3_CONV       = DDSC2_DESC + 1;
localparam DDSC3_DESC       = DDSC3_CONV + 1;
localparam TBL_COUNT        = DDSC3_DESC + 1;

//      Descriptors and events
localparam DESC_ITEM_DW    = 32;
localparam DESC_ITEM_COUNT = 16;

localparam EV_W            = 8;

//      Magnetic field parameters
localparam B_FIELD_W       = 32;

`endif //__TOP_SVH__