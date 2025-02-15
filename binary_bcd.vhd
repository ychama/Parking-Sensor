--------------------------------------------------------------------------------
-- File Name:      binary_bcd.vhd
-- Project:        Ultrasonic Parking Sensor / Proximity Alarm (or your project)
-- Target Device:  DE10-Lite or similar FPGA
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   This module converts a 13-bit binary number (binary) into a 16-bit BCD 
--   (Binary-Coded Decimal) representation (bcd). It uses a finite state machine 
--   (FSM) that implements the classic "Shift-and-Add-3" algorithm:
--
--   1) The binary input is placed into a longer vector (bcd_signal) that provides
--      space for up to 4 BCD digits (each nibble) plus the original binary bits.
--   2) Each nibble (of the potential BCD digits) is checked to see if it's 
--      greater than 4. If so, 3 is added to that nibble (the "add 3" step).
--   3) The entire register is shifted left by 1 bit.
--   4) Steps 2 and 3 repeat until all bits of the original binary number have 
--      been shifted into the BCD area.
--   5) The result is then output as a 16-bit BCD number.
--
-- Ports:
--   clk      : in  std_logic
--       The rising-edge clock driving the FSM.
--
--   reset_n  : in  std_logic
--       Active-low asynchronous reset signal. Resets the internal FSM and outputs.
--
--   binary   : in  std_logic_vector(12 downto 0)
--       13-bit binary input to be converted to BCD.
--
--   bcd      : out std_logic_vector(15 downto 0)
--       The resulting 16-bit BCD number. Typically displayed on 7-seg or used 
--       as readable decimal digits in your system.
--
-- Dependencies:
--   None (pure VHDL design).
--
-- Notes:
--   - This design uses a state machine with states S0..S6. 
--   - The constants add3_0digit..add3_3digit are masks used to selectively add 
--     3 to each nibble if it exceeds 4, simulating a "BCD correction."
--   - The output bcd will be available once the FSM completes all shifts for 
--     the 13-bit input (i.e., after 12 shifts).
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - If you need a larger binary input, increase the input vector size and 
--       adjust the shift count logic accordingly.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_bcd is
    port(
        clk      : in  std_logic;                       -- System clock
        reset_n  : in  std_logic;                       -- Active-low reset
        binary   : in  std_logic_vector(12 downto 0);   -- 13-bit binary input
        bcd      : out std_logic_vector(15 downto 0)    -- 16-bit BCD output
    );
end binary_bcd;

architecture behavior of binary_bcd is

    ----------------------------------------------------------------------------
    -- FSM States (S0..S6)
    ----------------------------------------------------------------------------
    type statetype is (S0, S1, S2, S3, S4, S5, S6);
    signal CurentState : statetype := S0;

    -- Counter to track how many shifts have been performed
    signal counter     : integer := 0;

    -- Internal register used for the shift-and-add operations.
    -- Size = 29 bits: top 16 bits can hold up to 4 BCD digits, plus 13 bits for 
    -- the original binary. 
    signal bcd_signal  : unsigned(28 downto 0) := (others => '0');

    -- Add-3 constants for each nibble of the BCD result
    constant add3_0digit : unsigned(28 downto 0) := 
                            "00000000000000110000000000000";
    constant add3_1digit : unsigned(28 downto 0) := 
                            "00000000001100000000000000000";
    constant add3_2digit : unsigned(28 downto 0) := 
                            "00000011000000000000000000000";
    constant add3_3digit : unsigned(28 downto 0) := 
                            "00110000000000000000000000000";

begin
    ----------------------------------------------------------------------------
    -- Main FSM Process
    ----------------------------------------------------------------------------
    bcd_process : process(reset_n, clk)
        variable NextState : statetype;
    begin
        -- Asynchronous active-low reset
        if (reset_n = '0') then
            bcd <= (others => '0');
            bcd_signal <= (others => '0');
            counter <= 0;
            CurentState <= S0;

        elsif (rising_edge(clk)) then
            --------------------------------------------------------------------
            -- State Machine
            --------------------------------------------------------------------
            case CurentState is

                -- S0: Initialize the bcd_signal with the input binary.
                when S0 =>
                    bcd_signal(12 downto 0) <= unsigned(binary); 
                    NextState := S1;

                -- S1: Check the top BCD nibble (bits 28..25). If > 4, add 3.
                when S1 =>
                    if (bcd_signal(28 downto 25) > 4) then
                        bcd_signal <= bcd_signal + add3_3digit;
                    end if;
                    NextState := S2;

                -- S2: Check the second nibble (bits 24..21). If > 4, add 3.
                when S2 =>
                    if (bcd_signal(24 downto 21) > 4) then
                        bcd_signal <= bcd_signal + add3_2digit;
                    end if;
                    NextState := S3;

                -- S3: Check the third nibble (bits 20..17). If > 4, add 3.
                when S3 =>
                    if (bcd_signal(20 downto 17) > 4) then
                        bcd_signal <= bcd_signal + add3_1digit;
                    end if;
                    NextState := S4;

                -- S4: Check the fourth nibble (bits 16..13). If > 4, add 3.
                when S4 =>
                    if (bcd_signal(16 downto 13) > 4) then
                        bcd_signal <= bcd_signal + add3_0digit;
                    end if;
                    NextState := S5;

                -- S5: Perform a left shift by 1 bit, moving the most significant 
                --     bits closer to the BCD region.
                when S5 =>
                    bcd_signal <= shift_left(unsigned(bcd_signal), 1);
                    NextState := S6;

                -- S6: Check if we've shifted enough times (counter=12) 
                --     for our 13-bit input. If so, output the top 16 bits 
                --     as the BCD result and reset. Otherwise, repeat.
                when S6 =>
                    if (counter = 12) then
                        bcd <= std_logic_vector(bcd_signal(28 downto 13));
                        bcd_signal <= (others => '0');
                        counter <= 0;
                        NextState := S0;
                    else
                        counter <= counter + 1;
                        NextState := S1;
                    end if;

                -- Default catch-all for robustness
                when others =>
                    NextState := S0;
                    counter <= 0;
                    bcd_signal <= (others => '0');
            end case;

            CurentState <= NextState;
        end if;
    end process;

end behavior;
