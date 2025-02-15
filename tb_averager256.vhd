-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 15.11.2020 18:54:37 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_averager256 is
end tb_averager256;

architecture tb of tb_averager256 is

    component averager256
        port (clk     : in std_logic;
              EN      : in std_logic;
              reset_n : in std_logic;
              Din     : in std_logic_vector (11 downto 0);
              Q       : out std_logic_vector (11 downto 0));
    end component;

    signal clk     : std_logic;
    signal EN      : std_logic;
    signal reset_n : std_logic;
    signal Din     : std_logic_vector (11 downto 0);
    signal Q       : std_logic_vector (11 downto 0);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
	 
	 Signal counter :              STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	 Signal response_valid_out_i : std_logic;

begin

    dut : averager256
    port map (clk     => clk,
              EN      => EN,
              reset_n => reset_n,
              Din     => Din,
              Q       => Q
				  );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;
	 
    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        EN <= '0';
		  Din(11 downto 3) <= "100011000"; -- upper ADC bits stay the same
		  
        -- Reset generation
        -- EDIT: Check that reset_n is really your reset signal
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;
		  EN <= '1';
		  
        -- EDIT Add stimuli here

         response_valid_out_process: process -- This models a 1 MSps ADC output
         begin                               -- However, your ADC has 25 kHz ADC output
              response_valid_out_i <= '0'; wait for 980 ns;
              response_valid_out_i <= '1'; wait for 20 ns; 
         end process;
        
         ADC_out_process : Process (response_valid_out_i) -- modify the lower 3 ADC bits
         begin
            if rising_edge(response_valid_out_i) then
               Case counter is
                  when "0000" => 
                     Din(2 downto 0) <= "000";
                     counter             <= "0001";
                     
                  when "0001" => 
                     Din(2 downto 0) <= "100";
                     counter             <= "0010";                     
                  
                  when "0010" => 
                     Din(2 downto 0) <= "010";
                     counter             <= "0011";
                  
                  when "0011" => 
                     Din(2 downto 0) <= "000";
                     counter             <= "0100";
                  
                  when "0100" => 
                     Din(2 downto 0) <= "111";
                     counter             <= "0101";
                  
                  when "0101" =>
                     Din(2 downto 0) <= "101";
                     counter             <= "0110";
                  
                  when "0110" => 
                     Din(2 downto 0) <= "011";
                     counter             <= "0111";
                  
                  when "0111" => 
                     Din(2 downto 0) <= "110";
                     counter             <= "1000";
                  
                  when "1000" => 
                     Din(2 downto 0) <= "110";
                     counter             <= "1001";
                  
                  when "1001" => 
                     Din(2 downto 0) <= "101";
                     counter             <= "1011";
                  
                  When others => 
                     Din(2 downto 0) <= "111";
                     counter             <= "0000";
               
               End Case;
            end if;
       End Process;
		  
		  
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
		  assert false report "Simulation ended" severity failure; -- need this line to halt the testbench  
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_averager256 of tb_averager256 is
    for tb
    end for;
end cfg_tb_averager256;