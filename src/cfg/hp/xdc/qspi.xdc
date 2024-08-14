set spi_Tsu  0.924
set spi_Th   0.541
set spi_Tco  6.182

set SCK_delay_max 2.056
set SCK_delay_min 2.056
set CSn_delay_max 2.056
set CSn_delay_min 2.056
set MOSI_delay_max 2.056
set MOSI_delay_min 2.056
set MISO_delay_max 2.256
set MISO_delay_min 2.256

set CSn_max_output_delay  [expr $CSn_delay_max  + $spi_Tsu - $SCK_delay_min]
set CSn_min_output_delay  [expr $CSn_delay_min  - $spi_Th  - $SCK_delay_max]
set MOSI_max_output_delay [expr $MOSI_delay_max + $spi_Tsu - $SCK_delay_min]
set MOSI_min_output_delay [expr $MOSI_delay_min - $spi_Th  - $SCK_delay_max]
set MISO_max_input_delay  [expr $MISO_delay_max + $spi_Tco + $SCK_delay_max]
set MISO_min_input_delay  [expr $MISO_delay_min + $spi_Tco + $SCK_delay_min]

set SCK_OUT {qspi_wrapper_i/hs_spi_m/hs_spi_master_m/hs_spi_master/SCK_OUT/C}
create_generated_clock -name SCK  -multiply_by 1  -source [get_pins $SCK_OUT] [get_ports SCK_p  ]
#create_generated_clock -name SCK_n -source [get_pins $SCK_OUT] -invert [get_ports SCK(n)]

set_property -dict { IOSTANDARD LVDS_25 } [get_ports { SCK_p }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { CSn_p }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MISO_p[0] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MISO_p[1] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MISO_p[2] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MISO_p[3] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MOSI_p[0] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MOSI_p[1] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MOSI_p[2] }];
set_property -dict { IOSTANDARD LVDS_25 } [get_ports { MOSI_p[3] }];


set_property PACKAGE_PIN F7 [get_ports {SCK_p}]
set_property PACKAGE_PIN E7 [get_ports {SCK_n}]
set_property PACKAGE_PIN D3 [get_ports {CSn_p}]
set_property PACKAGE_PIN C3 [get_ports {CSn_n}]

set_property PACKAGE_PIN A5 [get_ports {MISO_p[0]}]
set_property PACKAGE_PIN A4 [get_ports {MISO_n[0]}]
set_property PACKAGE_PIN B4 [get_ports {MISO_p[1]}]
set_property PACKAGE_PIN B3 [get_ports {MISO_n[1]}]
set_property PACKAGE_PIN A2 [get_ports {MISO_p[2]}]
set_property PACKAGE_PIN A1 [get_ports {MISO_n[2]}]
set_property PACKAGE_PIN B2 [get_ports {MISO_p[3]}]
set_property PACKAGE_PIN B1 [get_ports {MISO_n[3]}]


set_property PACKAGE_PIN D5 [get_ports {MOSI_p[0]}]
set_property PACKAGE_PIN C4 [get_ports {MOSI_n[0]}]
set_property PACKAGE_PIN C6 [get_ports {MOSI_p[1]}]
set_property PACKAGE_PIN C5 [get_ports {MOSI_n[1]}]
set_property PACKAGE_PIN E8 [get_ports {MOSI_p[2]}]
set_property PACKAGE_PIN D8 [get_ports {MOSI_n[2]}]
set_property PACKAGE_PIN B7 [get_ports {MOSI_p[3]}]
set_property PACKAGE_PIN B6 [get_ports {MOSI_n[3]}]

set_output_delay -clock [get_clocks {SCK}] -max $CSn_max_output_delay  [get_ports { CSn*}]
set_output_delay -clock [get_clocks {SCK}] -min $CSn_min_output_delay  [get_ports { CSn*}]
set_output_delay -clock [get_clocks {SCK}] -max $MOSI_max_output_delay [get_ports {MOSI*}]
set_output_delay -clock [get_clocks {SCK}] -min $MOSI_min_output_delay [get_ports {MOSI*}]
set_input_delay  -clock [get_clocks {SCK}] -max $MISO_max_input_delay  [get_ports {MISO*}]
set_input_delay  -clock [get_clocks {SCK}] -min $MISO_min_input_delay  [get_ports {MISO*}]

set_multicycle_path -from [get_clocks {SCK}] -to [get_cells {qspi_wrapper_i/hs_spi_m/hs_spi_master_m/hs_spi_master/rx_sr_reg[0]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[0]}] -hold  1
set_multicycle_path -from [get_clocks {SCK}] -to [get_cells {qspi_wrapper_i/hs_spi_m/hs_spi_master_m/hs_spi_master/rx_sr_reg[1]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[1]}] -hold  1
set_multicycle_path -from [get_clocks {SCK}] -to [get_cells {qspi_wrapper_i/hs_spi_m/hs_spi_master_m/hs_spi_master/rx_sr_reg[2]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[2]}] -hold  1
set_multicycle_path -from [get_clocks {SCK}] -to [get_cells {qspi_wrapper_i/hs_spi_m/hs_spi_master_m/hs_spi_master/rx_sr_reg[3]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[3]}] -hold  1

#set_false_path -from {spi_m:spi|hs_spi_master_avmm_m:spi_master|state*} -to {spi_m:spi|mmr.readdata*}

set_property IOB TRUE [get_ports {MOSI*}]
set_property IOB TRUE [get_ports {MISO*}]
set_property IOB TRUE [get_ports { CSn*}]

set_property DIFF_TERM         TRUE [get_ports {MISO*}]