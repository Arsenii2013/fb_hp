  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  set GP_CONTROL [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 GP_CONTROL ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {10000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $GP_CONTROL

  set HP0_FIFO_CTRL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_processing_system7:hpstatusctrl_rtl:1.0 HP0_FIFO_CTRL ]

  set HP0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 HP0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {10000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $HP0

  set GP_DATA [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 GP_DATA ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {10000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {8} \
   CONFIG.NUM_WRITE_OUTSTANDING {8} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $GP_DATA


  # Create ports
  set peripheral_reset [ create_bd_port -dir O -from 0 -to 0 -type rst peripheral_reset ]
  set peripheral_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst peripheral_aresetn ]
  set peripheral_clock [ create_bd_port -dir O -type clk peripheral_clock ]
  set app_clk [ create_bd_port -dir I -type clk -freq_hz 10000000 app_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {GP_CONTROL:HP0} \
   CONFIG.ASSOCIATED_RESET {bar_aresetn:app_aresetn} \
 ] $app_clk
  set app_aresetn [ create_bd_port -dir I -type rst app_aresetn ]
  set GPIO_I_0 [ create_bd_port -dir I -from 63 -to 0 GPIO_I_0 ]
  set GPIO_O_0 [ create_bd_port -dir O -from 63 -to 0 GPIO_O_0 ]
  set GPIO_T_0 [ create_bd_port -dir O -from 63 -to 0 GPIO_T_0 ]

  # Create instance: processing_system7, and set properties
  set processing_system7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7 ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
    CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095} \
    CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_APU_CLK_RATIO_ENABLE {21721} \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
    CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
    CONFIG.PCW_CLK0_FREQ {100000000} \
    CONFIG.PCW_CLK1_FREQ {10000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {767} \
    CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
    CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
    CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
    CONFIG.PCW_DM_WIDTH {4} \
    CONFIG.PCW_DQS_WIDTH {4} \
    CONFIG.PCW_DQ_WIDTH {32} \
    CONFIG.PCW_ENET0_BASEADDR {0xE000B000} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
    CONFIG.PCW_ENET0_RESET_ENABLE {1} \
    CONFIG.PCW_ENET0_RESET_IO {MIO 7} \
    CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_ENET_RESET_ENABLE {1} \
    CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
    CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_EN_4K_TIMER {0} \
    CONFIG.PCW_EN_CAN0 {0} \
    CONFIG.PCW_EN_CAN1 {0} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {0} \
    CONFIG.PCW_EN_CLK2_PORT {0} \
    CONFIG.PCW_EN_CLK3_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG0_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG1_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG2_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG3_PORT {0} \
    CONFIG.PCW_EN_DDR {1} \
    CONFIG.PCW_EN_EMIO_CAN0 {0} \
    CONFIG.PCW_EN_EMIO_CAN1 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_ENET0 {0} \
    CONFIG.PCW_EN_EMIO_ENET1 {0} \
    CONFIG.PCW_EN_EMIO_GPIO {1} \
    CONFIG.PCW_EN_EMIO_I2C0 {0} \
    CONFIG.PCW_EN_EMIO_I2C1 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
    CONFIG.PCW_EN_EMIO_PJTAG {0} \
    CONFIG.PCW_EN_EMIO_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_SPI0 {0} \
    CONFIG.PCW_EN_EMIO_SPI1 {0} \
    CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
    CONFIG.PCW_EN_EMIO_TRACE {0} \
    CONFIG.PCW_EN_EMIO_TTC0 {0} \
    CONFIG.PCW_EN_EMIO_TTC1 {0} \
    CONFIG.PCW_EN_EMIO_UART0 {0} \
    CONFIG.PCW_EN_EMIO_UART1 {0} \
    CONFIG.PCW_EN_EMIO_WDT {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
    CONFIG.PCW_EN_ENET0 {1} \
    CONFIG.PCW_EN_ENET1 {0} \
    CONFIG.PCW_EN_GPIO {1} \
    CONFIG.PCW_EN_I2C0 {0} \
    CONFIG.PCW_EN_I2C1 {0} \
    CONFIG.PCW_EN_MODEM_UART0 {0} \
    CONFIG.PCW_EN_MODEM_UART1 {0} \
    CONFIG.PCW_EN_PJTAG {0} \
    CONFIG.PCW_EN_PTP_ENET0 {0} \
    CONFIG.PCW_EN_PTP_ENET1 {0} \
    CONFIG.PCW_EN_QSPI {1} \
    CONFIG.PCW_EN_RST0_PORT {1} \
    CONFIG.PCW_EN_RST1_PORT {0} \
    CONFIG.PCW_EN_RST2_PORT {0} \
    CONFIG.PCW_EN_RST3_PORT {0} \
    CONFIG.PCW_EN_SDIO0 {0} \
    CONFIG.PCW_EN_SDIO1 {0} \
    CONFIG.PCW_EN_SMC {0} \
    CONFIG.PCW_EN_SPI0 {0} \
    CONFIG.PCW_EN_SPI1 {0} \
    CONFIG.PCW_EN_TRACE {0} \
    CONFIG.PCW_EN_TTC0 {0} \
    CONFIG.PCW_EN_TTC1 {0} \
    CONFIG.PCW_EN_UART0 {0} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_EN_USB0 {0} \
    CONFIG.PCW_EN_USB1 {0} \
    CONFIG.PCW_EN_WDT {0} \
    CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {125} \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
    CONFIG.PCW_GP0_EN_MODIFIABLE_TXN {1} \
    CONFIG.PCW_GP0_NUM_READ_THREADS {4} \
    CONFIG.PCW_GP0_NUM_WRITE_THREADS {4} \
    CONFIG.PCW_GP1_EN_MODIFIABLE_TXN {1} \
    CONFIG.PCW_GP1_NUM_READ_THREADS {4} \
    CONFIG.PCW_GP1_NUM_WRITE_THREADS {4} \
    CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
    CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C_RESET_ENABLE {1} \
    CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
    CONFIG.PCW_IMPORT_BOARD_PRESET {None} \
    CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
    CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_0_PULLUP {enabled} \
    CONFIG.PCW_MIO_0_SLEW {slow} \
    CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_10_PULLUP {enabled} \
    CONFIG.PCW_MIO_10_SLEW {slow} \
    CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_11_PULLUP {enabled} \
    CONFIG.PCW_MIO_11_SLEW {slow} \
    CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_12_PULLUP {enabled} \
    CONFIG.PCW_MIO_12_SLEW {slow} \
    CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_13_PULLUP {enabled} \
    CONFIG.PCW_MIO_13_SLEW {slow} \
    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_14_PULLUP {enabled} \
    CONFIG.PCW_MIO_14_SLEW {slow} \
    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_15_PULLUP {enabled} \
    CONFIG.PCW_MIO_15_SLEW {slow} \
    CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_16_PULLUP {enabled} \
    CONFIG.PCW_MIO_16_SLEW {slow} \
    CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_17_PULLUP {enabled} \
    CONFIG.PCW_MIO_17_SLEW {slow} \
    CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_18_PULLUP {enabled} \
    CONFIG.PCW_MIO_18_SLEW {slow} \
    CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_19_PULLUP {enabled} \
    CONFIG.PCW_MIO_19_SLEW {slow} \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_1_PULLUP {enabled} \
    CONFIG.PCW_MIO_1_SLEW {slow} \
    CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_20_PULLUP {enabled} \
    CONFIG.PCW_MIO_20_SLEW {slow} \
    CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_21_PULLUP {enabled} \
    CONFIG.PCW_MIO_21_SLEW {slow} \
    CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_22_PULLUP {enabled} \
    CONFIG.PCW_MIO_22_SLEW {slow} \
    CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_23_PULLUP {enabled} \
    CONFIG.PCW_MIO_23_SLEW {slow} \
    CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_24_PULLUP {enabled} \
    CONFIG.PCW_MIO_24_SLEW {slow} \
    CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_25_PULLUP {enabled} \
    CONFIG.PCW_MIO_25_SLEW {slow} \
    CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_26_PULLUP {enabled} \
    CONFIG.PCW_MIO_26_SLEW {slow} \
    CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_27_PULLUP {enabled} \
    CONFIG.PCW_MIO_27_SLEW {slow} \
    CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_28_PULLUP {enabled} \
    CONFIG.PCW_MIO_28_SLEW {slow} \
    CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_29_PULLUP {enabled} \
    CONFIG.PCW_MIO_29_SLEW {slow} \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_2_SLEW {slow} \
    CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_30_PULLUP {enabled} \
    CONFIG.PCW_MIO_30_SLEW {slow} \
    CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_31_PULLUP {enabled} \
    CONFIG.PCW_MIO_31_SLEW {slow} \
    CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_32_PULLUP {enabled} \
    CONFIG.PCW_MIO_32_SLEW {slow} \
    CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_33_PULLUP {enabled} \
    CONFIG.PCW_MIO_33_SLEW {slow} \
    CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_34_PULLUP {enabled} \
    CONFIG.PCW_MIO_34_SLEW {slow} \
    CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_35_PULLUP {enabled} \
    CONFIG.PCW_MIO_35_SLEW {slow} \
    CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_36_PULLUP {enabled} \
    CONFIG.PCW_MIO_36_SLEW {slow} \
    CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_37_PULLUP {enabled} \
    CONFIG.PCW_MIO_37_SLEW {slow} \
    CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_38_PULLUP {enabled} \
    CONFIG.PCW_MIO_38_SLEW {slow} \
    CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_39_PULLUP {enabled} \
    CONFIG.PCW_MIO_39_SLEW {slow} \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_3_SLEW {slow} \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_40_PULLUP {enabled} \
    CONFIG.PCW_MIO_40_SLEW {slow} \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_41_PULLUP {enabled} \
    CONFIG.PCW_MIO_41_SLEW {slow} \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_42_PULLUP {enabled} \
    CONFIG.PCW_MIO_42_SLEW {slow} \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_43_PULLUP {enabled} \
    CONFIG.PCW_MIO_43_SLEW {slow} \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_44_PULLUP {enabled} \
    CONFIG.PCW_MIO_44_SLEW {slow} \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_45_PULLUP {enabled} \
    CONFIG.PCW_MIO_45_SLEW {slow} \
    CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_46_PULLUP {enabled} \
    CONFIG.PCW_MIO_46_SLEW {slow} \
    CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_47_PULLUP {enabled} \
    CONFIG.PCW_MIO_47_SLEW {slow} \
    CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_48_PULLUP {enabled} \
    CONFIG.PCW_MIO_48_SLEW {slow} \
    CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_49_PULLUP {enabled} \
    CONFIG.PCW_MIO_49_SLEW {slow} \
    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_4_SLEW {slow} \
    CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_50_PULLUP {enabled} \
    CONFIG.PCW_MIO_50_SLEW {slow} \
    CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_51_PULLUP {enabled} \
    CONFIG.PCW_MIO_51_SLEW {slow} \
    CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_52_PULLUP {enabled} \
    CONFIG.PCW_MIO_52_SLEW {slow} \
    CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
    CONFIG.PCW_MIO_53_PULLUP {enabled} \
    CONFIG.PCW_MIO_53_SLEW {slow} \
    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_5_SLEW {slow} \
    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_6_SLEW {slow} \
    CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_7_SLEW {slow} \
    CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_8_SLEW {slow} \
    CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_9_PULLUP {enabled} \
    CONFIG.PCW_MIO_9_SLEW {slow} \
    CONFIG.PCW_MIO_PRIMITIVE {54} \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#ENET Reset#GPIO#GPIO#GPIO#GPIO#UART 1#UART 1#GPIO#GPIO#Enet 0#Enet 0#Enet\
0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#Enet 0#Enet 0} \
    CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#reset#gpio[8]#gpio[9]#gpio[10]#gpio[11]#tx#rx#gpio[14]#gpio[15]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#gpio[28]#gpio[29]#gpio[30]#gpio[31]#gpio[32]#gpio[33]#gpio[34]#gpio[35]#gpio[36]#gpio[37]#gpio[38]#gpio[39]#gpio[40]#gpio[41]#gpio[42]#gpio[43]#gpio[44]#gpio[45]#gpio[46]#gpio[47]#gpio[48]#gpio[49]#gpio[50]#gpio[51]#mdc#mdio}\
\
    CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} \
    CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} \
    CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} \
    CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} \
    CONFIG.PCW_NAND_CYCLES_T_AR {1} \
    CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
    CONFIG.PCW_NAND_CYCLES_T_RC {11} \
    CONFIG.PCW_NAND_CYCLES_T_REA {1} \
    CONFIG.PCW_NAND_CYCLES_T_RR {1} \
    CONFIG.PCW_NAND_CYCLES_T_WC {11} \
    CONFIG.PCW_NAND_CYCLES_T_WP {1} \
    CONFIG.PCW_NOR_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_CS0_T_PC {1} \
    CONFIG.PCW_NOR_CS0_T_RC {11} \
    CONFIG.PCW_NOR_CS0_T_TR {1} \
    CONFIG.PCW_NOR_CS0_T_WC {11} \
    CONFIG.PCW_NOR_CS0_T_WP {1} \
    CONFIG.PCW_NOR_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_CS1_T_PC {1} \
    CONFIG.PCW_NOR_CS1_T_RC {11} \
    CONFIG.PCW_NOR_CS1_T_TR {1} \
    CONFIG.PCW_NOR_CS1_T_WC {11} \
    CONFIG.PCW_NOR_CS1_T_WP {1} \
    CONFIG.PCW_NOR_CS1_WE_TIME {0} \
    CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
    CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.122} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.133} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.134} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.144} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {0.038} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {0.019} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {0.018} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.003} \
    CONFIG.PCW_PACKAGE_NAME {clg485} \
    CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_PERIPHERAL_BOARD_PRESET {None} \
    CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
    CONFIG.PCW_PS7_SI_REV {PRODUCTION} \
    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
    CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
    CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
    CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {0} \
    CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
    CONFIG.PCW_SMC_CYCLE_T0 {NA} \
    CONFIG.PCW_SMC_CYCLE_T1 {NA} \
    CONFIG.PCW_SMC_CYCLE_T2 {NA} \
    CONFIG.PCW_SMC_CYCLE_T3 {NA} \
    CONFIG.PCW_SMC_CYCLE_T4 {NA} \
    CONFIG.PCW_SMC_CYCLE_T5 {NA} \
    CONFIG.PCW_SMC_CYCLE_T6 {NA} \
    CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SMC_PERIPHERAL_VALID {0} \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SPI_PERIPHERAL_VALID {0} \
    CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {32} \
    CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} \
    CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
    CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_UART1_BASEADDR {0xE0001000} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 12 .. 13} \
    CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
    CONFIG.PCW_UIPARAM_DDR_AL {0} \
    CONFIG.PCW_UIPARAM_DDR_BL {8} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {139.2255} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {139.2255} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {139.2255} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {139.2255} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {101.3165} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {120.42} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {121.0875} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {142.1405} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {105.3065} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {126.177} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {129.083} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {148.0365} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
    CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
    CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB_RESET_ENABLE {1} \
    CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
    CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} \
    CONFIG.PCW_USE_AXI_NONSECURE {0} \
    CONFIG.PCW_USE_CORESIGHT {0} \
    CONFIG.PCW_USE_CROSS_TRIGGER {0} \
    CONFIG.PCW_USE_CR_FABRIC {1} \
    CONFIG.PCW_USE_DDR_BYPASS {0} \
    CONFIG.PCW_USE_DEBUG {0} \
    CONFIG.PCW_USE_DMA0 {0} \
    CONFIG.PCW_USE_DMA1 {0} \
    CONFIG.PCW_USE_DMA2 {0} \
    CONFIG.PCW_USE_DMA3 {0} \
    CONFIG.PCW_USE_EXPANDED_IOP {0} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {0} \
    CONFIG.PCW_USE_HIGH_OCM {0} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_M_AXI_GP1 {1} \
    CONFIG.PCW_USE_PROC_EVENT_BUS {0} \
    CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} \
    CONFIG.PCW_USE_S_AXI_ACP {0} \
    CONFIG.PCW_USE_S_AXI_GP0 {0} \
    CONFIG.PCW_USE_S_AXI_GP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_USE_S_AXI_HP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP2 {0} \
    CONFIG.PCW_USE_S_AXI_HP3 {0} \
    CONFIG.PCW_USE_TRACE {0} \
    CONFIG.PCW_VALUE_SILVERSION {3} \
    CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
  ] $processing_system7


  # Create instance: HP0_protocol_convert, and set properties
  set HP0_protocol_convert [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 HP0_protocol_convert ]
  set_property -dict [list \
    CONFIG.MI_PROTOCOL {AXI3} \
    CONFIG.SI_PROTOCOL {AXI4LITE} \
    CONFIG.TRANSLATION_MODE {2} \
  ] $HP0_protocol_convert


  # Create instance: GP0_protocol_convert, and set properties
  set GP0_protocol_convert [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 GP0_protocol_convert ]
  set_property -dict [list \
    CONFIG.MI_PROTOCOL {AXI4LITE} \
    CONFIG.SI_PROTOCOL {AXI3} \
    CONFIG.TRANSLATION_MODE {2} \
  ] $GP0_protocol_convert


  # Create instance: proc_sys_reset, and set properties
  set proc_sys_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset ]

  # Create instance: GP0_protocol_convert1, and set properties
  set GP0_protocol_convert1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 GP0_protocol_convert1 ]
  set_property -dict [list \
    CONFIG.MI_PROTOCOL {AXI4LITE} \
    CONFIG.SI_PROTOCOL {AXI3} \
    CONFIG.TRANSLATION_MODE {2} \
  ] $GP0_protocol_convert1


  # Create interface connections
  connect_bd_intf_net -intf_net GP0_protocol_convert1_M_AXI [get_bd_intf_ports GP_DATA] [get_bd_intf_pins GP0_protocol_convert1/M_AXI]
  connect_bd_intf_net -intf_net GP0_protocol_convert_M_AXI [get_bd_intf_ports GP_CONTROL] [get_bd_intf_pins GP0_protocol_convert/M_AXI]
  connect_bd_intf_net -intf_net HP0_1 [get_bd_intf_ports HP0] [get_bd_intf_pins HP0_protocol_convert/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_HP0_FIFO_CTRL_0_1 [get_bd_intf_ports HP0_FIFO_CTRL] [get_bd_intf_pins processing_system7/S_AXI_HP0_FIFO_CTRL]
  connect_bd_intf_net -intf_net axi_protocol_convert_0_M_AXI [get_bd_intf_pins processing_system7/S_AXI_HP0] [get_bd_intf_pins HP0_protocol_convert/M_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7/M_AXI_GP0] [get_bd_intf_pins GP0_protocol_convert/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_M_AXI_GP1 [get_bd_intf_pins GP0_protocol_convert1/S_AXI] [get_bd_intf_pins processing_system7/M_AXI_GP1]

  # Create port connections
  connect_bd_net -net GPIO_I_0_1 [get_bd_ports GPIO_I_0] [get_bd_pins processing_system7/GPIO_I]
  connect_bd_net -net aresetn_0_1 [get_bd_ports app_aresetn] [get_bd_pins HP0_protocol_convert/aresetn] [get_bd_pins GP0_protocol_convert/aresetn] [get_bd_pins GP0_protocol_convert1/aresetn]
  connect_bd_net -net bar_clk_1 [get_bd_ports app_clk] [get_bd_pins processing_system7/M_AXI_GP0_ACLK] [get_bd_pins processing_system7/S_AXI_HP0_ACLK] [get_bd_pins HP0_protocol_convert/aclk] [get_bd_pins GP0_protocol_convert/aclk] [get_bd_pins processing_system7/M_AXI_GP1_ACLK] [get_bd_pins GP0_protocol_convert1/aclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins proc_sys_reset/peripheral_reset] [get_bd_ports peripheral_reset]
  connect_bd_net -net proc_sys_reset_peripheral_aresetn [get_bd_pins proc_sys_reset/peripheral_aresetn] [get_bd_ports peripheral_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7/FCLK_RESET0_N] [get_bd_pins proc_sys_reset/ext_reset_in]
  connect_bd_net -net processing_system7_FCLK_CLK0 [get_bd_pins processing_system7/FCLK_CLK0] [get_bd_pins proc_sys_reset/slowest_sync_clk] [get_bd_ports peripheral_clock]
  connect_bd_net -net processing_system7_GPIO_O [get_bd_pins processing_system7/GPIO_O] [get_bd_ports GPIO_O_0]
  connect_bd_net -net processing_system7_GPIO_T [get_bd_pins processing_system7/GPIO_T] [get_bd_ports GPIO_T_0]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces processing_system7/Data] [get_bd_addr_segs GP_CONTROL/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces HP0] [get_bd_addr_segs processing_system7/S_AXI_HP0/HP0_DDR_LOWOCM] -force