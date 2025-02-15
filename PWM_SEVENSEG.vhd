--------------------------------------------------------------------------------
-- File Name:      PWM_SEVENSEG.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or your project)
-- Target Device:  DE10-Lite or another FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   This module produces a PWM (Pulse-Width Modulation) output when 'pwm_enable'
--   is high. The duty cycle is specified by a generic bit-width input 
--   (duty_cycle). The output is inverted at the end, i.e., 'inverted_pwm_out'
--   is the logical NOT of the raw PWM signal.
--
-- Generics:
--   width : integer := 13
--     - The bit-width for the internal counter and the duty_cycle input.
--       Typically, 13 bits allows values up to 8191 (2^13 - 1) if fully utilized.
--
-- Ports:
--   reset_n          : in  std_logic
--       Active-low reset. Resets 'counter' to all zeros.
--
--   clk              : in  std_logic
--       System clock. The counter increments on the rising edge, but only if
--       'pwm_enable' is '1'.
--
--   duty_cycle       : in  std_logic_vector(width-1 downto 0)
--       The requested duty cycle. If 'counter' is less than this value,
--       'pwm_out' is '1'. Otherwise, 'pwm_out' is '0'.
--
--   pwm_enable       : in  std_logic
--       When high, the internal counter increments each rising edge of 'clk'.
--       When low, the counter is paused, effectively holding the same PWM state.
--
--   inverted_pwm_out : out std_logic
--       The final, inverted PWM signal. '1' during the portion of the cycle
--       above the duty cycle, '0' otherwise. This may be used to drive
--       displays or LEDs that are active-low, or simply because your system
--       expects an inverted signal.
--
-- Equation References:
--   The commented equation "34.2424 - 1.21212x" appears to be from a prior
--   design phase or calibration. If relevant, it might relate distance to
--   an intended flashing rate. It's not directly used here unless 'duty_cycle'
--   is set according to that formula in another module.
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - If you need a direct (non-inverted) PWM, drive an output with 'pwm_out'
--       instead of 'not pwm_out'.
--     - If you want to stop flashing beyond 20 cm, you'd feed in a smaller
--       duty_cycle or disable 'pwm_enable' at distances > 20 cm, depending on
--       your design.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_SEVENSEG is
    generic(
        width : integer := 13  -- Allows for a counter up to 2^13-1 (8191)
    );
    port(
        reset_n          : in  std_logic;                              
        clk              : in  std_logic;                              
        duty_cycle       : in  std_logic_vector(width-1 downto 0);
        pwm_enable       : in  std_logic;                              
        inverted_pwm_out : out std_logic                              
    );
end PWM_SEVENSEG;

architecture Behavioral of PWM_SEVENSEG is

    ----------------------------------------------------------------------------
    -- Internal counter signal for generating the PWM
    ----------------------------------------------------------------------------
    signal counter : unsigned(width-1 downto 0);
    signal pwm_out : std_logic;

begin

    ----------------------------------------------------------------------------
    -- count Process:
    --   - Resets counter on reset_n='0'.
    --   - Increments counter on each rising_edge(clk) when pwm_enable='1'.
    ----------------------------------------------------------------------------
    count : process(clk, reset_n)
    begin
        if (reset_n = '0') then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if (pwm_enable = '1') then
                counter <= counter + 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- compare Process:
    --   - Compares 'counter' to 'duty_cycle'.
    --   - If counter < duty_cycle => pwm_out = '1', else '0'.
    ----------------------------------------------------------------------------
    compare : process(counter, duty_cycle)
    begin
        if (counter < unsigned(duty_cycle)) then
            pwm_out <= '1';
        else
            pwm_out <= '0';
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- The final output is the inverse of pwm_out.
    ----------------------------------------------------------------------------
    inverted_pwm_out <= not pwm_out;

end Behavioral;
