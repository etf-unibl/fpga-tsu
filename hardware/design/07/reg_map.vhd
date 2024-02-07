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
--   This file implements a register map of 3 32-bit registers.
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

-------------------------------------------------------
--! @reg.vhd
--! @brief 32-bit register
-------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Entity that describes the register map
--! There are 3 registers for the value of the input signal,
--! and for the 2 counters in the design
entity reg_map is
  port(
  clk_i     : in  std_logic;                     --! clk_i - clock signal
  rst_i     : in  std_logic;                     --! rst_i - asynchronous reset
  value_i   : in  std_logic_vector(31 downto 0); --! value_i - input for value register
  ts_high_i : in  std_logic_vector(31 downto 0); --! ts_high_i - input for Unix counter register
  ts_low_i  : in  std_logic_vector(31 downto 0); --! ts_low_i - input for nanoseconds counter register
  value_o   : out std_logic_vector(31 downto 0); --! value_o - output for value register
  ts_high_o : out std_logic_vector(31 downto 0); --! ts_high_o - output for Unix counter register
  ts_low_o  : out std_logic_vector(31 downto 0)  --! ts_low_o - output for nanoseconds counter register
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
  reg1 : reg port map(
  clk_i  => clk_i,
  rst_i  => rst_i,
  data_i => value_i,
  data_o => value_o
  );
  reg2 : reg port map(
  clk_i  => clk_i,
  rst_i  => rst_i,
  data_i => ts_high_i,
  data_o => ts_high_o
  );
  reg3 : reg port map(
  clk_i  => clk_i,
  rst_i  => rst_i,
  data_i => ts_low_i,
  data_o => ts_low_o
  );
end arch;