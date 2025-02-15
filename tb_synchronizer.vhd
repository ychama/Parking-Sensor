-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 20.10.2020 21:33:49 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_Synchronizer is
end tb_Synchronizer;

architecture tb of tb_Synchronizer is

    component Synchronizer
        port (clk : in std_logic;
              A   : in std_logic_vector (9 downto 0);
              G   : out std_logic_vector (9 downto 0));
    end component;

    signal clk : std_logic;
    signal A   : std_logic_vector (9 downto 0);
    signal G   : std_logic_vector (9 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : Synchronizer
    port map (clk => clk,
              A   => A,
              G   => G);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        A <= (others => '0');

        -- EDIT Add stimuli here
        wait for 5 * TbPeriod;
		  
		  A <= "1111111111";
        wait for 5 * TbPeriod;
		  A <= "1111100000";
        wait for 5 * TbPeriod;
		  A <= "0000011111";
        wait for 5 * TbPeriod;
		  
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_Synchronizer of tb_Synchronizer is
    for tb
    end for;
end cfg_tb_Synchronizer;