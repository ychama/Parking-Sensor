-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 8.12.2020 19:56:06 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_module is
end tb_module;

architecture tb of tb_module is

    component module
        port (reset_n  : in std_logic;
              clk      : in std_logic;
              distance : in std_logic_vector (12 downto 0);
              output   : out std_logic);
    end component;

    signal reset_n  : std_logic;
    signal clk      : std_logic;
    signal distance : std_logic_vector (12 downto 0);
    signal output   : std_logic;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
	 constant extra_delay : time:= TbPeriod*10000; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : module
    port map (reset_n  => reset_n,
              clk      => clk,
              distance => distance,
              output   => output);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        distance <= (others => '0');

        -- Reset generation
        -- EDIT: Check that reset_n is really your reset signal
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;

         distance <= "0111111111111"; wait for 421ms; -- 4095mm distance 
		  
		  distance <= "0010111011100"; wait for 800ms; -- 1500mm distance
		 
		  distance <= "0000110010000"; wait for 400ms; -- 400mm distance

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_module of tb_module is
    for tb
    end for;
end cfg_tb_module;