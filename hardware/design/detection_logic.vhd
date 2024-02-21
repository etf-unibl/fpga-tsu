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
--   This file implements an detection_logic design for
--   transition detection of input data signal
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
--! @detection_logic.vhd
--! @brief detection_logic design for signal transition detection
-----------------------------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;
--! Use numeric elements
use ieee.numeric_std.all;

--! Entity that describes the inputs and output of the detection_logic unit
--! There is an input data_i single-bit signal which transitions are gonna
--! be detected by this design. Each time transition is detected, 4 outputs
--! fall_tses & rise_tses are gonna be updated according to the exact time
--! when it's happened (both Unix time moment and nanosec time moment).
--! Additionally, there is an input unix_start_value_i as init value for
--! the Unix counter and output unix_time_o as output of the same counter.
entity detection_logic is
  port(
    data_i             : in  std_logic;                     --! Asynchronous data input
    clk_i              : in  std_logic;                     --! Clock signal input
    rst_i              : in  std_logic;                     --! Asynchronous reset input
    unix_start_value_i : in  std_logic_vector(31 downto 0); --! Value to be written into the UNIX counter
    unix_time_o        : out std_logic_vector(31 downto 0); --! Output for Unix counter
    fall_ts_h          : out std_logic_vector(31 downto 0); --! Unix time falling edge of data_i is detected
    fall_ts_l          : out std_logic_vector(31 downto 0); --! ns time falling edge of data_i is detected
    rise_ts_h          : out std_logic_vector(31 downto 0); --! Unix time rising edge of data_i is detected
    rise_ts_l          : out std_logic_vector(31 downto 0)  --! ns time rising edge of data_i is detected
);
end detection_logic;

--! @brief Architecture definition of the detection_logic
--! @details Transitions of the input signal data_i are being listen to. Because the data_i signal
--! can change within a flip-flop's setup and hold times the output may be unusable for various reasons.
--! The flip-flop may or may not have propagated the new value, or perhaps got confused for a while and
--! not settled to any real output value ("metastability"). So we do synchronization with two-stage
--! shift-register that are clocked by the target domain's clock. In this way we get
--! a synchronous version of that asynchronous input signal. Each time transition of data_i is detected,
--! depending if it was rising or faling edge, the pair of rising/falling outputs are being updated.
--! ?_ts_h refers to the Unix time moment and ?_ts_l to the nanosec moment of transition.
architecture arch of detection_logic is
--! Definition of signals to be used in the design
  signal data_async : std_logic := '0'; --! output of the first shift-register
  signal data_sync  : std_logic := '0'; --! output of the second shift-register
  signal old_value  : std_logic := '0'; --! value to be compared to detected new value
  signal ts_high_o  : std_logic_vector(31 downto 0);
  signal ts_low_o   : std_logic_vector(31 downto 0); 

  component counter is
  port(
    rst_i              : in  std_logic;
    clk_i              : in  std_logic;
    unix_start_value_i : in std_logic_vector(31 downto 0);
    ts_high_o          : out std_logic_vector(31 downto 0); 
    ts_low_o           : out std_logic_vector(31 downto 0)  
  );
  end component;

begin
  inner_counter : counter port map( --! counter instantiation
    rst_i              => rst_i,
    clk_i              => clk_i,
    unix_start_value_i => unix_start_value_i,
    ts_high_o          => ts_high_o,
    ts_low_o           => ts_low_o
  );

  -- Synchronizer for input data
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      data_async <= data_i;
      data_sync  <= data_async;
    end if;
  end process;

  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      old_value <= '0';
    elsif rising_edge(clk_i) then
      if old_value /= data_sync then --! transition detected
        if data_sync = '0' then      --! \_ FALL
          fall_ts_h <= ts_high_o;
          fall_ts_l <= ts_low_o;
        else                         --! _| RISE
          rise_ts_h <= ts_high_o;
          rise_ts_l <= ts_low_o;
        end if;
        old_value <= data_sync;
      end if;
    end if;
  end process;

  unix_time_o <= ts_high_o; --! output unix time
end arch;

