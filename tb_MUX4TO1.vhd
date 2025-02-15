-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 22.10.2020 17:02:28 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_MUX4TO1 is
end tb_MUX4TO1;

architecture tb of tb_MUX4TO1 is

    component MUX4TO1
        port (in0     : in std_logic_vector (15 downto 0);
              in1     : in std_logic_vector (15 downto 0);
              in2     : in std_logic_vector (15 downto 0);
              in3     : in std_logic_vector (15 downto 0);
              s       : in std_logic_vector (1 downto 0);
              mux_out : out std_logic_vector (15 downto 0));
    end component;

    signal in0     : std_logic_vector (15 downto 0);
    signal in1     : std_logic_vector (15 downto 0);
    signal in2     : std_logic_vector (15 downto 0);
    signal in3     : std_logic_vector (15 downto 0);
    signal s       : std_logic_vector (1 downto 0);
    signal mux_out : std_logic_vector (15 downto 0);

begin

    dut : MUX4TO1
    port map (in0     => in0,
              in1     => in1,
              in2     => in2,
              in3     => in3,
              s       => s,
              mux_out => mux_out);

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        in0 <= (others => '0');
        in1 <= X"0F0F";
        in2 <= X"F0F0";
        in3 <= X"FFFF";
        s 	<= (others => '0');

        -- EDIT Add stimuli here
		  wait for 100 ns;
		  s <= "01"; wait for 100 ns;
		  s <= "10"; wait for 100 ns;
		  s <= "11"; wait for 100 ns;
		  
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_MUX4TO1 of tb_MUX4TO1 is
    for tb
    end for;
end cfg_tb_MUX4TO1;