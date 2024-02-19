-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     reg
--
-- description:
--
--   This file implements a 32-bit register.
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

--! Entity that describes a 32-bit register
entity reg is
  port(
    clk_i  : in  std_logic;                     --! clk_i - clock signal
    rst_i  : in  std_logic;                     --! rst_i - reset signal
    data_i : in  std_logic_vector(31 downto 0); --! data_i - input data
    data_o : out std_logic_vector(31 downto 0)  --! data_o - output data
);
end reg;

--! @brief Architecture definition of the register
--! @details The output gets updated on every rising edge of the clock signal
architecture arch of reg is
  signal data_out : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
begin
--! data_o becomes the input value after every rising edge
--! rst_i is an asynchronous reset
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      data_out <= (others => '0');
    elsif rising_edge(clk_i) then
      data_out <= data_i;
    end if;
  end process;

  --! Output logic
  data_o <= data_out;
end arch;
