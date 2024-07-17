`ifndef __AFE_SVH__
`define __AFE_SVH__

package afe_pkg;

localparam AFE_MEM_SECT_SIZE      = 10'h080;

localparam AFE_SYS_BASE           = 10'h000;
localparam AFE_DDS_BASE           = 10'h080;
localparam AFE_MFM_BASE           = 10'h280;

// common registers
localparam CTRL_REG               = 10'h000;
localparam STATUS_REG             = 10'h040;

// system registers
localparam DDS_ENA                = 10'h004;
localparam PH_ADJ_START           = 10'h008;
localparam CLK_SYNC_CTRL_REG      = 10'h00C;
localparam JC_STATUS              = 10'h044;
localparam CLK_SYNC_RES_REG       = 10'h048;
localparam CLK_SYNC_RES           = 10'h04C;

// dds registers
localparam DDS_FREQ               = 10'h004;
localparam PH_ADJ_DESIRED_PHASE   = 10'h008;
localparam PH_ADJ_PRE_DELAY_TIME  = 10'h00C;
localparam PH_ADJ_WORK_TIME       = 10'h010;
localparam PH_ADJ_POST_DELAY_TIME = 10'h014;
localparam INIT_PHASE             = 10'h018;
localparam PHASE                  = 10'h044;
localparam DDS_FREQ_CURRENT       = 10'h048;

// mfm registers
localparam MF_ANA_I_HI            = 10'h044;
localparam MF_ANA_I_LOW           = 10'h048;
localparam MF_DIG_I_HI            = 10'h04C;
localparam MF_DIG_I_LOW           = 10'h050;
localparam MF_REF_SIGNAL          = 10'h054;
localparam MF_ZER_SIGNAL          = 10'h058;
localparam ADC_CAL_K              = 10'h05C;
localparam ADC_CAL_OFFSET         = 10'h060;
localparam LAST_CAL_ADC_DATA      = 10'h064;
localparam LAST_ROW_ADC_DATA      = 10'h068;

endpackage : afe_pkg

`endif//__AFE_SVH__