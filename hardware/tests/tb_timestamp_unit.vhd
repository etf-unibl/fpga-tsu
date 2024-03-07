LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

library design_lib;

ENTITY tb_timestamp_unit IS
  generic (runner_cfg : string);
END tb_timestamp_unit;

ARCHITECTURE arch OF tb_timestamp_unit IS

  signal data_i          : std_logic := '0';
  signal clk_i           : std_logic := '0';
  signal rst_i           : std_logic := '0';
  signal read            : std_logic := '0';
  signal write           : std_logic := '0';
  signal address 	     : std_logic_vector(3 downto 0) := (others => '0');
  signal writedata       : std_logic_vector(31 downto 0):= (others => '0');
  signal readdata        : std_logic_vector(31 downto 0):= (others => '0');
  signal byteenable      : std_logic_vector(3 downto 0) := (others => '0');
  signal waitrequest     : std_logic := '0';
  signal burstcount      : std_logic_vector(1 downto 0) := (others => '0');
  signal readdatavalid   : std_logic := '0';
  signal readdata_master : std_logic_vector(31 downto 0);
  signal response_o      : std_logic_vector(1 downto 0);
  signal interrupt_o     : std_logic;

  -- instantiate Avalon-MM bus master verification component
  constant avmm_bus : bus_master_t := new_bus(
    data_length       => 32,
    address_length => 4,
    logger => get_logger("avmm_bus")
  );

BEGIN
  -- AvalonMM slave dut
  dut : entity design_lib.timestamp_unit port map(
    data_i      => data_i,
    clk_i       => clk_i,
    rst_i       => rst_i,
    read_i      => read,
    write_i     => write,
    address_i   => address,
    writedata_i => writedata,
    readdata_o  => readdata,
    interrupt_o => interrupt_o,
    response_o  => response_o
  );
  
  -- AvalonMM master which signals AvalonMM slave dut, via AvalonMM bus
  avmm_master : entity vunit_lib.avalon_master
    generic map(
      bus_handle        => avmm_bus,
      use_readdatavalid => false
    )
    port map(
      clk           => clk_i,
      address       => address,
      write         => write,
      writedata     => writedata,
      read          => read,
      readdata      => readdata_master,
      byteenable    => byteenable,
      waitrequest   => waitrequest,
      burstcount    => burstcount,
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
    variable read_temp            : std_logic_vector(31 downto 0) := (others => '0');
    variable data_value           : std_logic_vector(31 downto 0) := (others => '0');
    variable reg_address          : std_logic_vector(3 downto 0)  := (others => '0');
    variable time_of_rising_edge  : integer;
    variable time_of_falling_edge : integer;
    variable ts_value             : integer := 0;
	variable exp_read_value           : std_logic_vector(31 downto 0) := (others => '0');
	
  begin
    test_runner_setup(runner, runner_cfg);
    test_case_loop : while test_suite loop

		if run("data_input_read_fifo") then
		
			  info("--------------------------------------------------------------------------------");
			  info("TEST CASE read/write fifo buffers:");
			  info("");
			  info("--------------------------------------------------------------------------------");

			  -- wait until reset is clear and rising edge of the clock is occured
			  wait until rst_i <= '0';
			  wait until rising_edge(clk_i);
			  -- wait for falling edge
			  wait for 10 ns;

			  -- unix_value to be written into slave
			  data_value := std_logic_vector(to_unsigned(10, 32));
			  -- address of sys_time register
			  reg_address := "0000";
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 60 ns;-- wait for stabilization

			  -- control register - setting interrupt enable flag and start_enable flag
			  -- disable software reset
			  reg_address := "0010";
			  data_value  := "00000000000000000000000000000011";
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 100 ns;

			  -- get some random digital wave to data_i
			  data_i <= '0';

			  wait for 100 us;
			  data_i <= '1';

			  wait for 60 us;
			  data_i <= '0';

			  wait for 20 us;
			  data_i <= '1';

			  wait for 50 us;
			  data_i <= '0';
			  
			  -- read from fifo_buffer
			  wait for 1 us;

			  for i in 0 to 1 loop
			  
				info("************************RISING_EDGE*********************************************");
			  
				-- read unix_time of rising edge
				reg_address := "1010";
				wait for 10 ns;
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO rising edge UNIX time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				-- read nanosecond time of rising edge
				reg_address := "1011";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO rising edge nanoseconds time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				info("************************FALLING_EDGE*********************************************");
				
				-- read unix time of falling edge
				reg_address := "1000";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO falling edge UNIX time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				-- read nanoseconds time of falling edge
				reg_address := "1001";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO falling edge nanoseconds time : " & integer'image(to_integer(unsigned(readdata)));
				
				wait for 100 ns;
			  end loop;
			  
			  
			  -------------------------------------------
			  -- again
			  data_i <= '0';

			  wait for 100 us;
			  data_i <= '1';

			  wait for 60 us;
			  data_i <= '0';

			  wait for 20 us;
			  data_i <= '1';

			  wait for 50 us;
			  data_i <= '0';
			  
					-- read from fifo_buffer
			  wait for 1 us;

			  for i in 0 to 1 loop
			  
				info("************************RISING_EDGE*********************************************");
			  
				-- read unix_time of rising edge
				reg_address := "1010";
				wait for 10 ns;
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO rising edge UNIX time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				-- read nanosecond time of rising edge
				reg_address := "1011";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO rising edge nanoseconds time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				info("************************FALLING_EDGE*********************************************");
				
				-- read unix time of falling edge
				reg_address := "1000";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO falling edge UNIX time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				-- read nanoseconds time of falling edge
				reg_address := "1001";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO falling edge nanoseconds time : " & integer'image(to_integer(unsigned(readdata)));
				
				wait for 100 ns;
			  end loop;
		  
		  

		elsif run("overflow_fifo_buffers") then
		
			  info("--------------------------------------------------------------------------------");
			  info("TEST CASE: overflow fifo buffers");
			  info("");
			  info("--------------------------------------------------------------------------------");

			  -- wait until reset is clear and rising edge of the clock is occured
			  wait until rst_i <= '0';
			  wait until rising_edge(clk_i);
			  -- wait for falling edge
			  wait for 10 ns;

			  -- address of sys_time register
			  reg_address := "0000";   
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 60 ns;-- wait for stabilization 

			  -- control register - setting interrupt enable flag and start_enable flag
			  -- disable software reset
			  reg_address := "0010";
			  data_value  := "00000000000000000000000000000011";
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 100 ns;

			  -- send values to data_i input which will fill the buffers
			  for j in 0 to 34 loop
				wait for 10 us;
				data_i <= '1';
				wait for 10 us;
				data_i <= '0';
			  end loop;

			  report "************************************************************* - Interrupt value is " & std_logic'image(interrupt_o);
			  wait for 100 ns;

			  reg_address := "0001"; -- status
			  read_bus(net, avmm_bus, reg_address, read_temp);
			  report "************************************************************* - status register read fifo full flag -> " & std_logic'image(readdata(2));
			  wait for 100 ns;

			  -- writing to status register via Avalon-MM to clear fifo_full flag
			  data_value := std_logic_vector(to_unsigned(2, 32));
			  write_bus(net, avmm_bus, reg_address, data_value);
			  
			  -- read status fifo_full flag (should be 0)
			  wait for 30 ns;
			  read_bus(net, avmm_bus, reg_address, read_temp);
			  report "************************************************************* - After clearing status fifo_full flag : ";
			  report "************************************************************* - status register read fifo full flag -> " & std_logic'image(readdata(2));
			  
			  -- read status fifo_full flag again, it should be back to 1 since fifo is still full
			  wait for 30 ns;
			  read_bus(net, avmm_bus, reg_address, read_temp);
			  report "************************************************************* - After one cycle fifo_full flag will be set again, because fifo is still full : ";
			  report "************************************************************* - status register read fifo full flag -> " & std_logic'image(readdata(2));

		elsif run("empty_fifo_buffer") then
			  info("--------------------------------------------------------------------------------");
			  info("TEST CASE: Empty fifo buffer");
			  info("");
			  info("--------------------------------------------------------------------------------");

			  -- wait until reset is clear and rising edge of the clock is occured
			  wait until rst_i <= '0';
			  wait until rising_edge(clk_i);
			  -- wait for falling edge
			  wait for 10 ns;

			  -- unix_value to be written into slave
			  data_value := std_logic_vector(to_unsigned(999, 32));
			  -- address of sys_time register
			  reg_address := "0000";   
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 60 ns;-- wait for stabilization 

			  -- control register - setting interrupt enable flag and start_enable flag
			  -- disable software reset
			  reg_address := "0010";
			  data_value  := "00000000000000000000000000000011";
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 100 ns;

			  -- #1 FIFO BUFFER
			  info("************************rise_ts_h_fifo*********************************************");
			  reg_address := "1010";
			  wait for 10 ns;
			  read_bus(net, avmm_bus, reg_address, read_temp); -- trying to read from empty buffer
			  
			  report "                                                 - fifo buffer rise_ts_h_fifo read value -> " 
				  & integer'image(to_integer(unsigned(readdata)));
			  
			  -- check to see if it is empty
			  exp_read_value := (others => '0');
			  assert(readdata = exp_read_value) 
				 report "                                              Error. rise_ts_h_fifo should be empty, but read value is " 
				   & integer'image(to_integer(unsigned(readdata)))
				 severity error;
			  
			  wait for 10 ns;
			  
			  -- read status register
			  reg_address := "0001"; -- address status reg
			  read_bus(net, avmm_bus, reg_address, read_temp); 
			  -- checking fifo empty flag
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                 - status register read fifo empty flag -> " & std_logic'image(readdata(1));
			  report "                                                 - Interrupt value is " & std_logic'image(interrupt_o);
			  
			  wait for 100 ns;


			  -- set empty_fifo flag to 0
			  data_value  := (others => '0');
			  write_bus(net, avmm_bus, reg_address, data_value); -- reset all flags to 0
			  wait for 100 ns;


			  -- read status register again
			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  info(" Now we can clear empty_flag via Avalon_MM and wait some time. Because fifo is still empty it should be set again");
			  -- check
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                  - status register read fifo empty flag  -> " & std_logic'image(readdata(1));
			  wait for 100 ns;

			  -- #2 FIFO BUFFER
			  info("************************rise_ts_l_fifo*********************************************");
			  reg_address := "1011";
			  wait for 10 ns;
			  read_bus(net, avmm_bus, reg_address, read_temp); -- trying to read from empty buffer
			  
			  report "                                                 - fifo buffer rise_ts_l_fifo read value -> " 
				  & integer'image(to_integer(unsigned(readdata)));
			  -- check to see if it is empty
			  exp_read_value := (others => '0');
			  assert(readdata = exp_read_value) 
				 report "                                              Error. rise_ts_l_fifo should be empty, but read value is " 
				   & integer'image(to_integer(unsigned(readdata)))
				 severity error;
			  
			  wait for 10 ns;
			  reg_address := "0001"; -- address status reg
			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                 - status register read fifo empty flag -> " & std_logic'image(readdata(1));
			  wait for 100 ns;

			  data_value  := (others => '0');
			  write_bus(net, avmm_bus, reg_address, data_value); -- reset all flags to 0
			  wait for 100 ns;

			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  info(" Now we can clear empty_flag via Avalon_MM and wait some time. Because fifo is still empty it should be set again");
			  -- check
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                  - status register read fifo empty flag  -> " & std_logic'image(readdata(1));
			  report "                                                  - Interrupt value is " & std_logic'image(interrupt_o);
			  wait for 100 ns;

			  -- #3 FIFO BUFFER
			  info("************************fall_ts_h_fifo*********************************************");
			  reg_address := "1000";
			  wait for 10 ns;
			  read_bus(net, avmm_bus, reg_address, read_temp); -- trying to read from empty buffer
			  
			  report "                                                 - fifo buffer fall_ts_h_fifo read value -> " 
				  & integer'image(to_integer(unsigned(readdata)));
			  -- check to see if it is empty
			  exp_read_value := (others => '0');
			  assert(readdata = exp_read_value) 
				 report "                                              Error. fall_ts_h_fifo should be empty, but read value is " 
				   & integer'image(to_integer(unsigned(readdata)))
				 severity error;
			  
			  wait for 10 ns;
			  reg_address := "0001"; -- address status reg
			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                 - status register read fifo empty flag -> " & std_logic'image(readdata(1));
			  wait for 100 ns;

			  data_value  := (others => '0');
			  write_bus(net, avmm_bus, reg_address, data_value); -- reset all flags to 0
			  wait for 100 ns;

			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  info(" Now we can clear empty_flag via Avalon_MM and wait some time. Because fifo is still empty it should be set again");
			  -- check
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                  - status register read fifo empty flag  -> " & std_logic'image(readdata(1));
			  report "                                                  - Interrupt value is " & std_logic'image(interrupt_o);
			  wait for 100 ns;
			
			  -- #4 FIFO BUFFER
			  info("************************fall_ts_l_fifo*********************************************");
			  reg_address := "1001";
			  wait for 10 ns;
			  read_bus(net, avmm_bus, reg_address, read_temp); -- trying to read from empty buffer
			  
			  report "                                                 - fifo buffer fall_ts_l_fifo read value -> " 
				  & integer'image(to_integer(unsigned(readdata)));
			  -- check to see if it is empty
			  exp_read_value := (others => '0');
			  assert(readdata = exp_read_value) 
				 report "                                              Error. fall_ts_l_fifo should be empty, but read value is " 
				   & integer'image(to_integer(unsigned(readdata)))
				 severity error;
			  
			  wait for 10 ns;
			  reg_address := "0001"; -- address status reg
			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                 - status register read fifo empty flag -> " & std_logic'image(readdata(1));
			  wait for 100 ns;

			  data_value  := (others => '0');
			  write_bus(net, avmm_bus, reg_address, data_value); -- reset all flags to 0
			  wait for 100 ns;

			  read_bus(net, avmm_bus, reg_address, read_temp); -- read status reg
			  -- checking fifo empty flag
			  info(" Now we can clear empty_flag via Avalon_MM and wait some time. Because fifo is still empty it should be set again");
			  -- check
			  assert(readdata(1) = '1') 
				report "                                                 Error with status register empty_flag. Expected '1', actual " & std_logic'image(readdata(1));
			  
			  -- print report in case there is no error
			  report "                                                  - status register read fifo empty flag  -> " & std_logic'image(readdata(1));
			  report "                                                  - Interrupt value is " & std_logic'image(interrupt_o);
			  
			  wait for 100 ns;

		elsif run("software_reset") then
		
			  info("--------------------------------------------------------------------------------");
			  info("TEST CASE: Check software reset");
			  info("");
			  info("--------------------------------------------------------------------------------");

			  -- wait until reset is clear and rising edge of the clock is occured
			  wait until rst_i <= '0';
			  wait until rising_edge(clk_i);
			  -- wait for falling edge
			  wait for 10 ns;

			  -- unix_value to be written into slave
			  data_value := std_logic_vector(to_unsigned(10, 32));
			  -- address of sys_time register
			  reg_address := "0000";
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 60 ns;-- wait for stabilization

			  -- control register - setting interrupt enable flag and start_enable flag
			  -- disable software reset
			  reg_address := "0010";
			  data_value  := "00000000000000000000000000000011";
			  write_bus(net, avmm_bus, reg_address, data_value);
			  wait for 100 ns;

			  -- get some random digital wave to data_i
			  data_i <= '0';

			  wait for 100 us;
			  data_i <= '1';

			  wait for 60 us;
			  data_i <= '0';

			  wait for 20 us;
			  data_i <= '1';

			  wait for 50 us;
			  data_i <= '0';
			  
			  -- read from fifo_buffer
			  wait for 1 us;
			  
			  ---- SOFTWARE RESET ------------
			  
			  
			  -- address of control register
			  reg_address := "0010";
			  -- set software_reset flag
			  data_value := "00000000000000000000000000000111";
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  
			  wait for 60 ns;
			  
			  
			  -- address of control register
			  reg_address := "0010";
			  -- set software_reset flag
			  data_value := "00000000000000000000000000000010";
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  
			  
			  
			  
			  ---- READ FROM FIFOs --------------
			 
			  for i in 0 to 1 loop
			  
				info("************************RISING_EDGE*********************************************");
			  
				-- read unix_time of rising edge
				reg_address := "1010";
				wait for 10 ns;
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO rising edge UNIX time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				-- read nanosecond time of rising edge
				reg_address := "1011";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO rising edge nanoseconds time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				info("************************FALLING_EDGE*********************************************");
				
				-- read unix time of falling edge
				reg_address := "1000";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO falling edge UNIX time : " & integer'image(to_integer(unsigned(readdata)));
				wait for 100 ns;

				-- read nanoseconds time of falling edge
				reg_address := "1001";
				read_bus(net, avmm_bus, reg_address, read_temp);
				report "************************************************ -  FIFO falling edge nanoseconds time : " & integer'image(to_integer(unsigned(readdata)));
				
				wait for 100 ns;
			  end loop;		 

		elsif run("avalon_error_handle") then
		
			  info("--------------------------------------------------------------------------------");
			  info("TEST CASE: Check avalon error handling");
			  info("");
			  info("--------------------------------------------------------------------------------");

			  -- wait until reset is clear and rising edge of the clock is occured
			  wait until rst_i <= '0';
			  wait until rising_edge(clk_i);
			  -- wait for falling edge
			  wait for 10 ns;
			  
			  -- unknown address
			  reg_address := "1111";
			  -- some random data
			  data_value := "00000001000010000000000000000111";
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  
			  wait for 40 ns;
			  
			  assert(response_o = "11") report "Error in Avalon-MM error handling. Expected response_o value is 11, but it was " 
			    & std_logic'image(response_o(1)) & std_logic'image(response_o(0)) 
				severity error;
			  
			 wait for 100 ns;
			  
			 --------------------------------------------------- 
			 -- check situation when trying to write into read_only register
			 
			  wait until rising_edge(clk_i);
			  -- wait for falling edge
			  wait for 10 ns;
			  
			  -- unknown address
			  reg_address := "1000"; -- fall_ts_h_fifo
			  -- some random data
			  data_value := "10010001000010000000000000000111";
			  -- write data_value from avalon master to slave, via avalon-mm bus
			  write_bus(net, avmm_bus, reg_address, data_value);
			  
			  wait for 40 ns;
			  
			  assert(response_o = "10") report "Error in Avalon-MM error handling. Expected response_o value is 10, but it was " 
			    & std_logic'image(response_o(1)) & std_logic'image(response_o(0)) 
				severity error;

      end if;
    end loop;
	
    test_runner_cleanup(runner);
    wait;

  end process;
END arch;
