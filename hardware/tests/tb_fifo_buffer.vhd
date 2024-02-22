LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;    

library vunit_lib;
context vunit_lib.vunit_context;       

library design_lib;                    

ENTITY tb_fifo_buffer IS
  generic (runner_cfg : string);
END tb_fifo_buffer;

ARCHITECTURE fifo_buffer_arch OF tb_fifo_buffer IS
-- constants                                                 
	-- signals                                                   
	SIGNAL clk_i : STD_LOGIC;
	SIGNAL data_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL empty_o : STD_LOGIC;
	SIGNAL fill_count_o : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL full_o : STD_LOGIC;
	SIGNAL rden_i : STD_LOGIC;
	SIGNAL rdvalid_o : STD_LOGIC;
	SIGNAL rst_i : STD_LOGIC;
	SIGNAL wren_i : STD_LOGIC;
	
	constant FIFO_SIZE : natural := 32;
	constant DATA_WIDTH : natural := 32;

BEGIN
	fifo : entity design_lib.fifo_buffer
	generic map(
	  g_RAM_WIDTH => DATA_WIDTH,
	  g_RAM_DEPTH => FIFO_SIZE
	)
	PORT MAP (
-- list connections between master ports and signals
	clk_i => clk_i,
	data_i => data_i,
	data_o => data_o,
	empty_o => empty_o,
	fill_count_o => fill_count_o,
	full_o => full_o,
	rden_i => rden_i,
	rdvalid_o => rdvalid_o,
	rst_i => rst_i,
	wren_i => wren_i
	);
	
	-- clock generator
	process
	begin
	  for i in 0 to 1000 loop
		clk_i <= '0';
		 wait for 10 ns;
		 clk_i <= '1';
		 wait for 10 ns;
	  end loop;
	wait;
	end process;
	
	always : PROCESS         
	
	BEGIN    
	  -- code executes for every event on sensitivity list  
	  
	  test_runner_setup(runner, runner_cfg);
	  	
	  rst_i <= '0';
	  data_i <= "00000000000000000000000000000000";
	  rden_i <= '0';
	  wren_i <= '0';
	  
	  wait for 20 ns;
	  
	  -- write values from 0 to 30 into the buffer (31 values)
	  info("Writing values into the buffer ...");
	  wren_i <= '1';
	  for i in 0 to FIFO_SIZE - 2 loop
        data_i <= std_logic_vector(to_unsigned(i, 32));
		report "                                           " & integer'image(to_integer(unsigned(data_i)));
	    wait for 20 ns;
	    assert(fill_count_o = std_logic_vector(to_unsigned(i + 1, 5))) 
	      report "Error fill_count; Expected: " & integer'image(i + 1) & ", Actual: " & integer'image(to_integer(unsigned(fill_count_o))) 
		  severity failure;
	  end loop;
	  report "                                           " & integer'image(to_integer(unsigned(data_i)));
	  info("Writing ended");
	  
	  
	  -- buffer should be full, check if that is correct
	  assert(full_o = '1') report "Error full_o; Expected '1'; Actual: '0'" severity failure;
	  report "                                           Buffer is full, number of elementes in buffer is " 
	    & integer'image(to_integer(unsigned(fill_count_o)));
	  info("==========================================================================================================================");
	  
	  
	  -- once the buffer is full, and we keep writing to it, old data will be overwritten
	  -- we will overwrite first 15 positions, with values from 31 to 45
	  info("Keep writing into the buffer to overwrite old data, we will overwrite half of the data");
	  for i in FIFO_SIZE - 1 to (FIFO_SIZE - 2) + (FIFO_SIZE - 2) / 2  loop
		data_i <= std_logic_vector(to_unsigned(i, 32));
		report "                                           "  & integer'image(to_integer(unsigned(data_i)));
		 wait for 20 ns;
		 -- buffer number of elements should be 31 all the time
		 assert(fill_count_o = "11111") 
		   report "Error fill_count; Expected: 31; Actual: " & integer'image(to_integer(unsigned(fill_count_o))) 
		   severity failure;
		 -- buffer should be full all the time
		 assert(full_o = '1') 
		   report "Error full_o; Expected 1; Actual: " & std_logic'image(full_o) 
		   severity failure;
	  end loop;
	  report "                                           " & integer'image(to_integer(unsigned(data_i)));
	  info("After overwriting old data...");
	  report "                                           Buffer is full, number of elementes in buffer is " 
	      & integer'image(to_integer(unsigned(fill_count_o)));
	  info("==========================================================================================================================");
	  
	  -- read buffer
	  -- now tail is same as head, and we first read values of index from the 16 to 30
	  info("Reading half of the buffer that was not overwritten");
	  wren_i <= '0';
	  rden_i <= '1';
	  for i in 0 to (FIFO_SIZE - 2) / 2 loop
		 wait for 20 ns;
		 report "                                           "  & integer'image(to_integer(unsigned(data_o)));
		 assert(data_o = std_logic_vector(to_unsigned(i + 15, 32))) 
		   report "Error data_o; Expected: " & integer'image(i + 15) & "; Actual: " & integer'image(to_integer(unsigned(data_o))) 
		   severity failure;
		 assert(rdvalid_o = '1') 
		   report "Error rdvalid_o; Expected: '1'; Actual: '0'" 
		   severity failure;
	  end loop;
	  report "                                           "  & integer'image(to_integer(unsigned(data_o)));
	  report "                                           Buffer is not full anymore, number of elementes in buffer is " 
	      & integer'image(to_integer(unsigned(fill_count_o)));
	  info("==========================================================================================================================");
	  

	  info("Reading the other half ...");
	  -- read other values from the buffer
	  -- these are the values, that overwrote old values, that is numbers 31 to 45
	  for i in FIFO_SIZE - 1 to (FIFO_SIZE - 2) + (FIFO_SIZE - 2) / 2 loop
		 wait for 20 ns;
		 report "                                           "  & integer'image(to_integer(unsigned(data_o)));
		 assert(data_o = std_logic_vector(to_unsigned(i, 32))) 
		   report "Error data_o; Expected: " & integer'image(i) & "; Actual: " & integer'image(to_integer(unsigned(data_o))) 
		   severity failure;
		 assert(rdvalid_o = '1') 
		   report "Error rdvalid_o; Expected: '1'; Actual: '0'" 
		   severity failure;
	  end loop;
	  report "                                           "  & integer'image(to_integer(unsigned(data_i)));
   	  report "                                           Buffer is now empty, number of elementes in the buffer is " 
	      & integer'image(to_integer(unsigned(fill_count_o)));
	  info("==========================================================================================================================");
	  
	  	  
	  -- fifo should be empty now
	  assert(empty_o = '1') report "Error empty_o; Expected: '1' Actual '0';" severity failure;
	  
	  -- checking if fill_count works correctly
	  rden_i <= '0';
	  wren_i <= '1';
	  for i in 0 to 30 loop
		data_i <= std_logic_vector(to_unsigned(i, 32));
		 wait for 20 ns;
		 assert(fill_count_o = std_logic_vector(to_unsigned(i + 1, 5))) 
		   report "Error fill_count; Expected: " & integer'image(i + 1) & ", Actual: " & integer'image(to_integer(unsigned(fill_count_o))) 
		   severity failure;
	  end loop;
	  
	  -- checking if rst_i works
	  rden_i <= '1';
	  wren_i <= '0';
	  rst_i <= '1';
	  wait for 20 ns;
	  rst_i <= '0';
	  wait for 20 ns;
	  assert(fill_count_o = "00000") 
	    report "Error fill_count; Expected: 0; Actual: " & integer'image(to_integer(unsigned(fill_count_o))) 
		severity failure;
	  assert(rdvalid_o = '0') report "Error rdvalid_o; Expected: '0'; Actual: '1'" severity failure;

	test_runner_cleanup(runner);

	WAIT;                                                        
	END PROCESS always;  
	
END fifo_buffer_arch;