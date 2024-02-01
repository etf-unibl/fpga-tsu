entity counter{
  start   : in std_logic,
  reset   : in std_logic,
  clk     : in std_logic
  ts_high : out std_logic_vector(31 downto 0),
  ts_low  : out std_logic_vector(31 downto 0)
}

architecture arch of counter{
  signal ts_low_temp  : unsigned(31 downto 0) := (others => '0');
  signal ts_high_temp : unsigned(31 downto 0) := (others => '0');

begin

  ts_low  <= std_logic_vector(ts_low_temp);
  ts_high <= std_logic_vector(ts_high_temp);

  increment_nanotime : process(clk)
  begin  
    if (rising_edge(clk))
      ts_low_temp <= ts_low_temp + 20;
    end if;
  end process increment_nanotime;

  increment_sectime : process(ts_low_temp)
  begin  
    if (ts_low_temp = "0011 1011 1001 1010 1100 1010 0000 0000")
      ts_high_temp <= ts_high_temp + 1;
      ts_low_temp <= 0;
    end if;
  end process increment_sectime;  
}