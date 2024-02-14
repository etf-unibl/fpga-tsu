library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library design_lib;

entity tb_detection_logic is
  generic (runner_cfg : string);
end tb_detection_logic;

architecture arch of tb_detection_logic is
    signal clk_i :  std_logic;
    signal input_i : std_logic;
    signal ts_value_o: std_logic_vector(31 downto 0);
    signal we_o : std_logic;
begin
  
  dc : entity design_lib.detection_logic port map(
        clk_i => clk_i,
          input_i => input_i,
          ts_value_o => ts_value_o,
          we_o => we_o
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

      input_i <= '0';
      wait for 60 ns;
    
      input_i <= '1';
      wait for 80 ns;
      
      input_i <= '0';
      wait for 20 ns;
      
      input_i <= '1';
      wait for 20 ns;
      
      input_i <= '0';
      wait for 20 ns;
      
      input_i <= '1';
      wait for 20 ns;
      
      input_i <= '0';
      wait for 20 ns;
      
      input_i <= '1';
      wait for 20 ns;
    
      input_i <= '0';
      wait for 20 ns;

      wait;

    end process;
    
    process 
    begin
        test_runner_setup(runner, runner_cfg);
        wait for 5 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 15 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '1') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        wait for 20 ns;
        assert (we_o = '0') report "Error. Expected 1, Actual " & std_logic'image(we_o) severity error;
        
        report "Test completed";
        test_runner_cleanup(runner);
        wait;
        
    
    end process;

end arch;