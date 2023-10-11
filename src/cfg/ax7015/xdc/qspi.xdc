set spi_Tsu  0.924
set spi_Th   0.541
set spi_Tco  6.182

set SCK_delay_max 2.056
set SCK_delay_min 2.056
set CSn_delay_max 2.009
set CSn_delay_min 2.009
set MOSI_delay_max 2.056
set MOSI_delay_min 2.008
set MISO_delay_max 2.295
set MISO_delay_min 2.217

set CSn_max_output_delay  [expr $CSn_delay_max  + $spi_Tsu - $SCK_delay_min]
set CSn_min_output_delay  [expr $CSn_delay_min  - $spi_Th  - $SCK_delay_max]
set MOSI_max_output_delay [expr $MOSI_delay_max + $spi_Tsu - $SCK_delay_min]
set MOSI_min_output_delay [expr $MOSI_delay_min - $spi_Th  - $SCK_delay_max]
set MISO_max_input_delay  [expr $MISO_delay_max + $spi_Tco + $SCK_delay_max]
set MISO_min_input_delay  [expr $MISO_delay_min + $spi_Tco + $SCK_delay_min]

set SCK_OUT {spi|spi_master|hs_spi_master|sck_out|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|muxsel}
create_generated_clock -name SCK   -source [get_pins $SCK_OUT]         [get_ports SCK   ]
create_generated_clock -name SCK_n -source [get_pins $SCK_OUT] -invert [get_ports SCK(n)]

set_output_delay -clock [get_clocks {SCK}] -max $CSn_max_output_delay  [get_ports { CSn*}]
set_output_delay -clock [get_clocks {SCK}] -min $CSn_min_output_delay  [get_ports { CSn*}]
set_output_delay -clock [get_clocks {SCK}] -max $MOSI_max_output_delay [get_ports {MOSI*}]
set_output_delay -clock [get_clocks {SCK}] -min $MOSI_min_output_delay [get_ports {MOSI*}]
set_input_delay  -clock [get_clocks {SCK}] -max $MISO_max_input_delay  [get_ports {MISO*}]
set_input_delay  -clock [get_clocks {SCK}] -min $MISO_min_input_delay  [get_ports {MISO*}]

set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[0]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[0]}] -hold  1
set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[1]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[1]}] -hold  1
set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[2]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[2]}] -hold  1
set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[3]}] -setup 2
#set_multicycle_path -from [get_clocks {SCK}] -to [get_registers {*hs_spi_master*rx_sr[3]}] -hold  1

set_false_path -from {spi_m:spi|hs_spi_master_avmm_m:spi_master|state*} -to {spi_m:spi|mmr.readdata*}
