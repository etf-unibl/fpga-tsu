-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     output_buffer_logic
--
-- description: This file implements output logic for the fifo buffers.
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
--! @output_buffer_logic.vhd
--! @brief Output buffer logic design
-----------------------------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

entity output_buffer_logic is
  port(
  clk_i   : in  std_logic; --! Clock input
  rst_i   : in  std_logic; --! Asnychronous reset input
  en_i    : in  std_logic; --! Enable input
  empty_i : in  std_logic; --! Input for sensing empty fifo buffer
  read_i  : in  std_logic; --! Avalon read input
  rden_o  : out std_logic  --! Output for enabling reading from fifo buffer
);
end output_buffer_logic;

--! @brief Architecture of output_buffer_logic
--! @details When the first element is written into the fifo buffer
--! it gets popped automatically through this logic
--! Every subsequent reading will pop the next element from the fifo buffer
--! There is an asynchronous reset, and also the logic is reset when the fifo buffer gets empty
architecture arch of output_buffer_logic is
  signal first_write_temp : std_logic := '0';
  signal rden_o_temp : std_logic := '0';
begin
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      first_write_temp <= '0';
      rden_o_temp <= '0';
    elsif rising_edge(clk_i) then
      if empty_i = '1' then
        first_write_temp <= '0';
        rden_o_temp <= '0';
      else
        if first_write_temp = '0' and en_i = '1' then
          first_write_temp <= '1';
          rden_o_temp <= '1';
        elsif first_write_temp = '1' and read_i = '1' then
          rden_o_temp <= '1';
        else
          rden_o_temp <= '0';
        end if;
      end if;
    end if;
  end process;
  rden_o <= rden_o_temp;
end architecture;
