LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

library design_lib;

ENTITY tb_avs_integrated_tsu IS
  generic (runner_cfg : string);
END tb_avs_integrated_tsu;

ARCHITECTURE arch OF tb_avs_integrated_tsu IS

	signal data_i 		: std_logic := '0';
	signal clk_i 		: std_logic := '0';
	signal rst_i 		: std_logic := '0';
	signal read 		: std_logic := '0';
	signal write 		: std_logic := '0';
	signal address 		: std_logic_vector(2 downto 0) := (others => '0');
	signal writedata  	: std_logic_vector(31 downto 0):= (others => '0');
	signal readdata   	: std_logic_vector(31 downto 0):= (others => '0');
	signal byteenable   : std_logic_vector(3 downto 0) := (others => '0');
	signal waitrequest  : std_logic := '0';
	signal burstcount   : std_logic_vector(1 downto 0) := (others => '0');
	signal readdatavalid : std_logic := '0';
	signal readdata_master : std_logic_vector(31 downto 0);
	
	-- instantiate Avalon-MM bus master verification component
	constant avmm_bus : bus_master_t := new_bus(
	  data_length => 32,
	  address_length => 3,
	  logger => get_logger("avmm_bus")
	);

BEGIN

  -- 
  dut : entity design_lib.avs_integrated_tsu port map(
     data_i => data_i,
	 clk_i => clk_i,
	 rst_i => rst_i,
	 read_i => read,
	 write_i => write,
	 address_i => address,
	 writedata_i => writedata,
	 readdata_o => readdata
  );
  
  -- avalon-mm master that will issue signals to the avalon-mm slave dut, via avalon-mm bus
  -- ports of avalon-mm master will be mapped to internal signals
  avmm_master : entity vunit_lib.avalon_master
	  generic map(
		bus_handle => avmm_bus,
		use_readdatavalid => false
	  )
	  port map(
	    clk => clk_i,
		address => address,
		write => write,
		writedata => writedata,
		read => read,
		readdata => readdata_master,
		byteenable => byteenable,
		waitrequest => waitrequest,
	    burstcount => burstcount,
	    readdatavalid => readdatavalid
	  );
  
    -- reset generator
    rst_i <= '1', '0' after 50 ns;
    
	-- clock process generator
	process
	begin
		 clk_i <= '1';
		 wait for 10 ns;
		 clk_i <= '0';
		 wait for 10 ns;
	end process;

   process
     
	-- variables declaration 
	variable read_temp : std_logic_vector(31 downto 0) := (others => '0');
	variable data_value : std_logic_vector(31 downto 0) := (others => '0');
	variable reg_address : std_logic_vector(2 downto 0) := (others => '0');
	variable time_of_rising_edge : integer;
	variable time_of_falling_edge : integer;
	variable ts_value : integer := 0;
	
	BEGIN
	  
	  test_runner_setup(runner, runner_cfg);

	  test_case_loop : while test_suite loop
	  
		  if run("sys_time_check") then
		  
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: write to SYS_TIME register via Avalon-MM");
			info("           after that read from it via Avalon-MM, and check results");
			info("--------------------------------------------------------------------------------");
			 
			-- wait until reset is clear, and rising edge of clock
			wait until rst_i <= '0';
			wait until rising_edge(clk_i);
			wait for 10 ns;   -- wait for falling edge
			
			-- data to be written to slave
			data_value := std_logic_vector(to_unsigned(999, 32));
			-- address that is going to be accessed on avalon slave, its sys_time register
			reg_address := "000";   
			-- write data_value from avalon master to slave, via avalon-mm bus
			write_bus(net, avmm_bus, reg_address, data_value);
			
			-- wait for stabilization 
			wait for 60 ns;
			
			-- read from avalon-mm slave
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			report "**************************************** -  Expected sys_time value " 
			   & integer'image(to_integer(unsigned(data_value))) & ", output value was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(data_value = readdata) 
			   report "**************************************** -  Error while Avalon-MM writing to sys_time register." 
			   severity error;
			 
			info("===== TEST CASE FINISHED =====");
			info("=======================================================");
			
		  elsif run("status_check") then
		  
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: write to STATUS register via Avalon-MM");
			info("           after that read from it via Avalon-MM, and check results");
			info("--------------------------------------------------------------------------------");
			 
			wait until rst_i <= '0';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			data_value := std_logic_vector(to_unsigned(3, 32));
			reg_address := "001";
			write_bus(net, avmm_bus, reg_address, data_value);
			wait for 60 ns;
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			report "**************************************** -  Expected status register value " 
			   & integer'image(to_integer(unsigned(data_value))) & ", output value was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(data_value = readdata) 
			   report "**************************************** -  Error while Avalon-MM writing to status register." 
			   severity error;
			 
			info("===== TEST CASE FINISHED =====");
			info("=======================================================");
			
		  elsif run("control_check") then
		  
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: write to CONTROL register via Avalon-MM");
			info("           after that read from it via Avalon-MM, and check results");
			info("--------------------------------------------------------------------------------");
			 
			wait until rst_i <= '0';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			data_value := std_logic_vector(to_unsigned(3, 32));
			reg_address := "010";
			write_bus(net, avmm_bus, reg_address, data_value);
			wait for 60 ns;
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			report "**************************************** -  Expected control register value " 
			   & integer'image(to_integer(unsigned(data_value))) & ", output value was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(data_value = readdata) 
			   report "**************************************** -  Error while Avalon-MM writing to status register." 
			   severity error;
			 
			info("===== TEST CASE FINISHED =====");
			info("=======================================================");
			
		  elsif run("rise_ts_check") then
		  
			info("----------------------------------------------------------------------------------------");
			info("TEST CASE: Make transition on the data_i input so that rising edge occurs ");
			info("           after that read from rise_ts_h and rise_ts_l via Avalon-MM, and check results");
			info("----------------------------------------------------------------------------------------");
			
			-- initial vala on data_i input is zero
			data_i <= '0';
			
			wait until rst_i <= '0';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			-- initial unix time value set to 100 s
			data_value := std_logic_vector(to_unsigned(9999999, 32));
			reg_address := "000";  -- "000" is address of sys_time register
			
			write_bus(net, avmm_bus, reg_address, data_value);
			
			wait for 80 ns; -- 4 cycles is needed for counter to start counting
			
			
			-- rising edge will happen after time_of_rising_edge ns (should be a number dividible by 20)
			time_of_rising_edge := 1234580;
			wait for 1234580 ns;
			data_i <= '1';
			
			-- make sure the output is stabilized, so wait 100 ns and then read
			wait for 100 ns;
			-- reading rise_ts_h register
			reg_address := "101";  -- address of rise_ts_h register
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			info("**************************************************************************************************************");		
			report "********************************************************************* -  Expected unix time value is " 
			   & integer'image(to_integer(unsigned(data_value))) & ", output of rise_ts_h register was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(data_value = readdata) 
			   report "**************************************** -  Error while reading rise_ts_h register. Value doesnt't match" 
			   severity error;
			info("**************************************************************************************************************");	
			
			-- reading rise_ts_l register
			reg_address := "110"; -- address of rise_ts_l register
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			-- convert readdata value to integer and store it to variable ts_value, and the reduce it by 40 ns, because of
			-- input data synchronizer in detection_logic 
			ts_value := to_integer(unsigned(readdata));
			ts_value := ts_value - 40;

			info("**************************************************************************************************************");
			report "********************************************************************* -  Expected nanoseconds time value is " 
			   & integer'image(time_of_rising_edge) & ", output of rise_ts_l register was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(std_logic_vector(to_unsigned(time_of_rising_edge, 32)) = std_logic_vector(to_unsigned(ts_value, 32))) 
			   report "**************************************** -  Error while reading rise_ts_h register. Value doesnt't match" 
			   severity error;
			info("**************************************************************************************************************");
			
			info("===== TEST CASE FINISHED =====");
			info("=======================================================");
			
		  elsif run("fall_ts_check") then
		  
			info("----------------------------------------------------------------------------------------");
			info("TEST CASE: Make transition on the data_i input so that falling edge occurs ");
			info("           after that read from fall_ts_h and fall_ts_l via Avalon-MM, and check results");
			info("----------------------------------------------------------------------------------------");
			
			-- initial vala on data_i input is zero
			data_i <= '0';
			
			wait until rst_i <= '0';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			-- initial unix time value set to 100 s
			data_value := std_logic_vector(to_unsigned(9999999, 32));
			reg_address := "000";  -- "000" is address of sys_time register
			
			write_bus(net, avmm_bus, reg_address, data_value);
			
			wait for 80 ns; -- 4 cycles is needed for counter to start counting
			
			
			-- rising edge will happen after time_of_rising_edge ns (should be a number dividible by 20)
			time_of_rising_edge := 1234580;
			wait for 1234580 ns;
			data_i <= '1';
			
			time_of_falling_edge := 50000;
			wait for 50000 ns;
			data_i <= '0';
			
			-- make sure the output is stabilized, so wait 100 ns and then read
			wait for 100 ns;
			-- reading fall_ts_h register
			reg_address := "011";  -- fall_ts_h register
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			info("**************************************************************************************************************");		
			report "********************************************************************* -  Expected unix time value is " 
			   & integer'image(to_integer(unsigned(data_value))) & ", output of fall_ts_h register was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(data_value = readdata) 
			   report "**************************************** -  Error while reading rise_ts_h register. Value doesnt't match" 
			   severity error;
			info("**************************************************************************************************************");	
			
			-- reading fall_ts_l register
			reg_address := "100"; -- fall_ts_l register
			read_bus(net, avmm_bus, reg_address, read_temp);
			
			-- convert readdata value to integer and store it to variable ts_value, and the reduce it by 40 ns, because of
			-- input data synchronizer in detection_logic 
			ts_value := to_integer(unsigned(readdata));
			ts_value := ts_value - 40;

			info("**************************************************************************************************************");
			report "********************************************************************* -  Expected nanoseconds time value is " 
			   & integer'image(time_of_rising_edge + time_of_falling_edge) & ", output of fall_ts_l register was "
			   & integer'image(to_integer(unsigned(readdata)));
			   
			assert(std_logic_vector(to_unsigned(time_of_rising_edge + time_of_falling_edge, 32)) = std_logic_vector(to_unsigned(ts_value, 32))) 
			   report "**************************************** -  Error while reading rise_ts_h register. Value doesnt't match" 
			   severity error;
			info("**************************************************************************************************************");
			
			info("===== TEST CASE FINISHED =====");
			info("=======================================================");
			
		  end if;
		end loop;
	  
	  test_runner_cleanup(runner);
	  wait;
	  
	end process;
	
                                                                                 
END arch;
