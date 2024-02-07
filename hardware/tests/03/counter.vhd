-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "02/05/2024 14:21:04"
                                                            
-- Vhdl Test Bench template for design  :  counter
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
USE ieee.numeric_std.all;                             

ENTITY counter_vhd_tst IS
END counter_vhd_tst;
ARCHITECTURE counter_arch OF counter_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk_i : STD_LOGIC;
SIGNAL rst_i : STD_LOGIC;
SIGNAL ts_high_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ts_low_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
COMPONENT counter
	PORT (
	clk_i : IN STD_LOGIC;
	rst_i : IN STD_LOGIC;
	ts_high_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	ts_low_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : counter
	PORT MAP (
-- list connections between master ports and signals
	clk_i => clk_i,
	rst_i => rst_i,
	ts_high_o => ts_high_o,
	ts_low_o => ts_low_o
	);
process
begin
  for j in 0 to 1000000000 loop
    for i in 0 to 50000000 loop
      clk_i <= '1';
      wait for 10 ns;
      clk_i <= '0';
      wait for 10 ns;
    end loop;
  end loop;
  wait;
end process;
                                         
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )
-- variable declarations                                      
BEGIN                                                         
  for j in 0 to 1000 loop
    for i in 0 to 50000000 loop
      wait for 10 ns;
      assert (ts_low_o = std_logic_vector(to_unsigned(i * 20, 32))) report "Error ts_low; Expected: " & integer'image(i * 20) & " Actual: " & integer'image(to_integer(unsigned(ts_low_o))) severity failure;
      report "Successful assertion: ts_low";
		assert (ts_high_o = std_logic_vector(to_unsigned(j, 32))) report "Error ts_high; Expected: " & integer'image(j) & " Actual: " & integer'image(to_integer(unsigned(ts_high_o))) severity failure;
      report "Successful assertion: ts_high";
      wait for 10 ns;
	 end loop;
  end loop;
WAIT;                                                        
END PROCESS always;                                          
END counter_arch;
