set_property -dict { PACKAGE_PIN M6   IOSTANDARD LVCMOS33 } [get_ports { PERST }];
set_property PULLUP true [get_ports PERST]
set_false_path -from [get_ports PERST]

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells REFCLK_ibuf_i]
set_property PACKAGE_PIN U9 [get_ports {REFCLK_p}]
set_property PACKAGE_PIN V9 [get_ports {REFCLK_n}]
create_clock -add -name REFCLK -period 8.00 -waveform {0 4} [get_ports { REFCLK_p }];
