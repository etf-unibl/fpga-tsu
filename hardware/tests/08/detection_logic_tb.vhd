library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity detection_logic_tb is
end detection_logic_tb;

architecture arch of detection_logic_tb is

  component detection_logic
    port(
       clk_i : in std_logic;
        input : in std_logic;
        ts_value_o: out std_logic_vector(31 downto 0);
        we : out std_logic
      );
    end component;
    
    signal clk_i :  std_logic;
    signal input : std_logic;
    signal ts_value_o: std_logic_vector(31 downto 0);
    signal we : std_logic;

begin
  
  dc : detection_logic port map(
        clk_i => clk_i,
          input => input,
          ts_value_o => ts_value_o,
          we => we
        );
        
        
    clock_process : process
    begin
      clk_i <= '0';
      wait for 10 ns;
      clk_i <= '1';
      wait for 10 ns;
    end process;
    
    
    process 
    begin
  
      input <= '0';
      wait for 60 ns;
    
      input <= '1';
      wait for 80 ns;
      
      input <= '0';
      wait for 20 ns;
      
      input <= '1';
      wait for 20 ns;
      
      input <= '0';
      wait for 20 ns;
      
      input <= '1';
      wait for 20 ns;
      
      input <= '0';
      wait for 20 ns;
      
      input <= '1';
      wait for 20 ns;
    
      input <= '0';
      wait for 20 ns;
          
      wait;

    end process;
    
    process 
    begin
        
        wait for 5 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 15 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '1') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        wait for 20 ns;
        assert (we = '0') report "Error. Expected 1, Actual " & std_logic'image(we) severity error;
        
        report "Test completed";
        
        wait;
        
    
    end process;

end arch;