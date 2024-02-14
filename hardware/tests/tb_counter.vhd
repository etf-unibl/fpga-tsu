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
-- Generated on "02/12/2024 10:01:54"
                                                            
-- Vhdl Test Bench template for design  :  counter
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library design_lib;

ENTITY tb_counter IS
    generic (runner_cfg : string);
END tb_counter;
ARCHITECTURE counter_arch OF tb_counter IS
-- constants                                                 
-- signals                                                   
SIGNAL clk_i : STD_LOGIC;
SIGNAL rst_i : STD_LOGIC;
SIGNAL ts_high_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ts_low_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL value_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	i1 : entity design_lib.counter
	PORT MAP (
-- list connections between master ports and signals
	clk_i => clk_i,
	rst_i => rst_i,
	ts_high_o => ts_high_o,
	ts_low_o => ts_low_o,
	value_i => value_i
	);
process
begin
  for j in 0 to 1000000000 loop
    for i in 0 to 500 loop
      clk_i <= '1';
      wait for 10 ns;
      clk_i <= '0';
      wait for 10 ns;
    end loop;
  end loop;
  wait;
end process;

process
begin
  value_i <= (others => '0');
  wait for 10 ns;
  for i in 10 to 30 loop
    value_i <= std_logic_vector(to_unsigned(i, 32));
	 wait for 20 ns;
    for j in 0 to 20 loop
	   assert (ts_high_o = std_logic_vector(to_unsigned(i, 32))) report "Error ts_high; Expected: " & integer'image(i) & " Actual: " & integer'image(to_integer(unsigned(ts_high_o))) severity failure;
      report "Successful assertion: ts_high";
		wait for 20 ns;
    end loop;
  end loop;
end process;
                                         
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )
-- variable declarations                                      
BEGIN
  test_runner_setup(runner, runner_cfg);
  for j in 0 to 1000 loop
    for i in 0 to 500 loop
      wait for 10 ns;
      assert (ts_low_o = std_logic_vector(to_unsigned(i * 20, 32))) report "Error ts_low; Expected: " & integer'image(i * 20) & " Actual: " & integer'image(to_integer(unsigned(ts_low_o))) severity failure;
      report "Successful assertion: ts_low";
      wait for 10 ns;
	 end loop;
  end loop;
  test_runner_cleanup(runner);
  WAIT;                                                        
END PROCESS always;                                         
END counter_arch;
