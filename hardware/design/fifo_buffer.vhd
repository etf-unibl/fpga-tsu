-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     fifo_buffer
--
-- description: Logic that implements a 32-bit fifo ring buffer with 32 elements.
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

-------------------------------------------------------
--! @fifo_buffer
--! @brief FIFO ring buffer
-------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Entity consists of the following 2 generics and 10 ports:
entity fifo_buffer is
  generic (
    g_RAM_WIDTH : natural := 32; --! The width of every memory slot in bits
    g_RAM_DEPTH : natural := 32  --! The number of memory slots in ram
  );
  port(
    clk_i        : in  std_logic;                                --! Input for clock signal
    rst_i        : in  std_logic;                                --! Asynchronous reset signal
    data_i       : in  std_logic_vector(g_RAM_WIDTH - 1 downto 0); --! Input data
    wren_i       : in  std_logic;                                --! Enable writing into fifo buffer
    rden_i       : in  std_logic;                                --! Enable reading from fifo buffer
    data_o       : out std_logic_vector(g_RAM_WIDTH - 1 downto 0); --! Output data
    rdvalid_o    : out std_logic;                                --! Data valid output
    empty_o      : out std_logic;                                --! Used for signalizing empty buffer
    full_o       : out std_logic;                                --! Used for signalizing full buffer
    fill_count_o : out std_logic_vector(4 downto 0)              --! Number of elements in buffer
  );
end fifo_buffer;

--! Defined array for ram and internal signals inside of architecture
architecture arch of fifo_buffer is
  type ram_type is array (0 to g_RAM_DEPTH - 1) of std_logic_vector(data_i'range);
  signal ram : ram_type;
  subtype t_index_type is integer range ram_type'range;
  signal head : t_index_type;
  signal tail : t_index_type;
  signal data_out_temp : std_logic_vector(g_RAM_WIDTH -1 downto 0) := (others => '0');
  signal empty_temp : std_logic;
  signal full_temp : std_logic;
  signal fill_count_temp : integer range g_RAM_DEPTH - 1 downto 0 := 0;
  signal rdvalid_temp : std_logic := '0';

--! Procedure used for incrementing head/tail of buffer
--! Head/tail wraps around after enough increments
  procedure increment(signal index : inout t_index_type) is
  begin
    if index = t_index_type'high then
      index <= t_index_type'low;
    else
      index <= index + 1;
    end if;
  end procedure increment;

begin
--! Process for incrementing the head and tail of the buffer
--! Head gets incremented if write enable signal is '1' and the buffer is not full
--! Old values get overwritten if write enable signal is '1' and the buffer is full
--! Tail gets incremented when the read enable signal is '1' and the buffer is not empty
--! If the read enable signal is not active, or if the buffer is empty, the read valid signal is not active
--! When an element gets popped from the buffer successfully the read valid signal is active
  increment_head_tail : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      head <= 0;
      tail <= 0;
    elsif rising_edge(clk_i) then
      rdvalid_temp <= '0';
      if wren_i = '1' and full_temp = '0' then
        ram(head) <= data_i;
        increment(head);
      elsif wren_i = '1' and full_temp = '1' then
        ram(head) <= data_i;
        increment(head);
        increment(tail);
      end if;
      if rden_i = '1' and empty_temp = '0' then
        data_out_temp <= ram(tail);
        increment(tail);
        rdvalid_temp <= '1';
      end if;
    end if;
  end process increment_head_tail;
--! Combinational logic
--! Assigned values for empty_o and full_o based on number of elements in buffer
  fill_count_temp <= head - tail + g_RAM_DEPTH when head < tail else head - tail;
  empty_o <= empty_temp;
  full_o <= full_temp;
  fill_count_o <= std_logic_vector(to_unsigned(fill_count_temp, 5));
  data_o <= data_out_temp;
  empty_temp <= '1' when fill_count_temp = 0 else '0';
  full_temp <= '1' when fill_count_temp >= g_RAM_DEPTH - 1 else '0';
  rdvalid_o <= rdvalid_temp;
end arch;
