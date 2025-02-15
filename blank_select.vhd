--------------------------------------------------------------------------------
-- Design Name:    blank_select
-- Project Name:   Ultrasonic Parking Sensor / Proximity Alarm
-- Target Devices: DE10-Lite (Cyclone® V FPGA)
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   The blank_select module outputs a 6-bit control vector (blank_out) used to
--   selectively "blank" (turn off) certain 7-segment displays. Which digits to
--   blank depends on:
--   - The operating mode (state),
--   - The values of two 4-bit digit signals (num1, num2).
--
--   Typically, 'state' is a 2-bit mode selector from the system. The signals
--   num1 and num2 represent the upper (more significant) digits in a multi-digit
--   display. If both digits are zero and the system is in a certain state, it
--   may blank them to prevent leading zeros from showing or to reduce display
--   clutter.
--
-- Dependencies:
--   None specific (relies on top-level for integration).
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - The 6 bits in blank_out may map to individual display enabling lines
--       or DP/blanking lines, depending on your SevenSegment module.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blank_select is
    Port(
        -- 2-bit operating mode (e.g., 00,01,10,11 for different display modes)
        state       : in  STD_LOGIC_VECTOR(1 downto 0);

        -- 4-bit nibble for the third and second-most significant digits
        num1        : in  STD_LOGIC_VECTOR(3 downto 0);
        num2        : in  STD_LOGIC_VECTOR(3 downto 0);

        -- 6-bit control vector for blanking (or partially blanking) certain digits
        blank_out   : out STD_LOGIC_VECTOR(5 downto 0)
    );
end blank_select;

architecture behavioural of blank_select is
begin
    ----------------------------------------------------------------------------
    -- blank_out assignment logic:
    --
    -- 1) "111100" is chosen when:
    --      - num1 = "0000"
    --      - num2 = "0000"
    --      - state = "11"
    --    This may indicate that if both digits are zero and we are in state "11",
    --    we blank more of the display (e.g., hide the two most significant digits).
    --
    -- 2) "111000" is chosen when:
    --      - (num1 = "0000" and state = "01")
    --        OR
    --        (num1 = "0000" and num2 /= "0000" and state = "11")
    --    If the system is in certain modes and num1 = 0000, we partially blank.
    --    Alternatively, if num1=0 but num2 != 0 in state "11," we blank fewer digits.
    --
    -- 3) Otherwise "110000" is used, presumably the default or "no blank" scenario.
    --
    -- NOTE: The exact meaning of each bit in blank_out depends on how your SevenSegment
    --       or top-level design interprets them. They might correspond to enabling or
    --       disabling certain segments/displays.
    ----------------------------------------------------------------------------
    blank_out <=  "111100" when (num1 = "0000" and num2 = "0000" and state = "11") else
                  "111000" when ((num1 = "0000" and state = "01") or
                                 (num1 = "0000" and num2 /= "0000" and state = "11")) else
                  "110000";

end behavioural;
