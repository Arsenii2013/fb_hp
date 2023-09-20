# Create interface ports
  set pcie_ext_pipe [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:pcie_ext_pipe_rtl:1.0 pcie_ext_pipe ]

  set pcie_7x_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt ]

  set bar0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 bar0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {10000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $bar0

  set bar1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 bar1 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {10000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $bar1

  set bar2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 bar2 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.FREQ_HZ {10000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $bar2


  # Create ports
  set REFCLK [ create_bd_port -dir I -type clk -freq_hz 100000000 REFCLK ]
  set PERST [ create_bd_port -dir I -type rst PERST ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $PERST
  set m_axi_aclk [ create_bd_port -dir I -type clk -freq_hz 10000000 m_axi_aclk ]
  set m_axi_aresetn [ create_bd_port -dir I -type rst m_axi_aresetn ]

  # Create instance: axi_pcie_0, and set properties
  set axi_pcie_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.9 axi_pcie_0 ]
  set_property -dict [list \
    CONFIG.AXIBAR2PCIEBAR_0 {0x000000} \
    CONFIG.AXIBAR2PCIEBAR_1 {0x100000} \
    CONFIG.AXIBAR2PCIEBAR_2 {0x200000} \
    CONFIG.AXIBAR_NUM {3} \
    CONFIG.BAR1_ENABLED {true} \
    CONFIG.BAR1_SCALE {Kilobytes} \
    CONFIG.BAR1_SIZE {64} \
    CONFIG.BAR1_TYPE {Memory} \
    CONFIG.BAR2_ENABLED {true} \
    CONFIG.BAR2_SCALE {Megabytes} \
    CONFIG.BAR2_SIZE {1} \
    CONFIG.BAR2_TYPE {Memory} \
    CONFIG.DEVICE_ID {0x7022} \
    CONFIG.INCLUDE_BAROFFSET_REG {false} \
    CONFIG.MAX_LINK_SPEED {5.0_GT/s} \
    CONFIG.M_AXI_DATA_WIDTH {64} \
    CONFIG.NO_OF_LANES {X2} \
    CONFIG.PCIEBAR2AXIBAR_0 {0x000000} \
    CONFIG.PCIEBAR2AXIBAR_1 {0x100000} \
    CONFIG.PCIEBAR2AXIBAR_2 {0x200000} \
    CONFIG.S_AXI_DATA_WIDTH {64} \
    CONFIG.S_AXI_SUPPORTS_NARROW_BURST {false} \
    CONFIG.en_ext_pipe_interface {true} \
  ] $axi_pcie_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: axi_protocol_convert_0, and set properties
  set axi_protocol_convert_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_convert_0 ]
  set_property CONFIG.DATA_WIDTH {64} $axi_protocol_convert_0


  # Create instance: axi_clock_converter_0, and set properties
  set axi_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clock_converter_0 ]
  set_property -dict [list \
    CONFIG.ACLK_ASYNC {1} \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.PROTOCOL {AXI4LITE} \
  ] $axi_clock_converter_0


  # Create instance: axi_crossbar_0, and set properties
  set axi_crossbar_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar_0 ]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {64} \
    CONFIG.M00_A00_BASE_ADDR {0x0000000000000000} \
    CONFIG.M01_A00_BASE_ADDR {0x0000000000100000} \
    CONFIG.M02_A00_BASE_ADDR {0x0000000000200000} \
    CONFIG.NUM_MI {3} \
    CONFIG.PROTOCOL {AXI4LITE} \
  ] $axi_crossbar_0


  # Create interface connections
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins axi_clock_converter_0/M_AXI] [get_bd_intf_pins axi_crossbar_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M00_AXI [get_bd_intf_ports bar0] [get_bd_intf_pins axi_crossbar_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M01_AXI [get_bd_intf_ports bar1] [get_bd_intf_pins axi_crossbar_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M02_AXI [get_bd_intf_ports bar2] [get_bd_intf_pins axi_crossbar_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_pcie_0_M_AXI [get_bd_intf_pins axi_pcie_0/M_AXI] [get_bd_intf_pins axi_protocol_convert_0/S_AXI]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_ports pcie_7x_mgt] [get_bd_intf_pins axi_pcie_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net axi_protocol_convert_0_M_AXI [get_bd_intf_pins axi_protocol_convert_0/M_AXI] [get_bd_intf_pins axi_clock_converter_0/S_AXI]
  connect_bd_intf_net -intf_net pcie_ext_pipe_ep_0_1 [get_bd_intf_ports pcie_ext_pipe] [get_bd_intf_pins axi_pcie_0/pcie_ext_pipe_ep]

  # Create port connections
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_pins axi_pcie_0/axi_aclk_out] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins axi_protocol_convert_0/aclk] [get_bd_pins axi_clock_converter_0/s_axi_aclk]
  connect_bd_net -net clk_100MHz_1 [get_bd_ports REFCLK] [get_bd_pins axi_pcie_0/REFCLK]
  connect_bd_net -net m_axi_aclk_0_1 [get_bd_ports m_axi_aclk] [get_bd_pins axi_clock_converter_0/m_axi_aclk] [get_bd_pins axi_crossbar_0/aclk]
  connect_bd_net -net m_axi_aresetn_0_1 [get_bd_ports m_axi_aresetn] [get_bd_pins axi_clock_converter_0/m_axi_aresetn] [get_bd_pins axi_crossbar_0/aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_protocol_convert_0/aresetn] [get_bd_pins axi_clock_converter_0/s_axi_aresetn] [get_bd_pins axi_pcie_0/axi_aresetn]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports PERST] [get_bd_pins proc_sys_reset_0/ext_reset_in]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00100000 -target_address_space [get_bd_addr_spaces axi_pcie_0/M_AXI] [get_bd_addr_segs bar0/Reg] -force
  assign_bd_address -offset 0x00100000 -range 0x00100000 -target_address_space [get_bd_addr_spaces axi_pcie_0/M_AXI] [get_bd_addr_segs bar1/Reg] -force
  assign_bd_address -offset 0x00200000 -range 0x00100000 -target_address_space [get_bd_addr_spaces axi_pcie_0/M_AXI] [get_bd_addr_segs bar2/Reg] -force
