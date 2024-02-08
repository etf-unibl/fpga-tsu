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
-- Generated on "02/05/2024 15:49:16"
                                                            
-- Vhdl Test Bench template for design  :  reg_map
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;                                

ENTITY reg_map_tb IS
END reg_map_tb;

ARCHITECTURE reg_map_arch OF reg_map_tb IS
-- constants                                                 
-- signals                                                   
SIGNAL clk_i : STD_LOGIC;
SIGNAL rst_i :  STD_LOGIC;
SIGNAL ts_high_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ts_high_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ts_low_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ts_low_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL value_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL value_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL we_i    : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL we_o    : STD_LOGIC_VECTOR(31 DOWNTO 0);
COMPONENT reg_map
	PORT (
	clk_i : IN STD_LOGIC;
	rst_i : IN STD_LOGIC;
	ts_high_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	ts_high_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	ts_low_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	ts_low_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	value_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	value_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	we_i      : IN  std_logic_vector(31 downto 0);
	we_o      : OUT  std_logic_vector(31 downto 0)
	);
END COMPONENT;
BEGIN
	i1 : reg_map
	PORT MAP (
-- list connections between master ports and signals
	clk_i => clk_i,
	rst_i => rst_i,
	ts_high_i => ts_high_i,
	ts_high_o => ts_high_o,
	ts_low_i => ts_low_i,
	ts_low_o => ts_low_o,
	value_i => value_i,
	value_o => value_o,
	we_i => we_i,
	we_o => we_o
	);
	
 -- stimulus generator for reset
 rst_i <= '1', '0' after 20 ns;	

process
begin
  for i in 0 to 1000001 loop
    clk_i <= '0';
    wait for 10 ns;
    clk_i <= '1';
    wait for 10 ns;
  end loop;
wait;
end process; 


validation_one_reg: PROCESS                                              
BEGIN          
  ts_high_i <= (others => '0');  
  ts_low_i <= (others => '0'); 

  wait for 40 ns;               

  for i in 0 to 499999 loop
	  ts_high_i <= std_logic_vector(to_unsigned(i, 32));
	  ts_low_i <= std_logic_vector(to_unsigned(i, 32));
	  value_i <= std_logic_vector(to_unsigned(i, 32));
	  we_i <= std_logic_vector(to_unsigned(i, 32));
	  
	  wait for 20 ns;
	  assert (value_o = std_logic_vector(to_unsigned(i, 32))) report "Error value; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(value_o))) severity failure;
	  assert (we_o = std_logic_vector(to_unsigned(i, 32))) report "Error value; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(we_o))) severity failure;
	  
	  wait for 20 ns;
	  assert (ts_high_o = std_logic_vector(to_unsigned(i, 32))) report "Error ts_high; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(ts_high_o))) severity failure;
	  assert (ts_low_o = std_logic_vector(to_unsigned(i, 32))) report "Error ts_low; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(ts_low_o))) severity failure;
  end loop;
  
  report "Test successfully finished.";
WAIT;                                                        
END PROCESS validation_one_reg;

--validation_two_reg : PROCESS                                              
--BEGIN          
--  ts_high_i <= (others => '0');  
--  ts_low_i <= (others => '0'); 
--  value_i <= (others => '0');   
--  we_i <= (others => '0');
--  
--  wait for 40 ns;               
--  for i in 0 to 1000000 loop
--
--	  value_i <= std_logic_vector(to_unsigned(i, 32));
--	  we_i <= std_logic_vector(to_unsigned(i, 32));
--	  
--	  wait for 20 ns;
--	 
--	  assert (value_o = std_logic_vector(to_unsigned(i, 32))) report "Error value; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(value_o))) severity failure;
--	  assert (we_o = std_logic_vector(to_unsigned(i, 32))) report "Error value; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(we_o))) severity failure;
--
--  end loop;
--  
--  report "Test successfully finished.";
--WAIT;                                                        
--END PROCESS validation_two_reg;
                                          
END reg_map_arch;