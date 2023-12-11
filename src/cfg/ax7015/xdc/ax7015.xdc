set_property -dict { PACKAGE_PIN M6   IOSTANDARD LVCMOS33 } [get_ports { PERST_PCIE }];
set_property PULLUP true [get_ports PERST_PCIE]
set_false_path -from [get_ports PERST_PCIE]

set_property LOC IBUFDS_GTE2_X0Y0 [get_cells REFCLK_PCIE_ibuf_i]
set_property PACKAGE_PIN U9 [get_ports {REFCLK_PCIE_p}]
set_property PACKAGE_PIN V9 [get_ports {REFCLK_PCIE_n}]
create_clock -add -name REFCLK -period 10.00 -waveform {0 5} [get_ports { REFCLK_PCIE_p }];


set_property -dict { PACKAGE_PIN A5   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN A7   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN A6   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN B8   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

set_property PACKAGE_PIN W8 [get_ports {pcie_7x_mgt_rxp[0]}]
set_property PACKAGE_PIN AA7 [get_ports {pcie_7x_mgt_rxp[1]}]

set_property PACKAGE_PIN W4 [get_ports {pcie_7x_mgt_txp[0]}]
set_property PACKAGE_PIN AA3 [get_ports {pcie_7x_mgt_txp[1]}]


set_property PACKAGE_PIN W2 [get_ports {sfp_tx_p}]
set_property PACKAGE_PIN W6 [get_ports {sfp_rx_p}]
set_property -dict { PACKAGE_PIN U1   IOSTANDARD LVCMOS33 } [get_ports { sfp_tx_dis }];
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports { sfp_loss }];
set_property LOC GTPE2_CHANNEL_X0Y3 [get_cells gtpwizard_i/gtwizard_i/inst/gtwizard_i/gt0_gtwizard_i/gtpe2_i]
set_property RXSLIDE_MODE PMA [get_cells -hierarchical -filter {NAME =~ *gtpe2_i}]

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells REFCLK_SFP_ibuf_i]
set_property PACKAGE_PIN U5 [get_ports {REFCLK_SFP_p}]
set_property PACKAGE_PIN V5 [get_ports {REFCLK_SFP_n}]
create_clock -add -name REFCLK -period 8.00 -waveform {0 4} [get_ports { REFCLK_SFP_p }];

#set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks gtpwizard_i/gtwizard_i/inst/gtwizard_init_i/gtwizard_i/gt0_gtwizard_i/gtpe2_i/RXOUTCLK]
#set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks gtpwizard_i/gtwizard_i/inst/gtwizard_init_i/gtwizard_i/gt0_gtwizard_i/gtpe2_i/TXOUTCLK]