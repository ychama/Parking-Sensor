--------------------------------------------------------------------------------
-- File Name:      module.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or your project)
-- Target Device:  DE10-Lite or other FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   This module uses a lookup table (d27seg_LUT) to map a measured distance
--   (in 10^-4 cm) to a period (integer). It then feeds this period to a
--   downcounter. The downcounter toggles a pulse (downcounter_output) each time
--   it goes from zero to period-1. That pulse is used as 'pwm_enable' for
--   a PWM_SEVENSEG module, which generates a PWM signal (inverted) at that rate.
--
--   The module also disables (enable='0') the downcounter when distance >= 2000
--   (interpreted as 20.00 cm if distance is in 10^-4 cm units). This effectively
--   stops the flashing (the output remains either high or low).
--
-- Ports:
--   reset_n  : in  std_logic
--       Active-low reset for both the downcounter and PWM modules.
--
--   clk      : in  std_logic
--       System clock for synchronized operations.
--
--   distance : in  std_logic_vector(12 downto 0)
--       The measured distance, presumably in 10^-4 cm (e.g., 2000 => 20.00 cm).
--
--   output   : out std_logic
--       The resulting PWM-style signal. Often used to enable/disable or flash
--       a 7-segment display or LED bar. 
--
-- Internal Signals:
--   period              : integer
--       Derived from distance via the d27seg_LUT. Specifies how long the
--       downcounter runs before toggling a pulse.
--
--   downcounter_output  : std_logic
--       Goes high briefly each time the downcounter hits zero.
--
--   output_pwm          : std_logic
--       The PWM signal produced by the PWM_SEVENSEG instance. Assigned to
--       'output' at the end of the architecture.
--
--   enable              : std_logic
--       Determines whether the downcounter is active. Set to '1' if
--       distance < 2000 (e.g., 20 cm), or '0' otherwise, disabling the flash.
--
-- Dependencies:
--   - LUT_pkg (contains d27seg_LUT)
--   - downcounter.vhd
--   - PWM_SEVENSEG.vhd
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - The duty_cycle in PWM_SEVENSEG is set to "1000000000000" (13 bits,
--       which is decimal 2048). This might represent a ~25% duty cycle if
--       the counter is 12 bits deep (2^12=4096). Adjust as needed.
--     - The threshold 2000 in the process corresponds to 20 cm 
--       (since each unit is 10^-4 cm).
--------------------------------------------------------------------------------

library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.LUT_pkg.all;

entity module is
    port(
        reset_n  : in  std_logic;
        clk      : in  std_logic;
        distance : in  std_logic_vector(12 downto 0);
        output   : out std_logic
    );
end module;

architecture Behavioral of module is

    ----------------------------------------------------------------------------
    -- Internal Signals
    ----------------------------------------------------------------------------
    signal period            : integer;
    signal downcounter_output: std_logic;
    signal output_pwm        : std_logic;
    signal enable            : std_logic;

    ----------------------------------------------------------------------------
    -- Component Declarations
    ----------------------------------------------------------------------------
    component downcounter is
        port(
            clk     : in  std_logic; 
            reset_n : in  std_logic; 
            enable  : in  std_logic; 
            zero    : out std_logic;  
            period  : in  integer
        );
    end component;

    component PWM_SEVENSEG is
        generic(width : integer);
        port(
            reset_n           : in  std_logic;
            clk               : in  std_logic;
            duty_cycle        : in  std_logic_vector(width-1 downto 0);
            pwm_enable        : in  std_logic;
            inverted_pwm_out  : out std_logic
        );
    end component;

begin

    ----------------------------------------------------------------------------
    -- Process: emma
    --   - Maps 'distance' to 'period' via d27seg_LUT.
    --   - Disables (enable='0') the downcounter if distance >= 2000 (20 cm),
    --     effectively stopping the flashing.
    ----------------------------------------------------------------------------
    emma : process(distance)
    begin
        -- Convert distance to a period for the downcounter using LUT
        period <= d27seg_LUT(to_integer(unsigned(distance)));

        -- If distance >= 20 cm, disable the flash
        if to_integer(unsigned(distance)) >= 2000 then
            enable <= '0';
        else
            enable <= '1';
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- downcounter instantiation:
    --   - Runs from 'period' down to zero, then emits a pulse on 'zero' each time.
    --   - Only enabled when enable='1'.
    ----------------------------------------------------------------------------
    downcounter_instantiation : downcounter
        port map(
            clk     => clk,
            period  => period,
            enable  => enable,
            reset_n => reset_n,
            zero    => downcounter_output
        );

    ----------------------------------------------------------------------------
    -- PWM_SEVENSEG instantiation:
    --   - width => 13, so 'duty_cycle' is 13 bits wide.
    --   - 'pwm_enable' is driven by 'downcounter_output' pulses, controlling
    --     how frequently the PWM logic increments its own counter.
    --   - 'duty_cycle' is set to "1000000000000" => typically ~25% if the
    --     counter runs up to 4095. 
    ----------------------------------------------------------------------------
    PWM_SEVENSEG_instantiation : PWM_SEVENSEG
        generic map(width => 13)
        port map(
            clk               => clk,
            pwm_enable        => downcounter_output,
            reset_n           => reset_n,
            duty_cycle        => "1000000000000",  -- Hard-coded duty cycle
            inverted_pwm_out  => output_pwm
        );

    ----------------------------------------------------------------------------
    -- Final output assignment
    ----------------------------------------------------------------------------
    output <= output_pwm;

end Behavioral;
