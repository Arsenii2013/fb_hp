set_property -dict { PACKAGE_PIN M6   IOSTANDARD LVCMOS33 } [get_ports { PERST }];
set_property PULLUP true [get_ports PERST]
set_false_path -from [get_ports PERST]

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells REFCLK_ibuf_i]
set_property PACKAGE_PIN U9 [get_ports {REFCLK_p}]
set_property PACKAGE_PIN V9 [get_ports {REFCLK_n}]
create_clock -add -name REFCLK -period 10.00 -waveform {0 5} [get_ports { REFCLK_p }];


set_property -dict { PACKAGE_PIN A5   IOSTANDARD LVCMOS33 } [get_ports { PL_led }];
set_property -dict { PACKAGE_PIN A7   IOSTANDARD LVCMOS33 } [get_ports { user_link_up }];
set_property -dict { PACKAGE_PIN A6   IOSTANDARD LVCMOS33 } [get_ports { mmcm_lock }];

set_property PACKAGE_PIN W8 [get_ports {pcie_7x_mgt_rxp}]
set_property PACKAGE_PIN W4 [get_ports {pcie_7x_mgt_txp}]