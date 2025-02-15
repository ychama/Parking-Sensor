-------------------------------------------------------------------------------
-- Design Name:    ADC_Data
-- Project Name:   Ultrasonic Parking Sensor / Proximity Alarm
-- Target Devices: DE10-Lite (Cyclone® V FPGA)
-- Tool Versions:  Quartus Prime / ModelSim
--
-- Description:
--   This module interfaces with the on-board ADC (via ADC_Conversion_wrapper)
--   to read a 12-bit raw ADC value. It then applies a 256-sample moving
--   average (averager256) to produce a stable output (ADC_out). Using that
--   averaged value, it calculates:
--   1) Voltage in millivolts (voltage),
--   2) Distance in 10^-4 cm (distance),
--   for a connected sensor like the Sharp GP2Y0A41SK0F. The module also
--   outputs the raw ADC reading (ADC_raw) for debug or display purposes.
--
-- Dependencies:
--   - ADC_Conversion_wrapper.vhd   (for hardware or simulation of the ADC)
--   - averager256.vhd
--   - voltage2distance_array2.vhd
--
-- Revision:
--   Revision 0.01 - File Created
--   Additional Comments:
--     - Change the instantiation for ADC_Conversion_wrapper to select either
--       the RTL architecture (on-board hardware) or a simulation architecture
--       (for testbenches).
--     - Adjust the scaling factors (2500*2) if your ADC reference voltage or
--       sensor wiring changes.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_Data is
    Port(
        clk       : in  STD_LOGIC;                       -- System clock
        reset_n   : in  STD_LOGIC;                       -- Active-low reset
        voltage   : out STD_LOGIC_VECTOR (12 downto 0);  -- Voltage in millivolts
        distance  : out STD_LOGIC_VECTOR (12 downto 0);  -- Distance in 10^-4 cm
        ADC_raw   : out STD_LOGIC_VECTOR (11 downto 0);  -- Latest 12-bit ADC value
        ADC_out   : out STD_LOGIC_VECTOR (11 downto 0)   -- Moving average of ADC, over 256 samples
    );
End ADC_Data;

architecture rtl of ADC_Data is

    ----------------------------------------------------------------------------
    -- Constants
    ----------------------------------------------------------------------------
    -- X is used as part of the averaging logic. For 256-sample averaging, we have
    -- 2^8 = 256 => log4(2^8) = 4 bits of resolution gained.
    ----------------------------------------------------------------------------
    constant X : integer := 4;

    ----------------------------------------------------------------------------
    -- Internal Signals
    ----------------------------------------------------------------------------
    signal response_valid_out : STD_LOGIC;                         -- High when ADC data is valid
    signal ADC_raw_temp       : STD_LOGIC_VECTOR(11 downto 0);     -- ADC's raw 12-bit output
    signal ADC_out_ave        : STD_LOGIC_VECTOR(11 downto 0);     -- Averaged ADC value
    signal voltage_temp       : STD_LOGIC_VECTOR(12 downto 0);     -- Temporary storage for calculated voltage (mV)

    ----------------------------------------------------------------------------
    -- Component Declarations
    ----------------------------------------------------------------------------

    -- This wrapper instantiates the actual MAX10 ADC interface for hardware or
    -- a simulation model when testing.
    component ADC_Conversion_wrapper is
        Port(
            MAX10_CLK1_50      : in  STD_LOGIC;
            response_valid_out : out STD_LOGIC;
            ADC_out            : out STD_LOGIC_VECTOR (11 downto 0)
        );
    end component;

    --**********************************************************************
    -- Uncomment exactly ONE of the following lines to choose the architecture
    -- for ADC_Conversion_wrapper:
    --**********************************************************************
    for ADC_ins : ADC_Conversion_wrapper use entity work.ADC_Conversion_wrapper(RTL);        
    --for ADC_ins : ADC_Conversion_wrapper use entity work.ADC_Conversion_wrapper(simulation);
    --**********************************************************************

    -- Converts voltage (mV) to distance using a lookup table or polynomial
    -- based on the Sharp GP2Y0A41SK0F sensor's datasheet.
    component voltage2distance_array2 is
        Port(
            clk       : in  STD_LOGIC;
            reset_n   : in  STD_LOGIC;
            voltage   : in  STD_LOGIC_VECTOR(12 downto 0);
            distance  : out STD_LOGIC_VECTOR(12 downto 0)
        );
    end component;

    -- A 256-sample moving average filter for 12-bit data. Generic parameters:
    --   N = 8 => 2^8 = 256 samples
    --   X = log4(2^N) => 4 bits of extra resolution
    --   bits = 11 => input data is 12 bits wide (index 0..11)
    component averager256 is
        generic(
            N    : INTEGER;
            X    : INTEGER;
            bits : INTEGER
        );
        port(
            clk     : in  std_logic;
            EN      : in  std_logic;  -- High when a new sample is valid
            reset_n : in  std_logic;  -- Active-low reset
            Din     : in  std_logic_vector(bits downto 0);
            Q       : out std_logic_vector(bits downto 0)
        );
    end component;

begin
    ----------------------------------------------------------------------------
    -- Instantiation: voltage2distance_array2
    -- Converts the (mV) voltage measurement into a distance (in 10^-4 cm).
    ----------------------------------------------------------------------------
    voltage2distance_ins : voltage2distance_array2
        port map(
            clk      => clk,
            reset_n  => reset_n,
            voltage  => voltage_temp,
            distance => distance
        );

    ----------------------------------------------------------------------------
    -- Instantiation: ADC_Conversion_wrapper
    -- Reads the 12-bit raw data from the MAX10 ADC or simulation model.
    ----------------------------------------------------------------------------
    ADC_ins : ADC_Conversion_wrapper
        port map(
            MAX10_CLK1_50      => clk,
            response_valid_out => response_valid_out,
            ADC_out            => ADC_raw_temp
        );

    ----------------------------------------------------------------------------
    -- Instantiation: averager256
    -- Creates a moving average over 256 samples of the 12-bit ADC input.
    ----------------------------------------------------------------------------
    averager : averager256
        generic map(
            N    => 8,   -- 2^8 = 256 samples
            X    => 4,   -- log4(256) = 4
            bits => 11   -- 12-bit input data => index 0..11
        )
        port map(
            clk     => clk,
            EN      => response_valid_out,  -- Only sample when new ADC data is valid
            reset_n => reset_n,
            Din     => ADC_raw_temp,
            Q       => ADC_out_ave
        );

    ----------------------------------------------------------------------------
    -- Outputs
    ----------------------------------------------------------------------------
    -- Pass the averaged ADC value up to the top-level for display or debug.
    ADC_out <= ADC_out_ave;

    -- Also pass the raw ADC reading for debug or direct usage.
    ADC_raw <= ADC_raw_temp;

    ----------------------------------------------------------------------------
    -- Calculate voltage in mV from the averaged 12-bit ADC value.
    --   - Multiply by 5000 mV (shown as 2500*2) because the ADC is 2.5V reference
    --     but there's a 2:1 divider allowing up to ~5V. 
    --   - Divide by 2^12 (4096) to scale correctly for a 12-bit reading.
    ----------------------------------------------------------------------------
    voltage_temp <= '0' & std_logic_vector(
                        resize(
                            unsigned(ADC_out_ave) * 2500 * 2 / (2**12),
                            voltage_temp'length - 1
                        )
                     );

    voltage <= voltage_temp;

end rtl;
