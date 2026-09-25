set_clock_groups -exclusive -group [get_clocks {altera_reserved_tck}]

set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports {altera_reserved_tdi}]
set_input_delay  -clock altera_reserved_tck -clock_fall 3 [get_ports {altera_reserved_tms}]
set_output_delay -clock altera_reserved_tck -clock_fall 3 [get_ports {altera_reserved_tdo}]

create_clock -name ipClk_50M -period 20 [get_ports ipClk_50M]

derive_pll_clocks -create_base_clocks -use_net_name
derive_clock_uncertainty

set_false_path -from * -to [get_ports opLED*]
set_false_path -to * -from [get_ports ipSwitch*]
set_false_path -to * -from [get_ports ipnReset*]

create_clock -name opADXL345_SClk -period 200 [get_ports opADXL345_SClk]

set_output_delay -min -clock opADXL345_SClk             -6 [get_ports opADXL345_nCS]
set_output_delay -max -clock opADXL345_SClk              6 [get_ports opADXL345_nCS]
set_output_delay -min -clock opADXL345_SClk -clock_fall -6 [get_ports opADXL345_nCS] -add_delay
set_output_delay -max -clock opADXL345_SClk -clock_fall  6 [get_ports opADXL345_nCS] -add_delay

set_output_delay -min -clock opADXL345_SClk             -6 [get_ports opADXL345_SDI]
set_output_delay -max -clock opADXL345_SClk              6 [get_ports opADXL345_SDI]
set_output_delay -min -clock opADXL345_SClk -clock_fall -6 [get_ports opADXL345_SDI] -add_delay
set_output_delay -max -clock opADXL345_SClk -clock_fall  6 [get_ports opADXL345_SDI] -add_delay

set_input_delay  -min -clock opADXL345_SClk -clock_fall  0 [get_ports ipADXL345_SDO]
set_input_delay  -max -clock opADXL345_SClk -clock_fall 41 [get_ports ipADXL345_SDO]

set_multicycle_path -from [get_clocks opADXL345_SClk] \
                    -to   [get_clocks ipClk_50M] \
                    -setup 10 \

set_multicycle_path -from [get_clocks opADXL345_SClk] \
                    -to   [get_clocks ipClk_50M] \
                    -hold 9

set_multicycle_path -from [get_clocks ipClk_50M] \
                    -to   [get_clocks opADXL345_SClk] \
                    -start -setup 5

set_multicycle_path -from [get_clocks ipClk_50M] \
                    -to   [get_clocks opADXL345_SClk] \
                    -start -hold 4