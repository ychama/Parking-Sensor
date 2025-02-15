--------------------------------------------------------------------------------
-- File Name:      SevenSegment_decoder.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or similar)
-- Target Device:  DE10-Lite or another FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   Converts a 4-bit input (0..F) into a corresponding 7-segment pattern,
--   plus an optional decimal point. Allows the entire display to be blanked
--   when 'Blank' is '1'. The segment bits are inverted before driving 'H'
--   because the hardware lines are typically active-low.
--
-- Ports:
--   H      : out std_logic_vector(7 downto 0)
--       The output lines to the 7-segment display. 
--         - H(6 downto 0) = {g, f, e, d, c, b, a}, active-low.
--         - H(7)          = decimal point, active-low.
--
--   input  : in std_logic_vector(3 downto 0)
--       The 4-bit digit to display (hexadecimal 0..F).
--
--   DP     : in std_logic
--       Controls the decimal point. '1' => DP on (inverted to '0'), 
--       '0' => DP off.
--
--   Blank  : in std_logic
--       If '1', forces the display to be blank regardless of 'input'.
--
-- Internal Signals:
--   seven_seg : std_logic_vector(6 downto 0)
--       Holds the direct (non-inverted) segment pattern for {g, f, e, d, c, b, a}.
--       After the case statement, we invert it before assigning to H(6 downto 0).
--
-- How It Works:
--   1) If Blank='1', we set seven_seg="0000000" (all segments off before inversion).
--   2) Otherwise, we match 'input' to the appropriate 7-segment pattern.
--   3) We invert the bits in seven_seg before driving H, because the hardware 
--      expects active-low signals. For example, seven_seg='1' => H='0' => segment ON.
--   4) Similarly, 'DP' is inverted for H(7).
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - The bit patterns here assume a particular layout of segments. If your 
--       hardware pins differ, adjust accordingly.
--     - For active-high segments, remove the 'not' operations or invert the bit
--       patterns as needed.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegment_decoder is
    port(
        H      : out std_logic_vector(7 downto 0);  -- {DP, g, f, e, d, c, b, a}
        input  : in  std_logic_vector(3 downto 0);
        DP, 
        Blank  : in  std_logic
    );
end SevenSegment_decoder;

architecture Behavioral of SevenSegment_decoder is

    -- 'seven_seg' holds the direct (non-inverted) bits for segments g..a
    signal seven_seg : std_logic_vector(6 downto 0);

begin

    ----------------------------------------------------------------------------
    -- Main Process: Decodes 'input' into the appropriate 7-segment pattern,
    -- or blanks the display if Blank='1'.
    ----------------------------------------------------------------------------
    process(input, Blank)
    begin
        if (Blank = '1') then
            -- Force the display off
            seven_seg <= "0000000";
        else
            -- Decode the nibble (input) into one of the known patterns
            case input is
                when "0000" => seven_seg <= "0111111";  -- 0
                when "0001" => seven_seg <= "0000110";  -- 1
                when "0010" => seven_seg <= "1011011";  -- 2
                when "0011" => seven_seg <= "1001111";  -- 3
                when "0100" => seven_seg <= "1100110";  -- 4
                when "0101" => seven_seg <= "1101101";  -- 5
                when "0110" => seven_seg <= "1111101";  -- 6
                when "0111" => seven_seg <= "0000111";  -- 7
                when "1000" => seven_seg <= "1111111";  -- 8
                when "1001" => seven_seg <= "1100111";  -- 9
                -- Hex digits for A..F
                when "1010" => seven_seg <= "1110111";  -- A
                when "1011" => seven_seg <= "1111111";  -- B
                when "1100" => seven_seg <= "0111001";  -- C
                when "1101" => seven_seg <= "1101111";  -- D
                when "1110" => seven_seg <= "1111001";  -- E
                when "1111" => seven_seg <= "1110001";  -- F
                when others => seven_seg <= "0000000";  -- Default blank
            end case;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Invert the segments and DP to drive active-low hardware.
    -- If DP='1', H(7) = '0' => DP ON (active-low).
    ----------------------------------------------------------------------------
    H(6 downto 0) <= not seven_seg;
    H(7) <= not DP;

end Behavioral;
