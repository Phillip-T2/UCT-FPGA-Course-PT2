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
					
#-------------------------------------------------------------------------------
create_generated_clock -source [get_pins { SDRAM_PLL_Inst|altpll_component|auto_generated|pll1|clk[1] } ] \
                       -name opClk_SDRAM [get_ports opClk_SDRAM]

# Page 19 in the datasheet

# Suppose +- 100 ps skew
# max: t_AC (External Device) + Board Delay (Clock) + Board Delay (Data)
# min: t_OH (External Device) + Board Delay (Clock) + Board Delay (Data)
# max 5.4(max) +0.4(trace delay) +0.1 = 5.9
# min 2.7(min) +0.4(trace delay) -0.1 = 3.0

set_input_delay -max -clock opClk_SDRAM 5.9 [get_ports bpSDRAM*]
set_input_delay -min -clock opClk_SDRAM 3.0 [get_ports bpSDRAM*]

# shift-window (clk[0] is also 100 MHz, but with -90 deg phase shift)

set_multicycle_path -from [get_clocks opClk_SDRAM] \
                    -to   [get_clocks SDRAM_PLL:SDRAM_PLL_Inst|altpll:altpll_component|SDRAM_PLL_altpll:auto_generated|wire_pll1_clk[0] ] \
                    -setup 2

# Suppose +- 100 ps skew
# max : Board Delay (Data) - Board Delay (Clock) + t_DS (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - t_DH (External Device)
# max  1.5 +0.1 =  1.6
# min -0.8 -0.1 = -0.9

set_output_delay -max -clock opClk_SDRAM  1.6 [get_ports { bpSDRAM* opSDRAM* }]
set_output_delay -min -clock opClk_SDRAM -0.9 [get_ports { bpSDRAM* opSDRAM* }]

set_false_path -from * -to [get_ports opReadData*]
#-------------------------------------------------------------------------------