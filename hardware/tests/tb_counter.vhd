LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library design_lib;

ENTITY tb_counter IS
    generic (runner_cfg : string);
END tb_counter;
ARCHITECTURE counter_arch OF tb_counter IS
	-- constants                                                 
	-- signals                                                   
	SIGNAL clk_i : STD_LOGIC;
	SIGNAL rst_i : STD_LOGIC;
	SIGNAL unix_start_value_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ts_high_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ts_low_o : STD_LOGIC_VECTOR(31 DOWNTO 0); 
	
	BEGIN
		i1 : entity design_lib.counter
		PORT MAP (
	-- list connections between master ports and signals
		clk_i => clk_i,
		rst_i => rst_i,
		unix_start_value_i => unix_start_value_i,
		ts_high_o => ts_high_o,
		ts_low_o => ts_low_o
		);
	
	-- reset generator
	rst_i <= '1', '0' after 50 ns;
	
	clock_pulse: process
	begin
		 clk_i <= '1';
		  wait for 10 ns;
		  clk_i <= '0';
		  wait for 10 ns;
	end process clock_pulse;

														  
	always : PROCESS                                              
	-- optional sensitivity list                                  
	-- (        )
	-- variable declarations 
	variable unix_value : unsigned(31 downto 0);
	
	BEGIN
	  test_runner_setup(runner, runner_cfg);
	  
	  if run("unix_start_time") then
	  
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: set unix time to some initial value");
        info("--------------------------------------------------------------------------------");
		 
		wait until rst_i <= '0';
		wait until rising_edge(clk_i);
		wait for 10 ns;
		 
		unix_start_value_i <= std_logic_vector(to_unsigned(100, 32));
		wait for 20 ns;
		
		report "**************************************** -  Expected unix value " 
		   & integer'image(to_integer(unsigned(unix_start_value_i))) & ", output value was "
		   & integer'image(to_integer(unsigned(ts_high_o)));
		assert(unix_start_value_i = ts_high_o) 
		   report "**************************************** -  Error while setting unix start time." 
		   severity error;
		 
		info("===== TEST CASE FINISHED =====");
		info("=======================================================");
		
	  elsif run("nanoseconds_without_initial_unix") then

	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: check nanoseconds value, initial value not set (starting from zero)");
        info("--------------------------------------------------------------------------------");
	  
	    wait until rst_i <= '0';
		wait until rising_edge(clk_i);
		wait for 10 ns;
		 
		for i in 0 to 99 loop
		  wait for 20 ns;
		end loop;
		 
		report "**************************************** -  Expected nanoseconds value " 
		   & integer'image(2000) & ", output nanoseconds was "
		   & integer'image(to_integer(unsigned(ts_low_o)));
		assert(ts_low_o = std_logic_vector(to_unsigned(2000, 32))) 
		   report "**************************************** -  Error while counting nanoseconds from zero" 
		   severity error;
		
		info("===== TEST CASE FINISHED =====");
		info("=======================================================");
		
		 	  
	  elsif run("nanoseconds_with_initial_unix") then
	  
	    info("--------------------------------------------------------------------------------");
        info("TEST CASE: check nanoseconds value, initial unix value set");
        info("--------------------------------------------------------------------------------");
	  
	    wait until rst_i <= '0';
		wait until rising_edge(clk_i);
		wait for 10 ns;
		 
		unix_start_value_i <= std_logic_vector(to_unsigned(2500, 32));
		wait for 20 ns;
		
		for i in 0 to 49 loop
		  wait for 20 ns;
		end loop;
		
		report "**************************************** -  Expected unix value " 
		   & integer'image(to_integer(unsigned(unix_start_value_i))) & ", output unix value was "
		   & integer'image(to_integer(unsigned(ts_high_o)));
		   
		assert(ts_high_o = unix_start_value_i)
		   report "**************************************** -  Error while setting initial unix value " 
		   severity error;	
		
		report "**************************************** -  Expected nanoseconds value  " 
		   & integer'image(1000) & ", output nanoseconds was "
		   & integer'image(to_integer(unsigned(ts_low_o)));
		   
		assert(ts_low_o = std_logic_vector(to_unsigned(1000, 32))) 
		   report "**************************************** -  Error while counting nanoseconds " 
		   severity error;
		   
		info("===== TEST CASE FINISHED =====");
		info("=======================================================");
      
	  end if;
		  
	  test_runner_cleanup(runner);
	  WAIT;                                                        
	END PROCESS always;                                         
END counter_arch;
