-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     reg_map
--
-- description:
--
--   This file implements a register map of seven 32-bit registers.
-----------------------------------------------------------------------------
-- Copyright (c) 2024 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2024 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--! @reg_map.vhd
--! @brief Register map(file) containing seven 32-bit registers
-----------------------------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Entity that describes the register map
--! There are seven register. sys_time register for storing Unix time, status
--! for status information and interrupt sysbsystem, control for some control
--! flags, and 4 register for storing information about transition of input
--! signal, fall_ts_* when falling edge, and rise_ts_* when rising edge. Sufix h or l
--! denotes if unix time or nanoseconds is store in register
entity reg_map is
  port(
  clk_i           : in   std_logic;                     --! Clock signal
  rst_i           : in   std_logic;                     --! Asynchronous reset

  sys_time_i      : in   std_logic_vector(31 downto 0); --! Input for SYS_TIME r/w register
  status_i        : in   std_logic_vector(31 downto 0); --! Input for STATUS r/w register
  control_i       : in   std_logic_vector(31 downto 0); --! Input for CONTROL r/w register
  fall_ts_h_i     : in   std_logic_vector(31 downto 0); --! Input for FALL_TS_H read only register
  fall_ts_l_i     : in   std_logic_vector(31 downto 0); --! Input for FALL_TS_L read only register
  rise_ts_h_i     : in   std_logic_vector(31 downto 0); --! Input for RISE_TS_H read only register
  rise_ts_l_i     : in   std_logic_vector(31 downto 0); --! Input for RISE_TS_L read only register

  sys_time_o      : out  std_logic_vector(31 downto 0); --! Output for SYS_TIME r/w register
  status_o        : out  std_logic_vector(31 downto 0); --! Output for STATUS r/w register
  control_o       : out  std_logic_vector(31 downto 0); --! Output for CONTROL r/w register
  fall_ts_h_o     : out  std_logic_vector(31 downto 0); --! Output for FALL_TS_H read only register
  fall_ts_l_o     : out  std_logic_vector(31 downto 0); --! Output for FALL_TS_L read only register
  rise_ts_h_o     : out  std_logic_vector(31 downto 0); --! Output for RISE_TS_H read only register
  rise_ts_l_o     : out  std_logic_vector(31 downto 0) --! Output for RISE_TS_L read only register

  );
end reg_map;

--! @brief Architecture definition of the register map
--! @details The output of the 3 registers get updated on every rising edge of the clock signal
architecture arch of reg_map is

  component reg is
    port(
      clk_i  : in std_logic;
      rst_i  : in std_logic;
      data_i : in std_logic_vector(31 downto 0);
      data_o : out std_logic_vector(31 downto 0)
    );
  end component;

begin

  sys_time : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => sys_time_i,
    data_o => sys_time_o
  );

  status : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => status_i,
    data_o => status_o
  );

  control : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => control_i,
    data_o => control_o
  );

  fall_ts_h : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => fall_ts_h_i,
    data_o => fall_ts_h_o
  );

  fall_ts_l : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => fall_ts_l_i,
    data_o => fall_ts_l_o
  );

  rise_ts_h : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => rise_ts_h_i,
    data_o => rise_ts_h_o
  );

  rise_ts_l : reg port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => rise_ts_l_i,
    data_o => rise_ts_l_o
  );

end arch;
