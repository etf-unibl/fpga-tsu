-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     timestamp_unit
--
-- description: This file implements timestamping logic for an input signal.
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
--! @timestamp_unit.vhd
--! @brief Integrated top level entity with custom detection logic, fifo buffers, and counter
--! and also contains register map that can be accessed via Avalon-MM
-------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Entity serving as top level entity of design. It has ports compatible
--! with Avalon-MM, so it plays a role of Avalon-MM slave. It also has
--! data_i input port for signals which transitions need to be detected.
entity timestamp_unit is
  port(
  data_i             : in  std_logic;                     --! Input port for signal to be detected
  clk_i              : in  std_logic;                     --! Clock signal
  rst_i              : in  std_logic;                     --! Asynchronous reset
  read_i             : in  std_logic;                     --! Avalon-MM read signal
  write_i            : in  std_logic;                     --! Avalon-MM write signal
  address_i          : in  std_logic_vector(3 downto 0);  --! Avalon-MM address signal
  writedata_i        : in  std_logic_vector(31 downto 0); --! Avalon-MM signal for data to be written into slave
  readdata_o         : out std_logic_vector(31 downto 0); --! Avalon-MM signal for data to be read from slaves
  response_o         : out std_logic_vector(1 downto 0);  --! Avalon-MM signal for handling bus errors
  interrupt_o        : out std_logic                      --! Interrupt output
  );
end timestamp_unit;

--! @brief Architecture that does functional description of design.
--! @details Design contains fifo buffers, interrupt logic, custom detection_logic module, and reg_map module. Inside
--! detection_logic there is a counter module and based on that counting, detection_logic gives its
--! outputs that are then being stored into FIFO buffers through the reg_map
architecture arch of timestamp_unit is
  --! Signal for integrating hardware and software reset
  signal reset_temp : std_logic := '0';
  --! Definition of reg_map component
  component reg_map is
    port(
    clk_i           : in  std_logic;
    rst_i           : in  std_logic;

    sys_time_i      : in  std_logic_vector(31 downto 0);
    status_i        : in  std_logic_vector(31 downto 0);
    control_i       : in  std_logic_vector(31 downto 0);
    fall_ts_h_i     : in  std_logic_vector(31 downto 0);
    fall_ts_l_i     : in  std_logic_vector(31 downto 0);
    rise_ts_h_i     : in  std_logic_vector(31 downto 0);
    rise_ts_l_i     : in  std_logic_vector(31 downto 0);

    sys_time_o      : out  std_logic_vector(31 downto 0);
    status_o        : out  std_logic_vector(31 downto 0);
    control_o       : out  std_logic_vector(31 downto 0);
    fall_ts_h_o     : out  std_logic_vector(31 downto 0);
    fall_ts_l_o     : out  std_logic_vector(31 downto 0);
    rise_ts_h_o     : out  std_logic_vector(31 downto 0);
    rise_ts_l_o     : out  std_logic_vector(31 downto 0)
    );
  end component;

  --! Definition of detection_logic component
  component detection_logic is
    port(
      data_i               : in  std_logic;
      clk_i                : in  std_logic;
      rst_i                : in  std_logic;
      start_i              : in  std_logic;
      unix_start_value_i   : in  std_logic_vector(31 downto 0);
      en_fall_o            : out std_logic;
      en_rise_o            : out std_logic;
      unix_time_o          : out std_logic_vector(31 downto 0);
      fall_ts_h_o          : out std_logic_vector(31 downto 0);
      fall_ts_l_o          : out std_logic_vector(31 downto 0);
      rise_ts_h_o          : out std_logic_vector(31 downto 0);
      rise_ts_l_o          : out std_logic_vector(31 downto 0)
    );
  end component;

  --! Definition of fifo_buffer component
  component fifo_buffer is
    generic (
    g_RAM_WIDTH : natural := 32; --! The width of every memory slot in bits
    g_RAM_DEPTH : natural := 32  --! The number of memory slots in ram
  );
    port(
    clk_i        : in  std_logic;
    rst_i        : in  std_logic;
    data_i       : in  std_logic_vector(g_RAM_WIDTH - 1 downto 0);
    wren_i       : in  std_logic;
    rden_i       : in  std_logic;
    data_o       : out std_logic_vector(g_RAM_WIDTH - 1 downto 0);
    rdvalid_o    : out std_logic;
    empty_o      : out std_logic;
    full_o       : out std_logic;
    fill_count_o : out std_logic_vector(4 downto 0)
  );
  end component;

  --! Definition of interrupt_logic component
  component interrupt_logic is
    port(
    interrupt1_i   : in  std_logic;
    interrupt2_i   : in  std_logic;
    interrupt_en_i : in  std_logic;
    interrupt_o    : out std_logic
  );
  end component;


  --! Definition of output_buffer_logic component
  component output_buffer_logic is
    port(
     clk_i   : in  std_logic;
     rst_i   : in  std_logic;
     en_i    : in  std_logic;
     empty_i : in  std_logic;
     read_i  : in  std_logic;
     rden_o  : out std_logic
  );
  end component;

  --! Definition of d flip-flop component
  component d_ff is
    port(
      clk_i  : in  std_logic;
      rst_i  : in  std_logic;
      data_i : in  std_logic;
      data_o : out std_logic
  );
  end component;


  --! Signal used to write into sys_time register
  signal sys_time_write : std_logic_vector(31 downto 0) := (others => '0');

  --! Signal used to read from sys_time register and write initial unix time into counter
  signal sys_time_read  : std_logic_vector(31 downto 0) := (others => '0');

  --! Signals used to read from/write to status and control register
  signal status_write : std_logic_vector(31 downto 0) := (others => '0');
  signal status_read  : std_logic_vector(31 downto 0) := (others => '0');
  signal control_write : std_logic_vector(31 downto 0) := (others => '0');
  signal control_read  : std_logic_vector(31 downto 0) := (others => '0');

  --! Signals used to read from fall_x  and rise_x registers
  signal fall_ts_h_read : std_logic_vector(31 downto 0) := (others => '0');
  signal fall_ts_l_read : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_h_read : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_l_read : std_logic_vector(31 downto 0) := (others => '0');

  --! Signals used to connect detection_logic outputs with reg_map inputs
  signal fall_ts_h_write : std_logic_vector(31 downto 0) := (others => '0');
  signal fall_ts_l_write : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_h_write : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_l_write : std_logic_vector(31 downto 0) := (others => '0');
  signal en_fall_write   : std_logic := '0';
  signal en_rise_write   : std_logic := '0';

  --! Signal used to read current unix time from counter inside detection_logic
  signal unix_time_read : std_logic_vector(31 downto 0) := (others => '0');

  --! Signals for fill count
  signal fill_count_fall_h : std_logic_vector(4 downto 0) := "00000";
  signal fill_count_fall_l : std_logic_vector(4 downto 0) := "00000";
  signal fill_count_rise_h : std_logic_vector(4 downto 0) := "00000";
  signal fill_count_rise_l : std_logic_vector(4 downto 0) := "00000";

  --! Signals for reading fifo buffers
  signal fall_ts_h_read_en : std_logic := '0';
  signal fall_ts_l_read_en : std_logic := '0';
  signal rise_ts_h_read_en : std_logic := '0';
  signal rise_ts_l_read_en : std_logic := '0';

  --! Signals for fifo outputs
  signal fifo_fall_ts_h_read : std_logic_vector(31 downto 0) := (others => '0');
  signal fifo_fall_ts_l_read : std_logic_vector(31 downto 0) := (others => '0');
  signal fifo_rise_ts_h_read : std_logic_vector(31 downto 0) := (others => '0');
  signal fifo_rise_ts_l_read : std_logic_vector(31 downto 0) := (others => '0');

  --! Valid output signals for fifo buffers
  signal valid_fall_high_o : std_logic := '0';
  signal valid_fall_low_o  : std_logic := '0';
  signal valid_rise_high_o : std_logic := '0';
  signal valid_rise_low_o  : std_logic := '0';

  --! Empty and full signals for fifo buffers
  signal empty_fall_high_o : std_logic := '0';
  signal empty_fall_low_o  : std_logic := '0';
  signal empty_rise_high_o : std_logic := '0';
  signal empty_rise_low_o  : std_logic := '0';
  signal full_fall_high_o  : std_logic := '0';
  signal full_fall_low_o   : std_logic := '0';
  signal full_rise_high_o  : std_logic := '0';
  signal full_rise_low_o   : std_logic := '0';
  signal empty_o           : std_logic := '0';
  signal full_o            : std_logic := '0';
  signal status_internal   : std_logic_vector(31 downto 0) := (others => '0');

  --! Signals for output_buffer_logic
  signal fall_ts_h_temp : std_logic;
  signal fall_ts_l_temp : std_logic;
  signal rise_ts_h_temp : std_logic;
  signal rise_ts_l_temp : std_logic;



  --! Write enable d_ff signals
  signal en_fall_write_temp : std_logic;
  signal en_rise_write_temp : std_logic;

  --! start enable signal
  signal start_enable : std_logic;

  --! Avalon-mm response temporary signal
  signal response_temp : std_logic_vector(1 downto 0) := "00";

begin

  --! Instantiation of reg_map component
  inner_regmap : reg_map port map(
    clk_i       => clk_i,
    rst_i       => reset_temp,
    sys_time_i  => sys_time_write,
    status_i    => status_write,
    control_i   => control_write,
    fall_ts_h_i => fall_ts_h_write,
    fall_ts_l_i => fall_ts_l_write,
    rise_ts_h_i => rise_ts_h_write,
    rise_ts_l_i => rise_ts_l_write,
    sys_time_o  => sys_time_read,
    status_o    => status_read,
    control_o   => control_read,
    fall_ts_h_o => fall_ts_h_read,
    fall_ts_l_o => fall_ts_l_read,
    rise_ts_h_o => rise_ts_h_read,
    rise_ts_l_o => rise_ts_l_read
    );
  --! Instantiaton of detection_logic component
  inner_detection_logic : detection_logic port map(
    data_i             => data_i,
    clk_i              => clk_i,
    rst_i              => reset_temp,
    start_i            => start_enable,
    unix_start_value_i => sys_time_read,
    en_fall_o          => en_fall_write,
    en_rise_o          => en_rise_write,
    unix_time_o        => unix_time_read,
    fall_ts_h_o        => fall_ts_h_write,
    fall_ts_l_o        => fall_ts_l_write,
    rise_ts_h_o        => rise_ts_h_write,
    rise_ts_l_o        => rise_ts_l_write
  );
   --! Instantiation of FIFO buffer for fall ts high register
  fall_ts_h_fifo : fifo_buffer port map(
    clk_i        => clk_i,
    rst_i        => reset_temp,
    data_i       => fall_ts_h_read,
    wren_i       => en_fall_write_temp,
    rden_i       => fall_ts_h_temp,
    data_o       => fifo_fall_ts_h_read,
    rdvalid_o    => valid_fall_high_o,
    empty_o      => empty_fall_high_o,
    full_o       => full_fall_high_o,
    fill_count_o => fill_count_fall_h
  );
   --! Instantiation of FIFO buffer for fall ts low register
  fall_ts_l_fifo : fifo_buffer port map(
    clk_i        => clk_i,
    rst_i        => reset_temp,
    data_i       => fall_ts_l_read,
    wren_i       => en_fall_write_temp,
    rden_i       => fall_ts_l_temp,
    data_o       => fifo_fall_ts_l_read,
    rdvalid_o    => valid_fall_low_o,
    empty_o      => empty_fall_low_o,
    full_o       => full_fall_low_o,
    fill_count_o => fill_count_fall_l
  );
   --! Instantiation of FIFO buffer for rise ts high register
  rise_ts_h_fifo : fifo_buffer port map(
    clk_i        => clk_i,
    rst_i        => reset_temp,
    data_i       => rise_ts_h_read,
    wren_i       => en_rise_write_temp,
    rden_i       => rise_ts_h_temp,
    data_o       => fifo_rise_ts_h_read,
    rdvalid_o    => valid_rise_high_o,
    empty_o      => empty_rise_high_o,
    full_o       => full_rise_high_o,
    fill_count_o => fill_count_rise_h
  );
  --! Instantiation of FIFO buffer for rise ts low register
  rise_ts_l_fifo : fifo_buffer port map(
    clk_i        => clk_i,
    rst_i        => reset_temp,
    data_i       => rise_ts_l_read,
    wren_i       => en_rise_write_temp,
    rden_i       => rise_ts_l_temp,
    data_o       => fifo_rise_ts_l_read,
    rdvalid_o    => valid_rise_low_o,
    empty_o      => empty_rise_low_o,
    full_o       => full_rise_low_o,
    fill_count_o => fill_count_rise_l
  );
  -- Instantiation of interrupt logic
  interrupt : interrupt_logic port map(
    interrupt1_i   => status_read(1),
    interrupt2_i   => status_read(2),
    interrupt_en_i => control_read(1),
    interrupt_o    => interrupt_o
  );
  --! Instantiation of fall ts high output buffer logic
  fall_ts_h_buffer : output_buffer_logic port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    en_i    => en_fall_write_temp,
    empty_i => empty_fall_high_o,
    read_i  => fall_ts_h_read_en,
    rden_o  => fall_ts_h_temp
  );
  --! Instantiation of fall ts low output buffer logic
  fall_ts_l_buffer : output_buffer_logic port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    en_i    => en_fall_write_temp,
    empty_i => empty_fall_low_o,
    read_i  => fall_ts_l_read_en,
    rden_o  => fall_ts_l_temp
  );
  --! Instantiation of rise ts high output buffer logic
  rise_ts_h_buffer : output_buffer_logic port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    en_i    => en_rise_write_temp,
    empty_i => empty_rise_high_o,
    read_i  => rise_ts_h_read_en,
    rden_o  => rise_ts_h_temp
  );
  --! Instantiation of rise ts low output buffer logic
  rise_ts_l_buffer : output_buffer_logic port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    en_i    => en_rise_write_temp,
    empty_i => empty_rise_low_o,
    read_i  => rise_ts_l_read_en,
    rden_o  => rise_ts_l_temp
  );
  --! Instantiation of D flip-flop for enabling writing into fall fifo buffers
  en_fall_buffer : d_ff port map(
    clk_i  => clk_i,
    rst_i  => rst_i,
    data_i => en_fall_write,
    data_o => en_fall_write_temp
  );
  --! Instantiation of D flip-flop for enabling writing into rise fifo buffers
  en_rise_buffer : d_ff port map(
   clk_i   => clk_i,
    rst_i  => rst_i,
    data_i => en_rise_write,
    data_o => en_rise_write_temp
  );
  --! Synchronous process that decides which register is being
  --! written into or read from
  process(clk_i, reset_temp)
  begin
    if reset_temp = '1' then
      sys_time_write <= (others => '0');
      status_write <= (others => '0');
      control_write <= (others => '0');
      fall_ts_h_read_en <= '0';
      fall_ts_l_read_en <= '0';
      rise_ts_h_read_en <= '0';
      rise_ts_l_read_en <= '0';
      response_temp <= "00";
    elsif rising_edge(clk_i) then
      fall_ts_h_read_en <= '0';
      fall_ts_l_read_en <= '0';
      rise_ts_h_read_en <= '0';
      rise_ts_l_read_en <= '0';
      response_temp <= "00";
      --! sys_time register
      if address_i = "0000" then
        if write_i = '1' then
          sys_time_write <= writedata_i;
        elsif read_i = '1' then
          readdata_o <= unix_time_read;
        end if;
      --! status register
      elsif address_i = "0001" then
        if write_i = '1' then
          status_write <= writedata_i;
        elsif read_i = '1' then
          readdata_o <= status_read;
        end if;
     --! control register
      elsif address_i = "0010" then
        if write_i = '1' then
          control_write <= writedata_i;
        elsif read_i = '1' then
          readdata_o <= control_read;
        end if;
      --! fall_ts_h register
      elsif address_i = "0011" then
        if read_i = '1' then
          readdata_o <= fall_ts_h_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      --! fall_ts_l register
      elsif address_i = "0100" then
        if read_i = '1' then
          readdata_o <= fall_ts_l_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      --! rise_ts_h register
      elsif address_i = "0101" then
        if read_i = '1' then
          readdata_o <= rise_ts_h_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      --! rise_ts_l register
      elsif address_i = "0110" then
        if read_i = '1' then
          readdata_o <= rise_ts_l_read;
        elsif  write_i = '1' then
          response_temp <= "10";
        end if;
      --! fall_ts_h fifo buffer
      elsif address_i = "1000" then
        if read_i = '1' then
          fall_ts_h_read_en <= '1';
          readdata_o <= fifo_fall_ts_h_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      --! fall_ts_l fifo buffer
      elsif address_i = "1001" then
        if read_i = '1' then
          fall_ts_l_read_en <= '1';
          readdata_o <= fifo_fall_ts_l_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      --! rise_ts_h fifo buffer
      elsif address_i = "1010" then
        if read_i = '1' then
          rise_ts_h_read_en <= '1';
          readdata_o <= fifo_rise_ts_h_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      --! rise_ts_l fifo buffer
      elsif address_i = "1011" then
        if read_i = '1' then
          rise_ts_l_read_en <= '1';
          readdata_o <= fifo_rise_ts_l_read;
        elsif write_i = '1' then
          response_temp <= "10";
        end if;
      elsif read_i = '1' or write_i = '1' then
        response_temp <= "11";
      end if;
        --! Writing into status register
      if read_i /= '1' and write_i /= '1' then
        status_write <= status_internal;
      end if;
    end if;
  end process;
  --! Combinational logic
  response_o <= response_temp;
  start_enable <= control_read(0);
  reset_temp <= rst_i or control_read(2);
  empty_o <= empty_fall_high_o or empty_fall_low_o or empty_rise_high_o or empty_rise_low_o;
  full_o <= full_fall_high_o or full_fall_low_o or full_rise_high_o or full_rise_low_o;
  status_internal <= "00000000000000000000000000000" & full_o & empty_o & "0";
end arch;
