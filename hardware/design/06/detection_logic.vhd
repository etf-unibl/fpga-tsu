-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     detection_logic
--
-- description:
--
--   This file implements logic for transition detection of the input, as a
--   part of the bigger system that works as a Timestamp Unit
--
-----------------------------------------------------------------------------
-- Copyright (c) 2023 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2023 Faculty of Electrical Engineering
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

--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use integer types
use ieee.numeric_std.all;

--! This is a synchronous design that, as a port, has one-bit input on which digital waveform is brought.
--! There are two output ports. One is 32-bit output that fills timestamp_value register with the value
--! of on the input (0 or 1). The other one is set to one when there is a change
--! on the input that needs to be recognized (0->1 or 1->0).
entity detection_logic is
  port(
    input_i      : in  std_logic;                     --! Input port for the waveform
    clk_i        : in  std_logic;                     --! Clock signal input
    ts_value_o   : out std_logic_vector(31 downto 0); --! Output forwarded to timestamp_value register
    we_o         : out std_logic_vector(31 downto 0)  --! Write Enable Output that lowest bit is set on transition
);
end detection_logic;

--! @brief Architecture with functional definition of detection_logic.
--! @details Architecture is a simple design, where on each clock, based on the current value of the input and
--! the previous one, output 'we' is set to 1 if there is a transition on the input, and to 0 if there is not.
--! The other output is constantly updated based on the current value of the input.
architecture arch of detection_logic is
    --! Definition of signals to be used in the design
  signal current_value : std_logic := '0';
  signal we_temp       : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
begin
  --! Transition detect logic
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if input_i /= current_value then
        we_temp <= "00000000000000000000000000000001";
        current_value <= input_i;
      else
        we_temp <= "00000000000000000000000000000000";
      end if;
    end if;
  end process;

  --! Output logic
  ts_value_o <= "0000000000000000000000000000000" & current_value;
  we_o <= we_temp;
end arch;
