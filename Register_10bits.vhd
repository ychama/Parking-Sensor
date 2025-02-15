--------------------------------------------------------------------------------
-- File Name:      Register_10bits.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or similar)
-- Target Device:  DE10-Lite or other FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   A simple 10-bit register that stores data from 'D' to 'Q' on each rising
--   edge of 'clk', but only if 'enable' is '1'. The optional asynchronous reset
--   is commented out. If you need it, uncomment and supply 'reset_n' (active-low
--   or active-high depending on your design).
--
-- Ports:
--   clk    : in std_logic
--       The clock signal. Data is latched on its rising edge.
--
--   enable : in std_logic
--       Write-enable. Data is captured only when 'enable' = '1'.
--
--   D      : in std_logic_vector(9 downto 0)
--       The 10-bit input bus to be latched into the register.
--
--   Q      : out std_logic_vector(9 downto 0)
--       The 10-bit output bus reflecting the stored value.
--
-- Optional Reset:
--   - If you want an asynchronous or synchronous reset, uncomment the lines
--     related to 'reset_n' and initialize 'Q' to "0000000000".
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - Often used in a Synchronizer chain to bring external switch signals 
--       into the clock domain safely.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_10bits is
    port(
        clk    : in  std_logic;
        enable : in  std_logic;
        -- reset_n : in std_logic;
        D      : in  std_logic_vector(9 downto 0);
        Q      : out std_logic_vector(9 downto 0)
    );
end Register_10bits;

architecture BEHAVIOR of Register_10bits is
begin

    ----------------------------------------------------------------------------
    -- Main Process: Captures 'D' into 'Q' on rising_edge(clk) if enable='1'.
    -- (Optional) If reset_n logic is needed, uncomment the lines.
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            -- Uncomment the following if using an asynchronous or synchronous reset:
            -- if reset_n = '0' then
            --     Q <= (others => '0');
            -- elsif enable = '1' then
            --     Q <= D;
            -- end if;
            
            if enable = '1' then
                Q <= D;
            end if;
        end if;
    end process;

end BEHAVIOR;
