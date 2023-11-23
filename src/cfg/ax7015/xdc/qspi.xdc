set spi_Tsu  0.924
set spi_Th   0
set spi_Tco  8.182

set SCK_delay_max 1.5
set SCK_delay_min 1.5
set CSn_delay_max 1.5
set CSn_delay_min 1.5
set MOSI_delay_max 1.5
set MOSI_delay_min 1.5
set MISO_delay_max 1.5
set MISO_delay_min 1.5

set CSn_max_output_delay  [expr $CSn_delay_max  + $spi_Tsu - $SCK_delay_min]
set CSn_min_output_delay  [expr $CSn_delay_min  - $spi_Th  - $SCK_delay_max]
set MOSI_max_output_delay [expr $MOSI_delay_max + $spi_Tsu - $SCK_delay_min]
set MOSI_min_output_delay [expr $MOSI_delay_min - $spi_Th  - $SCK_delay_max]
set MISO_max_input_delay  [expr $MISO_delay_max + $spi_Tco + $SCK_delay_max]
set MISO_min_input_delay  [expr $MISO_delay_min + $spi_Tco + $SCK_delay_min]

set SCK_OUT {qspi_wrapper_i/hs_spi_m/hs_spi_master_m/hs_spi_master/SCK_OUT/C}
create_generated_clock -name SCK  -multiply_by 1  -source [get_pins $SCK_OUT] [get_ports SCK   ]
#create_generated_clock -name SCK_n -source [get_pins $SCK_OUT] -invert [get_ports SCK(n)]

set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 } [get_ports { SCK }];
set_property -dict { PACKAGE_PIN Y13  IOSTANDARD LVCMOS33 } [get_ports { CSn }];
set_property -dict { PACKAGE_PIN P2   IOSTANDARD LVCMOS33 } [get_ports { MISO[0] }];
set_property -dict { PACKAGE_PIN R7   IOSTANDARD LVCMOS33 } [get_ports { MISO[1] }];
set_property -dict { PACKAGE_PIN P8   IOSTANDARD LVCMOS33 } [get_ports { MOSI[0] }];
set_property -dict { PACKAGE_PIN R2   IOSTANDARD LVCMOS33 } [get_ports { MOSI[1] }];

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