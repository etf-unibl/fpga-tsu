-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     counter
--
-- description:
--
--   This file implements two 32-bit counters. One for UNIX time, the other
--   for number of nanoseconds.
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
--! @counter.vhd
--! @brief 2 32-bit counters, one for Unix time, the other for number of nanoseconds
-------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric elements
use ieee.numeric_std.all;

--! Entity that describes the inputs and output of the counter
--! Essentially, there are 2 counters:
--! One that counts the number of nanoseconds
--! The other counts Unix time based on those nanoseconds
entity counter is
  port(
    rst_i                : in  std_logic;                     --! Asynchronous reset input
    clk_i                : in  std_logic;                     --! Clock signal input
    unix_start_value_i   : in  std_logic_vector(31 downto 0); --! Value to be written into the UNIX counter
    ts_high_o            : out std_logic_vector(31 downto 0); --! Output for Unix counter
    ts_low_o             : out std_logic_vector(31 downto 0)  --! Output for nanoseconds timer
);
end counter;

--! @brief Architecture definition of the counter
--! @details The frequency of the clock signal is defined as 50MHz
--! Based on that, the step increment for time is 20ns, or the period
--! of the clock signal. The nanosecond counter increments itself
--! by 20 every clock cycle. When it reaches 1000000000, one second
--! has passed in real time, and the Unix counter gets incremented
--! by one, and the nanoseconds counter gets reset
architecture arch of counter is
--! Definition of signals to be used in the design
  signal ts_low_temp  : unsigned(31 downto 0) := (others => '0');
  signal ts_high_temp : unsigned(31 downto 0) := (others => '0');
  signal prev_unix_value   : std_logic_vector(31 downto 0) := (others => '0');
begin
  increment_nanotime : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      ts_low_temp <= (others => '0');
      ts_high_temp <= (others => '0');
    elsif rising_edge(clk_i) then
      ts_low_temp <= ts_low_temp + 20;
      if ts_low_temp = "00111011100110101100101000000000" then
        ts_high_temp <= ts_high_temp + 1;
        ts_low_temp <= (others => '0');
      end if;
      if prev_unix_value /= unix_start_value_i then
        ts_high_temp <= unsigned(unix_start_value_i);
		ts_low_temp <= (others => '0');
      end if;
      prev_unix_value <= unix_start_value_i;
    end if;
  end process increment_nanotime;
--! Combinational logic for assignment of outputs
  ts_low_o  <= std_logic_vector(ts_low_temp);
  ts_high_o <= std_logic_vector(ts_high_temp);
end arch;
