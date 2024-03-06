-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2023
-- https://github.com/etf-unibl/fpga-tsu
-----------------------------------------------------------------------------
--
-- unit name:     avs_integrated_tsu
--
-- description:
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
--! @avs_integrated_tsu
--! @brief Integrated top level entity with custom detection logic and counter
--! and also contains register map that can be accessed via Avalon-MM
-------------------------------------------------------
--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! Entity serving as top level entity of design. It has ports compatible
--! with Avalon-MM, so it plays a role of Avalon-MM slave. It also has
--! data_i input port for signals which transitions need to be detected.
entity avs_integrated_tsu is
  port(
  data_i       : in  std_logic;                     --! Input port for signal to be detected
  clk_i        : in  std_logic;                     --! Clock signal
  rst_i        : in  std_logic;                     --! Asynchronous reset
  read_i       : in  std_logic;                     --! Avalon-MM read signal
  write_i      : in  std_logic;                     --! Avalon-MM write signal
  address_i    : in  std_logic_vector(2 downto 0);  --! Avalon-MM address signal
  writedata_i  : in  std_logic_vector(31 downto 0); --! Avalon-MM signal for data to be written into slave
  readdata_o   : out std_logic_vector(31 downto 0)  --! Avalon-MM signal for data to be read from slaves
  );
end avs_integrated_tsu;

--! @brief Architecture that does functional description of design.
--! @details Design contains two submodules, custom detection_logic module, and reg_map module. Inside
--! detection_logic there is a counter module and based on that counting, detection_logic gives its
--! outputs that are then **being store into FIFO buffer**(not yet implemented), through the reg_map
architecture arch of avs_integrated_tsu is

  -- Definition of reg_map component
  component reg_map is
    port(
    clk_i           : in   std_logic;
    rst_i           : in   std_logic;

    sys_time_i      : in   std_logic_vector(31 downto 0);
    status_i        : in   std_logic_vector(31 downto 0);
    control_i       : in   std_logic_vector(31 downto 0);
    fall_ts_h_i     : in   std_logic_vector(31 downto 0);
    fall_ts_l_i     : in   std_logic_vector(31 downto 0);
    rise_ts_h_i     : in   std_logic_vector(31 downto 0);
    rise_ts_l_i     : in   std_logic_vector(31 downto 0);

    sys_time_o      : out  std_logic_vector(31 downto 0);
    status_o        : out  std_logic_vector(31 downto 0);
    control_o       : out  std_logic_vector(31 downto 0);
    fall_ts_h_o     : out  std_logic_vector(31 downto 0);
    fall_ts_l_o     : out  std_logic_vector(31 downto 0);
    rise_ts_h_o     : out  std_logic_vector(31 downto 0);
    rise_ts_l_o     : out  std_logic_vector(31 downto 0)
    );
  end component;

  -- Definition of detection_logic component
  component detection_logic is
    port(
      data_i             : in  std_logic;
      clk_i              : in  std_logic;
      rst_i              : in  std_logic;
      start_i            : in  std_logic;
      unix_start_value_i : in  std_logic_vector(31 downto 0);
      unix_time_o        : out std_logic_vector(31 downto 0);
      en_fall_o          : out std_logic;
      en_rise_o          : out std_logic;
      fall_ts_h_o        : out std_logic_vector(31 downto 0);
      fall_ts_l_o        : out std_logic_vector(31 downto 0);
      rise_ts_h_o        : out std_logic_vector(31 downto 0);
      rise_ts_l_o        : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Signal used to write into sys_time register
  signal sys_time_write : std_logic_vector(31 downto 0) := (others => '0');

  -- Signal used to read from sys_time register and write initial unix time into counter
  signal sys_time_read  : std_logic_vector(31 downto 0) := (others => '0');

  -- Signals used to read from/write to status and control register
  signal status_write : std_logic_vector(31 downto 0) := (others => '0');
  signal status_read  : std_logic_vector(31 downto 0) := (others => '0');
  signal control_write : std_logic_vector(31 downto 0) := (others => '0');
  signal control_read  : std_logic_vector(31 downto 0) := (others => '0');

  -- Signals used to read from fall_x  and rise_x registers
  signal fall_ts_h_read : std_logic_vector(31 downto 0) := (others => '0');
  signal fall_ts_l_read : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_h_read : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_l_read : std_logic_vector(31 downto 0) := (others => '0');

  -- Signals used to connect detection_logic outputs with reg_map inputs
  signal fall_ts_h_write : std_logic_vector(31 downto 0) := (others => '0');
  signal fall_ts_l_write : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_h_write : std_logic_vector(31 downto 0) := (others => '0');
  signal rise_ts_l_write : std_logic_vector(31 downto 0) := (others => '0');

  -- Signal used to read current unix time from counter inside detection_logic
  signal unix_time_read : std_logic_vector(31 downto 0) := (others => '0');

  --
  signal start_i   : std_logic := '1';
  signal en_fall_o : std_logic;
  signal en_rise_o : std_logic;


begin

  -- Instantiation of reg_map component
  inner_regmap : reg_map port map(
    clk_i       => clk_i,
    rst_i       => rst_i,

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

  -- Instantiaton of detection_logic component
  inner_detection_logic : detection_logic port map(
    data_i             => data_i,
    clk_i              => clk_i,
    rst_i              => rst_i,
    start_i            => start_i,
    unix_start_value_i => sys_time_read,
    unix_time_o        => unix_time_read,
    en_fall_o          => en_fall_o,
    en_rise_o          => en_rise_o,
    fall_ts_h_o        => fall_ts_h_write,
    fall_ts_l_o        => fall_ts_l_write,
    rise_ts_h_o        => rise_ts_h_write,
    rise_ts_l_o        => rise_ts_l_write
    );

  -- Synchronous process that decides which register is being
  -- written into or read from via Avalon-MM based on address
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      sys_time_write <= (others => '0');
      status_write   <= (others => '0');
      control_write  <= (others => '0');

    elsif rising_edge(clk_i) then

      -- sys_time register
      if address_i = "000" then
        if write_i = '1' then
          sys_time_write <= writedata_i;
        elsif read_i = '1' then
          readdata_o <= unix_time_read;
        end if;

        -- status register
      elsif address_i = "001" then
        if write_i = '1' then
          status_write <= writedata_i;
        elsif read_i = '1' then
          readdata_o <= status_read;
        end if;

       -- control register
      elsif address_i = "010" then
        if write_i = '1' then
          control_write <= writedata_i;
        elsif read_i = '1' then
          readdata_o <= control_read;
        end if;

        -- fall_ts_h register
      elsif address_i = "011" then
        if read_i = '1' then
          readdata_o <= fall_ts_h_read;
        end if;

        -- fall_ts_l register
      elsif address_i = "100" then
        if read_i = '1' then
          readdata_o <= fall_ts_l_read;
        end if;

        -- rise_ts_h register
      elsif address_i = "101" then
        if read_i = '1' then
          readdata_o <= rise_ts_h_read;
        end if;

        -- rise_ts_l register
      elsif address_i = "110" then
        if read_i = '1' then
          readdata_o <= rise_ts_l_read;
        end if;
      end if;
    end if;

  end process;

end arch;
