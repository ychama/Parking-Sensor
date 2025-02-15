--------------------------------------------------------------------------------
-- File Name:      PWM_DAC.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or your project)
-- Target Device:  DE10-Lite or similar FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   A parameterizable (width-bit) PWM generator. Internally, it increments an
--   unsigned counter every clock cycle (from 0 up to 'max_length'). If the
--   counter is less than the input 'duty_cycle', the output PWM is '1'; 
--   otherwise, it's '0'. The output is then inverted before being assigned to
--   'inverted_pwm_out', which may be necessary depending on how your hardware
--   or LEDs are wired.
--
-- Generics:
--   width : integer := 13
--     - The bit-width of the internal counter and the duty_cycle input.
--       A value of 13 means the duty cycle can range up to 2^13 - 1 = 8191.
--
-- Ports:
--   reset_n    : in  std_logic
--       Active-low asynchronous reset. Resets the counter to 0 or if the
--       counter >= max_length on next clock check.
--
--   clk        : in  std_logic
--       System clock. The counter increments on the rising edge.
--
--   duty_cycle : in  std_logic_vector(width-1 downto 0)
--       The target duty cycle value. 
--       e.g., if width=12, it can range from 0..4095 (2^12 - 1).
--
--   inverted_pwm_out : out std_logic
--       The PWM output (inverted) to drive external circuitry. '1' for the 
--       portion of the cycle below the duty_cycle, then '0' for the remainder.
--
-- Internal Constant:
--   max_length : integer := 4095
--     - The maximum count after which the counter resets. This is currently
--       set to 4095, matching 12 bits (2^12 - 1). If your 'width' is set to 13,
--       you may want to change this to 8191 for full-scale usage.
--
-- How it Works:
--   1) The process 'count' increments an unsigned counter each clock cycle.
--      If 'counter >= max_length' or 'reset_n' = '0', counter is reset to 0.
--   2) The process 'compare' checks if 'counter < duty_cycle'.
--      - If true, 'pwm_out' = '1'
--      - Otherwise, 'pwm_out' = '0'
--   3) The final output 'inverted_pwm_out' is the logical NOT of 'pwm_out'.
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - Adjust 'max_length' if you need the counter to match '2^width - 1'.
--     - If you need a non-inverted signal, you can directly drive 'pwm_out' 
--       to your output instead of inverting it.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_DAC is
    generic(
        width : integer := 13  -- Parameterizable bit-width for duty_cycle & counter
    );
    port(
        reset_n          : in  std_logic;                               -- Active-low reset
        clk              : in  std_logic;                               -- System clock
        duty_cycle       : in  std_logic_vector(width-1 downto 0);      -- Requested duty cycle
        inverted_pwm_out : out std_logic                               -- PWM output (inverted)
    );
end PWM_DAC;

architecture Behavioral of PWM_DAC is

    -- Internal unsigned counter
    signal counter : unsigned(width-1 downto 0);

    -- Raw PWM signal before inversion
    signal pwm_out : std_logic;

    -- By default, set for 12-bit max (4095). Update if width=13 for 8191, etc.
    constant max_length : integer := 4095;

begin

    ----------------------------------------------------------------------------
    -- Process: count
    --   - Increments the 'counter' each rising_edge(clk).
    --   - Resets the counter to 0 if reset_n='0' or if counter >= max_length.
    ----------------------------------------------------------------------------
    count : process(clk, reset_n)
    begin
        if (reset_n = '0' or counter >= max_length) then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Process: compare
    --   - If counter < duty_cycle, then pwm_out = '1', else '0'.
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
    -- Assign the inverted PWM signal to the output.
    ----------------------------------------------------------------------------
    inverted_pwm_out <= not pwm_out;

end Behavioral;
