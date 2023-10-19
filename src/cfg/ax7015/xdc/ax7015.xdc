set_property -dict { PACKAGE_PIN M6   IOSTANDARD LVCMOS33 } [get_ports { PERST }];
set_property PULLUP true [get_ports PERST]
set_false_path -from [get_ports PERST]

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells REFCLK_ibuf_i]
set_property PACKAGE_PIN U9 [get_ports {REFCLK_p}]
set_property PACKAGE_PIN V9 [get_ports {REFCLK_n}]
create_clock -add -name REFCLK -period 10.00 -waveform {0 5} [get_ports { REFCLK_p }];


set_property -dict { PACKAGE_PIN A5   IOSTANDARD LVCMOS33 } [get_ports { PL_led }];

set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 } [get_ports { SCK }];
set_property -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33 } [get_ports { CSn }];
set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS33 } [get_ports { MISO[0] }];
set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS33 } [get_ports { MISO[1] }];
set_property -dict { PACKAGE_PIN P2   IOSTANDARD LVCMOS33 } [get_ports { MOSI[0] }];
set_property -dict { PACKAGE_PIN P3   IOSTANDARD LVCMOS33 } [get_ports { MOSI[1] }];

set_property PACKAGE_PIN W8 [get_ports {pcie_7x_mgt_rxp[0]}]
set_property PACKAGE_PIN AA7 [get_ports {pcie_7x_mgt_rxp[1]}]

set_property PACKAGE_PIN W4 [get_ports {pcie_7x_mgt_txp[0]}]
set_property PACKAGE_PIN AA3 [get_ports {pcie_7x_mgt_txp[1]}]