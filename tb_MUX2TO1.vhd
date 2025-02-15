library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_MUX2TO1 IS
END tb_MUX2TO1;

ARCHITECTURE tb of tb_MUX2TO1 is

-- Component Declaration for MUX2T01

   component MUX2TO1 
   port ( in0     : in  std_logic_vector(15 downto 0);
          in1     : in  std_logic_vector(15 downto 0);
          s       : in  std_logic;
          mux_out : out std_logic_vector(15 downto 0) 
         );
   end component;   

	
    signal   s                : std_logic;
    signal   in0,in1, mux_out : std_logic_vector(15 downto 0);
    constant time_delay       : time := 20 ns;
    
    
    begin
    -- Instantiate the Unit Under Test (UUT)
    dut: MUX2TO1 port map ( 
	        in0     => in0,
           in1     => in1,
           s       => s,
           mux_out => mux_out 
          );
 
            
    -- Stimulus process 
      stimuli : process -- this process, in testbench/simulation code, is different than in design code
      begin
		  assert false report "MUX2TO1 testbench started"; -- puts a note in the ModelSim transcript window (this line is just for convenience)
		  wait for time_delay;
		  in0 <= "0000000000000000"; in1 <= "0000000000000000"; wait for time_delay;
		  s <= '0'; wait for time_delay;
		  in0 <= "0101010101010101"; in1 <= "1010101010101010"; wait for time_delay;
		  in0 <= "1010101010101010"; in1 <= "0101010101010101"; wait for time_delay;
		  s <= '1'; wait for time_delay;
		  in0 <= "0101010101010101"; in1 <= "1010101010101010"; wait for time_delay;
		  s <= '0'; wait for time_delay; -- this extends the time by 10x the time_delay, for ease of veiwing waveforms
		  assert false report "MUX2TO1 testbench completed"; -- puts a note in the ModelSim transcript window (this line is just for convenience)
        wait;	-- this wait without any time parameters just stops the simulation, otherwise it would repeat forever starting back at the top  
	   end process;  
 
end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_MUX2TO1 of tb_MUX2TO1 is
    for tb
    end for;
end cfg_tb_MUX2TO1;
