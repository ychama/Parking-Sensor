--------------------------------------------------------------------------------
-- File Name:      downcounter.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or similar)
-- Target Device:  DE10-Lite or other FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   A simple downcounter that starts counting from a given integer 'period'
--   down to zero. When it reaches zero, it:
--     1) Pulses 'zero' (sets it to '1' for one clock cycle), then
--     2) Reloads current_count to (period - 1).
--
-- Ports:
--   clk     : in  std_logic
--       The system clock. Counting occurs on its rising edge.
--
--   reset_n : in  std_logic
--       **Active-low** reset signal. When '0', sets current_count to 0 
--       and 'zero' to '0' immediately.
--
--   enable  : in  std_logic
--       Active-high enable. When 'enable' = '1', the counter is updated each
--       rising edge of the clock. When 'enable' = '0', the counter is frozen,
--       and 'zero' is forced high ('1').
--
--   zero    : out std_logic
--       A pulse signal that goes '1' for one clock cycle whenever the counter
--       transitions from 0 to (period - 1). Useful for triggering external
--       logic (e.g., enabling a PWM step, toggling, etc.).
--
--   period  : in integer
--       An integer specifying the reload value for the counter. When the 
--       counter hits 0, it is reloaded to (period - 1).
--
-- Behavior:
--   - If current_count=0 and enable=1, zero is asserted and current_count 
--     re-initializes to (period - 1).
--   - If current_count != 0 and enable=1, current_count decrements by 1 
--     and zero is deasserted.
--   - If enable=0, 'zero' stays '1' continuously, and the counter doesn't count.
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - If you need to monitor the current_count externally, uncomment the 
--       'value <= ...' line and adjust its size to match the maximum period 
--       range.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- The math_real libraries are used for computing log2, etc. if needed.
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;

entity downcounter is
    port(
        clk     : in  std_logic;  -- Clock
        reset_n : in  std_logic;  -- Active-low reset
        enable  : in  std_logic;  -- Active-high enable
        zero    : out std_logic;  -- Pulses '1' when the counter hits 0
        period  : in  integer     -- Reload value for the downcounter
        --value : out std_logic_vector(...)  -- (Optional) current_count output
    );
end downcounter;

architecture Behavioral of downcounter is

    ----------------------------------------------------------------------------
    -- Internal signal for the current counter value
    ----------------------------------------------------------------------------
    signal current_count : integer;

begin
    ----------------------------------------------------------------------------
    -- downcount Process
    --   - Checks reset_n (active-low) first.
    --   - On rising_edge(clk), if 'enable' is '1', decrements current_count until
    --     it hits 0, at which point 'zero' is pulsed and current_count is reloaded
    --     to period - 1.
    ----------------------------------------------------------------------------
    downcount : process(clk, reset_n) 
    begin
        if (reset_n = '0') then
            -- On reset: Initialize
            current_count <= 0;
            zero <= '0';
        elsif rising_edge(clk) then
            if (enable = '1') then
                if (current_count = 0) then
                    current_count <= period - 1;
                    zero <= '1';  -- Pulse goes high for this one clock cycle
                else
                    current_count <= current_count - 1;
                    zero <= '0';
                end if;
            else
                -- When enable='0', freeze the counter 
                -- and force 'zero' = '1' continuously
                zero <= '1';
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Optional: If you want to observe the current_count externally,
    -- uncomment the code below and adjust its range to match 'period'.
    --
    -- value <= std_logic_vector(to_signed(current_count, value'length));
    ----------------------------------------------------------------------------

end Behavioral;
