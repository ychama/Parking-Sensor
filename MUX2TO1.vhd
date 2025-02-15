library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX2TO1 is
port ( in0     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits
       in1     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits
       s       : in  std_logic;
       mux_out : out std_logic_vector(15 downto 0) -- notice no semi-colon 
      );
end MUX2TO1; -- can also be written as "end entity;" or just "end;"

architecture BEHAVIOR of MUX2TO1 is
	begin
		with s select
			mux_out <= in0 when '0', -- when s is '0' then mux_out becomes in1
			           in1 when others;
end BEHAVIOR; -- can also be written as "end;"
