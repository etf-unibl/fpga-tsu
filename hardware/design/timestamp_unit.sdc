## Generated SDC file "timestamp_unit.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"

## DATE    "Tue Mar 05 12:45:52 2024"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name clk_i -period 20.000 [get_ports {clk_i}]
create_clock -name clk_i_virt -period 20.000


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty 


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock clk_i_virt -max 1.050 [get_ports {data_i}]
set_input_delay -clock clk_i_virt -min 0.850 [get_ports {data_i}]
set_input_delay -clock clk_i_virt -max 1.750 [get_ports {read_i}]
set_input_delay -clock clk_i_virt -min 1.550 [get_ports {read_i}]
set_input_delay -clock clk_i_virt -max 0.550 [get_ports {write_i}]
set_input_delay -clock clk_i_virt -min 0.350 [get_ports {write_i}]
set_input_delay -clock clk_i_virt -max 1.180 [get_ports {address_i[*]}]
set_input_delay -clock clk_i_virt -min 0.980 [get_ports {address_i[*]}]
set_input_delay -clock clk_i_virt -max 1.850 [get_ports {writedata_i[*]}]
set_input_delay -clock clk_i_virt -min 1.650 [get_ports {writedata_i[*]}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock clk_i_virt -max 0.550 [get_ports {readdata_o[*]}]
set_output_delay -clock clk_i_virt -min 0.350 [get_ports {readdata_o[*]}]
set_output_delay -clock clk_i_virt -max 0.550 [get_ports {interrupt_o}]
set_output_delay -clock clk_i_virt -min 0.350 [get_ports {interrupt_o}]
set_output_delay -clock clk_i_virt -max 0.550 [get_ports {response_o[*]}]
set_output_delay -clock clk_i_virt -min 0.350 [get_ports {response_o[*]}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {rst_i}] -to [all_registers]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

set_location_assignment PIN_AC18 -to writedata_i[0]
set_location_assignment PIN_Y17 -to writedata_i[1]
set_location_assignment PIN_AD17 -to writedata_i[2]
set_location_assignment PIN_Y18 -to writedata_i[3]
set_location_assignment PIN_AK16 -to writedata_i[4]
set_location_assignment PIN_AK18 -to writedata_i[5]
set_location_assignment PIN_AK19 -to writedata_i[6]
set_location_assignment PIN_AJ19 -to writedata_i[7]
set_location_assignment PIN_AJ17 -to writedata_i[8]
set_location_assignment PIN_AJ16 -to writedata_i[9]
set_location_assignment PIN_AH18 -to writedata_i[10]
set_location_assignment PIN_AH17 -to writedata_i[11]
set_location_assignment PIN_AG16 -to writedata_i[12]
set_location_assignment PIN_AE16 -to writedata_i[13]
set_location_assignment PIN_AF16 -to writedata_i[14]
set_location_assignment PIN_AG17 -to writedata_i[15]
set_location_assignment PIN_AA18 -to writedata_i[16]
set_location_assignment PIN_AA19 -to writedata_i[17]
set_location_assignment PIN_AE17 -to writedata_i[18]
set_location_assignment PIN_AC20 -to writedata_i[19]
set_location_assignment PIN_AH19 -to writedata_i[20]
set_location_assignment PIN_AJ20 -to writedata_i[21]
set_location_assignment PIN_AH20 -to writedata_i[22]
set_location_assignment PIN_AK21 -to writedata_i[23]
set_location_assignment PIN_AD19 -to writedata_i[24]
set_location_assignment PIN_AD20 -to writedata_i[25]
set_location_assignment PIN_AE18 -to writedata_i[26]
set_location_assignment PIN_AE19 -to writedata_i[27]
set_location_assignment PIN_AF20 -to writedata_i[28]
set_location_assignment PIN_AF21 -to writedata_i[29]
set_location_assignment PIN_AF19 -to writedata_i[30]
set_location_assignment PIN_AG21 -to writedata_i[31]
set_location_assignment PIN_AB17 -to readdata_o[0]
set_location_assignment PIN_AA21 -to readdata_o[1]
set_location_assignment PIN_AB21 -to readdata_o[2]
set_location_assignment PIN_AC23 -to readdata_o[3]
set_location_assignment PIN_AD24 -to readdata_o[4]
set_location_assignment PIN_AE23 -to readdata_o[5]
set_location_assignment PIN_AE24 -to readdata_o[6]
set_location_assignment PIN_AF25 -to readdata_o[7]
set_location_assignment PIN_AF26 -to readdata_o[8]
set_location_assignment PIN_AG25 -to readdata_o[9]
set_location_assignment PIN_AG26 -to readdata_o[10]
set_location_assignment PIN_AH24 -to readdata_o[11]
set_location_assignment PIN_AH27 -to readdata_o[12]
set_location_assignment PIN_AJ27 -to readdata_o[13]
set_location_assignment PIN_AK29 -to readdata_o[14]
set_location_assignment PIN_AK28 -to readdata_o[15]
set_location_assignment PIN_AK27 -to readdata_o[16]
set_location_assignment PIN_AJ26 -to readdata_o[17]
set_location_assignment PIN_AK26 -to readdata_o[18]
set_location_assignment PIN_AH25 -to readdata_o[19]
set_location_assignment PIN_AJ25 -to readdata_o[20]
set_location_assignment PIN_AJ24 -to readdata_o[21]
set_location_assignment PIN_AK24 -to readdata_o[22]
set_location_assignment PIN_AG23 -to readdata_o[23]
set_location_assignment PIN_AK23 -to readdata_o[24]
set_location_assignment PIN_AH23 -to readdata_o[25]
set_location_assignment PIN_AK22 -to readdata_o[26]
set_location_assignment PIN_AJ22 -to readdata_o[27]
set_location_assignment PIN_AH22 -to readdata_o[28]
set_location_assignment PIN_AG22 -to readdata_o[29]
set_location_assignment PIN_AF24 -to readdata_o[30]
set_location_assignment PIN_AF23 -to readdata_o[31]
set_location_assignment PIN_AJ21 -to address_i[3]
set_location_assignment PIN_AG18 -to address_i[2]
set_location_assignment PIN_AG20 -to address_i[1]
set_location_assignment PIN_AF18 -to address_i[0]
set_location_assignment PIN_AC22 -to write_i
set_location_assignment PIN_AA20 -to response_o[0]
set_location_assignment PIN_AD21 -to response_o[1]
set_location_assignment PIN_AE22 -to read_i
set_location_assignment PIN_AF14 -to clk_i
set_location_assignment PIN_AB12 -to rst_i
set_location_assignment PIN_AK3 -to data_i
set_location_assignment PIN_V16 -to interrupt_o