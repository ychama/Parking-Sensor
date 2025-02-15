-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 26.11.2020 18:09:36 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_downcounter is
end tb_downcounter;

architecture tb of tb_downcounter is

    component downcounter
        port (clk     : in std_logic;
              reset_n : in std_logic;
              enable  : in std_logic;
              zero    : out std_logic;
				  period  : in integer);
    end component;

    signal clk     : std_logic;
    signal reset_n : std_logic;
    signal enable  : std_logic;
    signal zero    : std_logic;
	 signal period  : integer;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : downcounter
    port map (clk     => clk,
              reset_n => reset_n,
              enable  => enable,
              zero    => zero,
				  period   => period);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        enable <= '0';

        -- Reset generation
        -- EDIT: Check that reset_n is really your reset signal
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;
			period <= 1000; wait for 100 * TbPeriod; 
        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;
		  enable <= '1';
		  wait for 10000 * TbPeriod;
		  enable <= '0';
		  wait for 10000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_downcounter of tb_downcounter is
    for tb
    end for;
end cfg_tb_downcounter;