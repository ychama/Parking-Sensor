--------------------------------------------------------------------------------
-- File Name:      MUX4TO1.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or your project)
-- Target Device:  DE10-Lite or similar FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   A 4-to-1 multiplexer that selects one of four 16-bit input vectors based on
--   a 2-bit select line (s). The selected 16-bit vector is driven onto mux_out.
--
-- Ports:
--   in0, in1, in2, in3 : in  STD_LOGIC_VECTOR(15 downto 0)
--       Four 16-bit input vectors. For example:
--         - in0 = Hex data
--         - in1 = BCD data
--         - in2 = Stored data
--         - in3 = Pattern data (e.g., "5A5A")
--
--   s : in  STD_LOGIC_VECTOR(1 downto 0)
--       A 2-bit select signal controlling which input is passed to mux_out.
--       Usually:
--         "00" => in0
--         "01" => in1
--         "10" => in2
--         "11" => in3
--
--   mux_out : out STD_LOGIC_VECTOR(15 downto 0)
--       The 16-bit result of the selected input vector.
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - This multiplexer is used throughout the design to choose among multiple
--       data sources (e.g., HEX, BCD distance, BCD voltage, etc.).
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX4TO1 is
    port( 
        in0     : in  std_logic_vector(15 downto 0); 
        in1     : in  std_logic_vector(15 downto 0); 
        in2     : in  std_logic_vector(15 downto 0); 
        in3     : in  std_logic_vector(15 downto 0); 
        s       : in  std_logic_vector(1 downto 0);   -- 2-bit select input
        mux_out : out std_logic_vector(15 downto 0)
    );
end MUX4TO1;

architecture BEHAVIOR of MUX4TO1 is
begin
    ----------------------------------------------------------------------------
    -- Simple concurrent statement with 'with-select' to choose among in0..in3
    ----------------------------------------------------------------------------
    with s select
        mux_out <= in0 when "00",
                   in1 when "01",
                   in2 when "10",
                   in3 when others;  -- covers "11" or any undefined combination
end BEHAVIOR;
