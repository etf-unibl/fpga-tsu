LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  
USE ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library design_lib;

ENTITY tb_interrupt_logic IS
  generic (runner_cfg : string);
END tb_interrupt_logic;

ARCHITECTURE arch OF tb_interrupt_logic IS

  signal interrupt1_i : std_logic;
  signal interrupt2_i : std_logic;
  signal interrupt_en_i : std_logic;
  signal interrupt_o : std_logic;
  
  type test_vector is record 
    int1 : std_logic;
	int2 : std_logic;
	int_en : std_logic;
	int_o : std_logic;
  end record;
  
  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array := (
-- int1, int2, int_en, int_o
    ('0', '0', '0', '0'),
    ('0', '1', '0', '0'),
    ('1', '0', '0', '0'),
    ('1', '1', '0', '0'),
    ('0', '0', '1', '0'),
    ('0', '1', '1', '1'),
    ('1', '0', '1', '1'),
    ('1', '1', '1', '1')
  );
	
  	

BEGIN

  -- interrupt design entity
  interrupt_design : entity design_lib.interrupt_logic port map(
     interrupt1_i => interrupt1_i,
	 interrupt2_i => interrupt2_i,
	 interrupt_en_i => interrupt_en_i,
	 interrupt_o => interrupt_o
  );
  

   process
     
	BEGIN
	  
	  test_runner_setup(runner, runner_cfg);	


        for i in test_vectors'range loop
		
          interrupt1_i <= test_vectors(i).int1;
          interrupt2_i <= test_vectors(i).int2;
          interrupt_en_i <= test_vectors(i).int_en;
		  wait for 20 ns;
		  
		  assert(interrupt_o = test_vectors(i).int_o)
		    report "Error! Interrupt input values are " & std_logic'image(interrupt1_i) & " and " & std_logic'image(interrupt2_i) 
			  & " , and enable input is " & std_logic'image(interrupt_en_i) & ", so output should be " & std_logic'image(test_vectors(i).int_o)
			  & ", but it was " & std_logic'image(interrupt_o)
			severity error;
		end loop;
	
	  test_runner_cleanup(runner);
	  wait;
	  
	end process;
	
                                                                                 
END arch;
