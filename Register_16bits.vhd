--------------------------------------------------------------------------------
-- File Name:      Register_16bits.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or your project)
-- Target Device:  DE10-Lite or similar FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   This is a simple 16-bit register that captures data on the rising edge of
--   the clock when 'enable' is asserted. It also features an active-low
--   asynchronous reset that clears the output (Q) to "0000".
--
-- Ports:
--   clk     : in  std_logic
--       The system clock. Data is latched on the rising edge.
--
--   reset_n : in  std_logic
--       Active-low asynchronous reset. When low, Q is forced to X"0000".
--
--   enable  : in  std_logic
--       Write-enable control. If 'enable' = '1' at the rising edge of 'clk',
--       the input D is copied to Q. If 'enable' = '0', Q remains unchanged.
--
--   D       : in  std_logic_vector(15 downto 0)
--       The 16-bit data input to be registered.
--
--   Q       : out std_logic_vector(15 downto 0)
--       The 16-bit registered output.
--
-- Behavior:
--   - On reset_n = '0': Q <= X"0000"
--   - On rising_edge(clk) and enable = '1': Q <= D
--   - Otherwise, Q retains its previous value.
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - This register is commonly used to store data such as user-selected
--       inputs or sensor readings in a synchronous design.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_16bits is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        D       : in  std_logic_vector(15 downto 0);
        Q       : out std_logic_vector(15 downto 0)
    );
end Register_16bits;

architecture BEHAVIOR of Register_16bits is
begin

    ----------------------------------------------------------------------------
    -- Main Process: Asynchronous reset, rising_edge clock for register
    ----------------------------------------------------------------------------
    process(clk, reset_n)
    begin
        -- Asynchronous active-low reset
        if reset_n = '0' then
            Q <= X"0000";
        -- Rising-edge detection
        elsif rising_edge(clk) then
            -- Load input D into Q only if enable is high
            if enable = '1' then
                Q <= D;
            end if;
        end if;
    end process;

end BEHAVIOR;
