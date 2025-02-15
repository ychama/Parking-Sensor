-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 10.11.2020 18:45:19 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_blank_select is
end tb_blank_select;

architecture tb of tb_blank_select is

    component blank_select
        port (
				  state		: in std_logic_vector (1 downto 0);
				  num1      : in std_logic_vector (3 downto 0);
              num2      : in std_logic_vector (3 downto 0);
              blank_out : out std_logic_vector (5 downto 0));
    end component;

	 signal state		: std_logic_vector (1 downto 0);
    signal num1      : std_logic_vector (3 downto 0);
    signal num2      : std_logic_vector (3 downto 0);
    signal blank_out : std_logic_vector (5 downto 0);

begin

    dut : blank_select
    port map (
				  state		=> state,
				  num1      => num1,
              num2      => num2,
              blank_out => blank_out);

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        num1 <= (others => '0');						-- setting num1 to 0
        num2 <= (others => '0');						-- setting num2 to 0
		  state <= "11";
		  wait for 1000 ns;								-- should blank LEDs 6-3 (111100)
		  num2 <= (others => '1');						-- setting num2 to 1
		  wait for 1000 ns;								-- should blank LEDs 6-4 (111000)
		  state <= "01";
		  wait for 1000 ns;
		  num1 <= (others => '1');						-- setting num1 to 1
		  wait for 1000 ns;
		  state <= "11";
		  wait for 1000 ns;
		  
																-- should blank LEDs 6-5 (110000)
        -- EDIT Add stimuli here						

			assert false report "Simulation ended" severity failure; -- need this line to halt the testbench  
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_blank_select of tb_blank_select is
    for tb
    end for;
end cfg_tb_blank_select;