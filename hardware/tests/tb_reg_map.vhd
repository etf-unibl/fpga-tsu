LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library design_lib;

ENTITY tb_reg_map IS
    generic (runner_cfg : string);
END tb_reg_map;
ARCHITECTURE reg_map_arch OF tb_reg_map IS
-- constants                                                 
-- signals                                                   
  signal clk_i   :  std_logic;
  signal rst_i   :   std_logic;                    
  
  signal sys_time_i  : std_logic_vector(31 downto 0) := (others => '0'); 
  signal status_i    :  std_logic_vector(31 downto 0):= (others => '0'); 
  signal control_i   : std_logic_vector(31 downto 0):= (others => '0');
  signal fall_ts_h_i : std_logic_vector(31 downto 0):= (others => '0');
  signal fall_ts_l_i : std_logic_vector(31 downto 0):= (others => '0');
  signal rise_ts_h_i : std_logic_vector(31 downto 0):= (others => '0');
  signal rise_ts_l_i : std_logic_vector(31 downto 0):= (others => '0');
  
  signal sys_time_o  : std_logic_vector(31 downto 0):= (others => '0');
  signal status_o    : std_logic_vector(31 downto 0):= (others => '0');
  signal control_o   : std_logic_vector(31 downto 0):= (others => '0');
  signal fall_ts_h_o : std_logic_vector(31 downto 0):= (others => '0');
  signal fall_ts_l_o : std_logic_vector(31 downto 0):= (others => '0');
  signal rise_ts_h_o : std_logic_vector(31 downto 0):= (others => '0');
  signal rise_ts_l_o : std_logic_vector(31 downto 0):= (others => '0');
  
BEGIN
	i1 : entity design_lib.reg_map
	PORT MAP (
-- list connections between master ports and signals
		clk_i => clk_i,
		rst_i => rst_i,
		sys_time_i => sys_time_i,
		status_i => status_i,
		control_i => control_i,
		fall_ts_h_i => fall_ts_h_i,
		fall_ts_l_i => fall_ts_l_i,
		rise_ts_h_i => rise_ts_h_i,
		rise_ts_l_i => rise_ts_l_i,
		sys_time_o => sys_time_o,
		status_o => status_o,
		control_o => control_o,
		fall_ts_h_o => fall_ts_h_o,
		fall_ts_l_o => fall_ts_l_o,
		rise_ts_h_o => rise_ts_h_o,
		rise_ts_l_o => rise_ts_l_o	
	);
	
  -- stimulus generator for reset
	rst_i <= '1', '0' after 30 ns;	

process
begin
    clk_i <= '0';
    wait for 10 ns;
    clk_i <= '1';
    wait for 10 ns;
end process;  
                                    
validation : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN
  test_runner_setup(runner, runner_cfg);
  
   test_cases_loop : WHILE test_suite LOOP
     
      IF run("sys_time") THEN
        info("--------------------------------------------------------------------------------");
        info("TEST CASE: sys_time register check");
        info("--------------------------------------------------------------------------------");
		wait until rst_i <= '0';
	    wait until rising_edge(clk_i);
	    wait for 10 ns;  

	    sys_time_i <= std_logic_vector(to_unsigned(2, 32));
	    wait for 20 ns;
	    assert(sys_time_i = sys_time_o) report "Error in sys_time register. Expected " & integer'image(to_integer(unsigned(sys_time_i))) 
		   & " Actual " & integer'image(to_integer(unsigned(sys_time_o))) severity error; 
        info("===== TEST CASE FINISHED =====");
		
	  elsif run("status") then
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: status register check");
        info("--------------------------------------------------------------------------------");
		wait until rst_i <= '0';
		wait until rising_edge(clk_i);
		wait for 10 ns;  

    	status_i <= std_logic_vector(to_unsigned(3, 32));
		wait for 20 ns;
		assert(status_i = status_o) report "Error in sys_time register. Expected " & integer'image(to_integer(unsigned(status_i))) 
			 & " Actual " & integer'image(to_integer(unsigned(status_o))) severity error; 
		info("===== TEST CASE FINISHED =====");
	  
	  elsif run("control") then 
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: control register check");
        info("--------------------------------------------------------------------------------");
	    wait until rst_i <= '0';
		wait until rising_edge(clk_i);
	    wait for 10 ns;  

	    control_i <= std_logic_vector(to_unsigned(4, 32));
	    wait for 20 ns;
	    assert(control_i = control_o) report "Error in sys_time register. Expected " & integer'image(to_integer(unsigned(control_i))) 
		   & " Actual " & integer'image(to_integer(unsigned(control_o))) severity error; 		
		info("===== TEST CASE FINISHED =====");
		
	  elsif run("fall_ts_h") then 
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: fall_ts_h register check");
        info("--------------------------------------------------------------------------------");
     	wait until rst_i <= '0';
		wait until rising_edge(clk_i);
	    wait for 10 ns;  

    	fall_ts_h_i <= std_logic_vector(to_unsigned(5, 32));
	    wait for 20 ns;
	    assert(fall_ts_h_i = fall_ts_h_o) report "Error in sys_time register. Expected " 
		   & integer'image(to_integer(unsigned(fall_ts_h_i))) 
		   & " Actual " & integer'image(to_integer(unsigned(fall_ts_h_o))) severity error; 			
		info("===== TEST CASE FINISHED =====");
		
	  elsif run("fall_ts_l") then 
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: fall_ts_l register check");
        info("--------------------------------------------------------------------------------");
	    wait until rst_i <= '0';
		wait until rising_edge(clk_i);
	    wait for 10 ns;  

	    fall_ts_l_i <= std_logic_vector(to_unsigned(6, 32));
	    wait for 20 ns;
	    assert(fall_ts_l_i = fall_ts_l_o) report "Error in sys_time register. Expected " 
		   & integer'image(to_integer(unsigned(fall_ts_l_i))) 
		   & " Actual " & integer'image(to_integer(unsigned(fall_ts_l_o))) severity error;
		
		info("===== TEST CASE FINISHED =====");
	  
	  elsif run("rise_ts_h") then 
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: rise_ts_h register check");
        info("--------------------------------------------------------------------------------");
		wait until rst_i <= '0';
		wait until rising_edge(clk_i);
		wait for 10 ns;  

		rise_ts_h_i <= std_logic_vector(to_unsigned(7, 32));
		wait for 20 ns;
		assert(rise_ts_h_i = rise_ts_h_o) report "Error in sys_time register. Expected " 
			 & integer'image(to_integer(unsigned(rise_ts_h_i))) 
			 & " Actual " & integer'image(to_integer(unsigned(rise_ts_h_o))) severity error;		
		info("===== TEST CASE FINISHED =====");
		
	  elsif run("rise_ts_l") then 
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: rise_ts_l register check");
        info("--------------------------------------------------------------------------------");
	    wait until rst_i <= '0';
		wait until rising_edge(clk_i);
	    wait for 10 ns;  

	    rise_ts_l_i <= std_logic_vector(to_unsigned(8, 32));
	    wait for 20 ns;
	    assert(rise_ts_l_i = rise_ts_l_o) report "Error in sys_time register. Expected " 
		   & integer'image(to_integer(unsigned(rise_ts_l_i))) 
		   & " Actual " & integer'image(to_integer(unsigned(rise_ts_l_o))) severity error; 		
		info("===== TEST CASE FINISHED =====");
	  
	  end if;
   end loop;
  
	info ("======  Complete test successfully finished =========");
  test_runner_cleanup(runner);
  WAIT;                                                        
END PROCESS validation;                                               
END reg_map_arch;
