-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     d_ff
--
-- description: This file implements a D flip-flop.
--
--
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
--! @d_ff.vhd
--! @brief D flip-flop design
-----------------------------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

entity d_ff is
  port(
    clk_i  : in  std_logic; --! Clock input
    rst_i  : in  std_logic; --! Asynchronous reset input
    data_i : in  std_logic; --! Data input
    data_o : out std_logic  --! Data output
  );
end d_ff;

--! @brief Architecture of D flip-flop
--! @details Output becomes the current input
--! signal on every rising edge of the clock signal
architecture arch of d_ff is
  signal data_o_temp : std_logic := '0';
begin
--! D flip-flop logic
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      data_o_temp <= '0';
    elsif rising_edge(clk_i) then
      data_o_temp <= data_i;
    end if;
  end process;
  data_o <= data_o_temp;
end arch;
