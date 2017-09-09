## Clock signal
set_property PACKAGE_PIN W5 [get_ports mclk]							
	set_property IOSTANDARD LVCMOS33 [get_ports mclk]
    create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10.00} [get_ports mclk]

##Pmod Header JA
##Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
#Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
##Sch name = JA7
### comment out later !!!!!!
set_property PACKAGE_PIN H1 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
#Sch name = JA8
set_property PACKAGE_PIN K2 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
#Sch name = JA9
set_property PACKAGE_PIN H2 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
#Sch name = JA10
set_property PACKAGE_PIN G3 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]


##Pmod Header JB
#Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports spi_cs]					
	set_property IOSTANDARD LVCMOS33 [get_ports spi_cs]
#Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports spi_sdata]					
	set_property IOSTANDARD LVCMOS33 [get_ports spi_sdata]
#Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports spi_sclk]					
	set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]


##Pmod Header JXADC
#Sch name = XA1_P
set_property PACKAGE_PIN J3 [get_ports seg[8]]				
	set_property IOSTANDARD LVCMOS33 [get_ports seg[8]]
#Sch name = XA2_P
set_property PACKAGE_PIN L3 [get_ports seg[7]]				
	set_property IOSTANDARD LVCMOS33 [get_ports seg[7]]
#Sch name = XA3_P
set_property PACKAGE_PIN M2 [get_ports seg[6]]				
	set_property IOSTANDARD LVCMOS33 [get_ports seg[6]]
#Sch name = XA4_P
set_property PACKAGE_PIN N2 [get_ports seg[5]]				
	set_property IOSTANDARD LVCMOS33 [get_ports seg[5]]
#Sch name = XA4_N
set_property PACKAGE_PIN N1 [get_ports {seg[9]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[9]}]


## These additional constraints are recommended by Digilent
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
