-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 3.12.2020 18:09:12 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level is
end tb_top_level;

architecture tb of tb_top_level is

    component top_level
        port (clk      : in std_logic;
              reset_n  : in std_logic;
              set      : in std_logic;
              SW       : in std_logic_vector (9 downto 0);
              LEDR     : out std_logic_vector (9 downto 0);
              HEX0     : out std_logic_vector (7 downto 0);
              HEX1     : out std_logic_vector (7 downto 0);
              HEX2     : out std_logic_vector (7 downto 0);
              HEX3     : out std_logic_vector (7 downto 0);
              HEX4     : out std_logic_vector (7 downto 0);
              HEX5     : out std_logic_vector (7 downto 0);
              buzz_out : out std_logic);
    end component;

    signal clk      : std_logic;
    signal reset_n  : std_logic;
    signal set      : std_logic;
    signal SW       : std_logic_vector (9 downto 0);
    signal LEDR     : std_logic_vector (9 downto 0);
    signal HEX0     : std_logic_vector (7 downto 0);
    signal HEX1     : std_logic_vector (7 downto 0);
    signal HEX2     : std_logic_vector (7 downto 0);
    signal HEX3     : std_logic_vector (7 downto 0);
    signal HEX4     : std_logic_vector (7 downto 0);
    signal HEX5     : std_logic_vector (7 downto 0);
    signal buzz_out : std_logic;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
	 constant extra_delay : time:= TbPeriod*10000; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : top_level
    port map (clk      => clk,
              reset_n  => reset_n,
              set      => set,
              SW       => SW,
              LEDR     => LEDR,
              HEX0     => HEX0,
              HEX1     => HEX1,
              HEX2     => HEX2,
              HEX3     => HEX3,
              HEX4     => HEX4,
              HEX5     => HEX5,
              buzz_out => buzz_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
		  reset_n <= '0';
		SW <= (others => '1');

			wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;
		set <= '1';
		wait for 1 ms; 
		
		set <= '0'; wait for 1.1 ms; 
		
		SW <= (others => '0'); wait for 20*extra_delay; 
		set <= '1'; sw <= (others => '1'); wait for 1 ms;
		
       wait for 3 ms;
		reset_n <= '0'; 
		wait for 1 ms;
		reset_n <= '1';
		wait for 100 ms;
		wait for 225*extra_delay; 
		
		SW(9 downto 8) <= "01";
				
		wait for 225*extra_delay;

        -- EDIT Add stimuli here
		
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        assert false report "Simulation ended" severity failure; -- need this line to halt the testbench  
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_top_level of tb_top_level is
    for tb
    end for;
end cfg_tb_top_level;