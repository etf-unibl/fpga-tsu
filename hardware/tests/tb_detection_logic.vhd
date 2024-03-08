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

    signal clk_i : std_logic := '0';
	signal rst_i : std_logic := '0';
    signal data_i : std_logic := '0';
    signal unix_start_value_i : std_logic_vector(31 downto 0) := (others => '0');
	signal start : std_logic := '0';
	signal en_fall : std_logic := '0';
	signal en_rise : std_logic := '0';
	signal unix_time_o : std_logic_vector(31 downto 0) := (others => '0');
	signal fall_ts_h : std_logic_vector(31 downto 0) := (others => '0');
    signal fall_ts_l : std_logic_vector(31 downto 0) := (others => '0');
	signal rise_ts_h : std_logic_vector(31 downto 0) := (others => '0');
	signal rise_ts_l : std_logic_vector(31 downto 0) := (others => '0');
	 
	 
begin
  
  dc : entity design_lib.detection_logic 
    port map(
     data_i => data_i,
	 clk_i => clk_i,
	 rst_i => rst_i,
	 start_i => start,
	 unix_start_value_i => unix_start_value_i,
	 en_fall_o => en_fall,
	 en_rise_o => en_rise,
	 unix_time_o   => unix_time_o,
	 fall_ts_h_o => fall_ts_h,
	 fall_ts_l_o => fall_ts_l,
	 rise_ts_h_o => rise_ts_h,
     rise_ts_l_o => rise_ts_l
	);
        
    rst_i <= '1', '0' after 40 ns;    
    
    clock_process : process
    begin
      clk_i <= '0';
      wait for 10 ns;
      clk_i <= '1';
      wait for 10 ns;
    end process;

    process 
      variable ts_l : integer := 0;
	  variable ts_h : integer := 0;
	  variable time_of_rising_edge : integer;
	  variable time_of_falling_edge : integer;
	  
	begin
	 
	  test_runner_setup(runner, runner_cfg);
	  
	  test_case_loop : while test_suite loop
	  
	    if run ("initial_unix_time") then
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: Unix time value set");
			info("--------------------------------------------------------------------------------");
			wait until rst_i = '0';
			start <= '1';
			unix_start_value_i <= std_logic_vector(to_unsigned(10, 32));
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			info("********************************************************************************");	
			report "                               -    Expected unix time value is " 
			   & integer'image(to_integer(unsigned(unix_start_value_i))) 
			   & ", actual value is " & integer'image(to_integer(unsigned(unix_time_o)));
			assert(unix_start_value_i = unix_time_o) 
			   report "                              -    Error while setting initial unix value "  
			   severity error;
			info("********************************************************************************");	
			   
			info("===== TEST CASE FINISHED =====");
		
		elsif run("rising_edge") then
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: Rising Edge Transition ");
			info(" Initial value not set, so it should be zero. After 60 us, rising edge occurs, and should be detected");
			info("--------------------------------------------------------------------------------");
			
			wait until rst_i = '0';
			start <= '1';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			-- simulating rising edge after 60 us
			data_i <= '0';
			time_of_rising_edge := 1234580;
			wait for 1234580 ns;
			data_i <= '1';
			
			-- wait for output to stabilize
			wait for 70 ns;
			
			-- check unix time
			info("********************************************************************************");
			report "                               -    Expected unix time of rising edge " 
			   & integer'image(to_integer(unsigned(unix_start_value_i))) 
			   & ", actual value is " & integer'image(to_integer(unsigned(rise_ts_h)));
			   
			assert(rise_ts_h = unix_time_o) 
			   report "                               -    Error while detecting unix time of rising edge" 
		       severity error;
			info("********************************************************************************");
			   
			   
			-- check nanoseconds
			-- because of  syncronization, data_i will be late for 3 cycles (60 ns)
			ts_l := to_integer(unsigned(rise_ts_l));
			ts_l := ts_l - 60;

			info("********************************************************************************");
			report "                               -    Expected nanoseconds time of rising edge " 
			   & integer'image(time_of_rising_edge) 
			   & ", actual value is " & integer'image(ts_l);
			   
			assert((ts_l) = time_of_rising_edge) 
			   report "                               -    Error while detecting nanoseconds time of rising edge" 
		       severity error;
			info("********************************************************************************");
			
			
			info("===== TEST CASE FINISHED =====");
			
		elsif run("rising_edge_initial_value") then
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: Rising Edge Transition With Initial Unix Time");
			info(" Initial value set to 10. After 60 us, rising edge occurs");
			info("--------------------------------------------------------------------------------");
			
			wait until rst_i = '0';
			unix_start_value_i <= std_logic_vector(to_unsigned(10, 32));  -- set initial unix time to 10
			start <= '1';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
		    -- simulating rising edge after 60 us
			data_i <= '0';
			time_of_rising_edge := 1234580;
			wait for 1234580 ns;
			data_i <= '1';
			
			-- wait for output to stabilize
			wait for 70 ns;
			
			-- check unix time
			info("********************************************************************************");
			report "                               -    Expected unix time of rising edge " 
			   & integer'image(to_integer(unsigned(unix_start_value_i))) 
			   & ", actual value is " & integer'image(to_integer(unsigned(rise_ts_h)));
			   
			assert(rise_ts_h = unix_time_o) 
			   report "                               -    Error while detecting unix time of rising edge" 
		       severity error;
			info("********************************************************************************");
			   
			   
			-- check nanoseconds
			-- because of  syncronization, data_i will be late for 2 cycles (60 ns)
			ts_l := to_integer(unsigned(rise_ts_l));
			ts_l := ts_l - 40;

			info("********************************************************************************");
			report "                               -    Expected nanoseconds time of rising edge " 
			   & integer'image(time_of_rising_edge) 
			   & ", actual value is " & integer'image(ts_l);
			   
			assert((ts_l) = time_of_rising_edge) 
			   report "                               -    Error while detecting nanoseconds time of rising edge" 
		       severity error;
			info("********************************************************************************");
			
			info("===== TEST CASE FINISHED =====");

		elsif run("falling_edge") then
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: Falling Edge Transition ");
			info(" Initial value not set, so it should be zero. After 60 us, rising edge occurs, ");
			info(" after another 70 us falling edge ");
			info("--------------------------------------------------------------------------------");
			
			wait until rst_i = '0';
			start <= '1';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			data_i <= '0';
			
			time_of_rising_edge := 10000;
			wait for 10000 ns;
			data_i <= '1';
			
			time_of_falling_edge := 5000;
			wait for 5000 ns;
			data_i <= '0';

			-- wait for output to stabilize
			wait for 70 ns;
			
			-- check unix time
			info("********************************************************************************");
			report "                               -    Expected unix time of falling edge " 
			   & integer'image(to_integer(unsigned(unix_start_value_i))) 
			   & ", actual value is " & integer'image(to_integer(unsigned(fall_ts_h)));
			   
			assert(fall_ts_h = unix_time_o) 
			   report "                               -    Error while detecting unix time of rising edge" 
		       severity error;
			info("********************************************************************************");
			   
			   
			-- check nanoseconds
			-- because of  syncronization, data_i will be late for 3 cycles (60 ns)
			ts_l := to_integer(unsigned(fall_ts_l));
			ts_l := ts_l - 60;

			info("********************************************************************************");
			report "                               -    Expected nanoseconds time of rising edge " 
			   & integer'image(time_of_falling_edge + time_of_rising_edge) 
			   & ", actual value is " & integer'image(ts_l);
			   
			assert(ts_l = time_of_falling_edge + time_of_rising_edge) 
			   report "                               -    Error while detecting nanoseconds time of rising edge" 
		       severity error;
			info("********************************************************************************");
			
			info("===== TEST CASE FINISHED =====");
			
		elsif run("falling_edge_initial_value") then
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: Rising Edge Transition With Initial Unix Time");
			info(" Initial value set to 1000. After 130 us, falling edge occurs");
			info("--------------------------------------------------------------------------------");
			
			wait until rst_i = '0';
			start <= '1';
			unix_start_value_i <= std_logic_vector(to_unsigned(1000, 32));
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			data_i <= '0';
			time_of_rising_edge := 458200;
			wait for 458200 ns;
			data_i <= '1';
			
			time_of_falling_edge := 5580;
			wait for 5580 ns;
			data_i <= '0';

			-- wait for output to stabilize
			wait for 70 ns;
			
			-- check unix time
			info("********************************************************************************");
			report "                               -    Expected unix time of falling edge " 
			   & integer'image(to_integer(unsigned(unix_start_value_i))) 
			   & ", actual value is " & integer'image(to_integer(unsigned(fall_ts_h)));
			   
			assert(fall_ts_h = unix_time_o) 
			   report "                               -    Error while detecting unix time of rising edge" 
		       severity error;
			info("********************************************************************************");
			   
			   
			-- check nanoseconds
			-- because of  syncronization, data_i will be late for 2 cycles (40 ns)
			ts_l := to_integer(unsigned(fall_ts_l));
			ts_l := ts_l - 40;

			info("********************************************************************************");
			report "                               -    Expected nanoseconds time of rising edge " 
			   & integer'image(time_of_falling_edge + time_of_rising_edge) 
			   & ", actual value is " & integer'image(ts_l);
			   
			assert(ts_l = time_of_falling_edge + time_of_rising_edge) 
			   report "                               -    Error while detecting nanoseconds time of rising edge" 
		       severity error;
			info("********************************************************************************");
			
			info("===== TEST CASE FINISHED =====");
			
        end if;
      end loop;

      info("====== Complete test succesfully finished ========");
	  
	  test_runner_cleanup(runner);
	  wait;
	end process;
end arch;
	  