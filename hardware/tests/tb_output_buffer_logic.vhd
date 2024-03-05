LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library design_lib;

ENTITY tb_output_buffer_logic IS
    generic (runner_cfg : string);
END tb_output_buffer_logic;

ARCHITECTURE arch OF tb_output_buffer_logic IS
	-- constants                                                 
	-- signals                                                   
	SIGNAL clk_i : STD_LOGIC;
	SIGNAL rst_i : STD_LOGIC;
	SIGNAL en_i : STD_LOGIC;
	SIGNAL empty_i : STD_LOGIC;
	SIGNAL read_i : STD_LOGIC;
	SIGNAL rden_o : STD_LOGIC; 
	
	BEGIN
		i1 : entity design_lib.output_buffer_logic
		PORT MAP (
	-- list connections between master ports and signals
		clk_i => clk_i,
		rst_i => rst_i,
		en_i => en_i,
		empty_i => empty_i,
		read_i => read_i,
		rden_o => rden_o
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
	variable unix_value_increment : std_logic_vector(31 downto 0);
	
	BEGIN
	  test_runner_setup(runner, runner_cfg);
	  
		  
			info("--------------------------------------------------------------------------------");
			info("TEST CASE: set unix time to some initial value");
			info("--------------------------------------------------------------------------------");
			 
			wait until rst_i <= '0';
			wait until rising_edge(clk_i);
			wait for 10 ns;
			
			empty_i <= '1';
			wait for 60 ns;
			
			
			report "**************************************** -  Expected output value is 0" 
			   & ", output value was " & std_logic'image(rden_o);
			   
			assert(rden_o = '0') 
			   report "**************************************** -  Error when fifo buffer empty." 
			   severity error;
			   
			-------------------------------------------------------------------------------------

			empty_i <= '0';
			read_i <= '1';
			en_i <= '0';
			wait for 20 ns;
			
			report "**************************************** -  Expected output value is 0" 
			   & ", output value was " & std_logic'image(rden_o);
			   
			assert(rden_o = '0') 
			   report "**************************************** -  Error when read_i is set, but en_i is not" 
			   severity error;
			   
			----------------------------------------------------------------------------------   
			
			read_i <= '1';
			en_i <= '1';
			wait for 20 ns;
			
			report "**************************************** -  Expected output value is 1" 
			   & ", output value was " & std_logic'image(rden_o);
			   
			assert(rden_o = '1') 
			   report "**************************************** -  Error when read_i is set, and en_i is also set" 
			   severity error;
			   
			   
			--------------------------------------------------------------------------------------------
			
			read_i <= '1';
			en_i <= '1';
			empty_i <= '1';
			wait for 20 ns;
			
			report "**************************************** -  Expected output value is 0" 
			   & ", output value was " & std_logic'image(rden_o);
			   
			assert(rden_o = '0') 
			   report "**************************************** -  Error when read_i is set, en_i is set, but fifo buffer is empty" 
			   severity error;
			
			
			
			 
			info("===== TEST CASE FINISHED =====");
			info("=======================================================");

		  
	  test_runner_cleanup(runner);
	  WAIT;                                                        
	END PROCESS always;                                         
END arch;
