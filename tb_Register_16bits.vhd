library ieee;
use ieee.std_logic_1164.all;

entity tb_Register_16bits is
end tb_Register_16bits;

architecture tb of tb_Register_16bits is

    component Register_16bits
        port (clk     : in std_logic;
              reset_n : in std_logic;
              enable  : in std_logic;
              D       : in std_logic_vector (15 downto 0);
              Q       : out std_logic_vector (15 downto 0));
    end component;

    signal clk     : std_logic;
    signal reset_n : std_logic;
    signal enable  : std_logic;
    signal D       : std_logic_vector (15 downto 0);
    signal Q       : std_logic_vector (15 downto 0);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : Register_16bits
    port map (clk     => clk,
              reset_n => reset_n,
              enable  => enable,
              D       => D,
              Q       => Q);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        enable <= '0';
        D <= (others => '0');

        -- Reset generation
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;
	
        -- testing that Q doesn't change when enable = 1
		  enable <= '1';
        D <= X"FFFF"; 	wait for 10 * TbPeriod;
		  D <= X"F0F0"; 	wait for 10 * TbPeriod;
		  D <= X"0F0F"; 	wait for 10 * TbPeriod;
		  D <= X"0000"; 	wait for 10 * TbPeriod;
		  reset_n <= '0'; wait for 10 * TbPeriod;
		  reset_n <= '1'; wait for 10 * TbPeriod;
		  -- testing that Q changes when enable = 0
		  enable <= '0';
        D <= X"FFFF"; 	wait for 10 * TbPeriod;
		  D <= X"F0F0"; 	wait for 10 * TbPeriod;
		  D <= X"0F0F"; 	wait for 10 * TbPeriod;
		  reset_n <= '0'; wait for 10 * TbPeriod;
		  reset_n <= '1'; wait for 10 * TbPeriod;
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_Register_16bits of tb_Register_16bits is
    for tb
    end for;
end cfg_tb_Register_16bits;

