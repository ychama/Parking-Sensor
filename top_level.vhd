library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity top_level IS
	PORT( 
		clk                           : in  STD_LOGIC;
		reset_n                       : in  STD_LOGIC;
		set 						        	: in  STD_LOGIC;
		SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
		LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
		HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0);
		buzz_out								: out STD_LOGIC
	);
END top_level;

architecture Behavioral of top_level is

-- signals
Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
Signal DP_in:				STD_LOGIC_VECTOR (15 downto 0);
Signal Blank:   			STD_LOGIC_VECTOR (5 downto 0);
signal debounce_result: STD_LOGIC;
signal sync_output:		STD_LOGIC_VECTOR (9 downto 0);
signal mux_out:		 	STD_LOGIC_VECTOR(15 DOWNTO 0);
signal reg_out:		 	STD_LOGIC_VECTOR(15 DOWNTO 0);
-- hex mode signals
signal hex_mux_in:	 	STD_LOGIC_VECTOR(15 DOWNTO 0);
-- voltage mode signals
signal ADC_voltage:		STD_LOGIC_VECTOR(12 downto 0);
signal bcd_voltage:		STD_LOGIC_VECTOR(15 downto 0);
-- distance mode signals
signal ADC_distance:		STD_LOGIC_VECTOR(12 downto 0);
signal bcd_distance:		STD_LOGIC_VECTOR(15 downto 0);
-- adc out signals
signal ADC_avg_out:		STD_LOGIC_VECTOR(11 downto 0);
signal ADC_avg_mux_in:	STD_LOGIC_VECTOR(15 downto 0);
signal PWM_LED_OUT: STD_LOGIC;
signal buzzer_in :STD_LOGIC;


--module output
signal module_output : STD_LOGIC;
-- Components
Component SevenSegment IS
	PORT( 
		Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0);
		Hex0,Hex1,Hex2,Hex3,Hex4,Hex5                         : out STD_LOGIC_VECTOR (7 downto 0);
		DP_in,Blank                                           : in  STD_LOGIC_VECTOR (5 downto 0);
		enable                                                : in STD_LOGIC
	);
END Component;

Component binary_bcd IS
   PORT(
      clk     : in  STD_LOGIC;                      --system clock
      reset_n : in  STD_LOGIC;                      --active low asynchronus reset_n
      binary  : in  STD_LOGIC_VECTOR(12 DOWNTO 0);  --binary number to convert
      bcd     : out STD_LOGIC_VECTOR(15 DOWNTO 0)   --resulting BCD number
	);           
END Component;

Component ADC_Data IS
	PORT(  
		clk      : in 	STD_LOGIC;
		reset_n  : in 	STD_LOGIC; -- active-low
		voltage  : out STD_LOGIC_VECTOR (12 downto 0); -- Voltage in milli-volts
		distance : out STD_LOGIC_VECTOR (12 downto 0); -- distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
		ADC_raw  : out STD_LOGIC_VECTOR (11 downto 0); -- the latest 12-bit ADC value
		ADC_out  : out STD_LOGIC_VECTOR (11 downto 0)  -- moving average of ADC value, over 256 samples,
	);
END Component;

Component debounce IS
	GENERIC(
    clk_freq    : INTEGER := 50_000_000;  --system clock frequency in Hz
    stable_time : INTEGER := 30 				--time button must remain stable in ms
	 );         
	 
	PORT(
		clk    	: in std_logic; 
		button  	: in std_logic;
		result  	: out std_logic
	);
END Component;

Component MUX2TO1 IS
	PORT(
		in0     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits
		in1     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits
		s       : in  std_logic;
		mux_out : out std_logic_vector(15 downto 0) -- notice no semi-colon 
	);
END Component;

Component MUX4TO1 IS
	PORT(
		in0     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits	hex
      in1     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits	bcd
      in2     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits	stored
      in3     : in  std_logic_vector(15 downto 0); -- changed input to 16 bits	5A5A
      s       : in  std_logic_vector( 1 downto 0); -- 2 bit select input
      mux_out : out std_logic_vector(15 downto 0) -- notice no semi-colon 
	);
END Component;

Component Register_16bits IS
	PORT(
		clk		: in 	std_logic;
		reset_n	: in 	std_logic;
		enable   : in  std_logic;
		D			: in 	std_logic_vector(15 downto 0);
		Q			: out	std_logic_vector(15 downto 0)
	);
END Component;			

Component Synchronizer IS
	PORT( 
		clk  		: in  STD_LOGIC;
		enable	: in 	STD_LOGIC;
		A			: in	STD_LOGIC_VECTOR(9 downto 0);
		G			: out	STD_LOGIC_VECTOR(9 downto 0)
	);
END Component;

Component blank_select IS
   PORT(
		state			: in  STD_LOGIC_VECTOR(1 downto 0);
      num1     	: in  STD_LOGIC_VECTOR(3 downto 0);
      num2			: in  STD_LOGIC_VECTOR(3 downto 0);
      blank_out 	: out STD_LOGIC_VECTOR(5 DOWNTO 0)
	);           
END Component;

Component PWM_DAC IS
	Generic ( width : integer := 13);
	PORT(
		reset_n    : in  STD_LOGIC;
      clk        : in  STD_LOGIC;
      duty_cycle : in  STD_LOGIC_VECTOR (width-1 downto 0);
      inverted_pwm_out    : out STD_LOGIC
	);
END Component;

Component module IS
	PORT    ( reset_n    : in  STD_LOGIC;
				 clk        : in  STD_LOGIC;
				 distance : in  STD_LOGIC_VECTOR (12 downto 0);
				 output    : out STD_LOGIC
				 
						);
END Component;

Component module2 IS
	PORT    ( reset_n    : in  STD_LOGIC;
				 clk        : in  STD_LOGIC;
				 distance : in  STD_LOGIC_VECTOR (12 downto 0);
				 output    : out STD_LOGIC
				 
						);
END Component;
begin
Num_Hex0 <= reg_out(3  downto  0); 
Num_Hex1 <= reg_out(7  downto  4);
Num_Hex2 <= reg_out(11 downto  8);
Num_Hex3 <= reg_out(15 downto 12);
Num_Hex4 <= "0000";
Num_Hex5 <= "0000";  
hex_mux_in <= X"00" & sync_output(7 downto 0);
ADC_avg_mux_in <= X"0" & ADC_avg_out;
					
ADC_ins0: ADC_Data
	PORT MAP (
		clk		=> clk,
		reset_n 	=> reset_n,
		voltage 	=> ADC_voltage,
		distance	=>	ADC_distance,
		ADC_out 	=> ADC_avg_out
	);

btn_debounce: debounce 
	Generic map (
		stable_time => 1 --when running a simulation make it 1ms so it runs faster
		--stable_time => 30 --when compiling and moving the code to the board use this
	)
	PORT MAP (
		clk      => clk,
		button   => set,
		result   => debounce_result
	);
	
switch_synchronizer: Synchronizer
	PORT MAP(
		clk		=> clk,
		enable	=> debounce_result,
		A			=> sw(9 downto 0),
		G			=> sync_output
	);
						
Hold_Register: Register_16bits
	PORT MAP(
		clk		=> clk,
		reset_n	=> reset_n,
		enable	=> debounce_result,
		D			=> mux_out,
		Q			=> reg_out
	);

voltage_binary_bcd: binary_bcd                               
	PORT MAP(
		clk      => clk,                          
		reset_n  => reset_n,                                 
		binary   => ADC_voltage,    
		bcd      => bcd_voltage      
	);
							
distance_binary_bcd: binary_bcd                               
	PORT MAP(
		clk      => clk,                          
		reset_n  => reset_n,                                 
		binary   => ADC_distance,    
		bcd      => bcd_distance         
	);
							

data_MUX4TO1: MUX4TO1
	PORT MAP( 
		in0 		=> hex_mux_in,
		in1 		=> bcd_distance,
		in2		=> bcd_voltage,
		in3		=> ADC_avg_mux_in,
		s   		=> sync_output(9 downto 8),
		mux_out	=> mux_out
	);
						
DP_MUX4TO1: MUX4TO1
	PORT MAP( 
		in0 		=> X"0000",
		in1 		=> X"0004",
		in2		=> X"0008",
		in3		=> X"0000",
		s   		=> sync_output(9 downto 8),
		mux_out	=> DP_in
	);
						
blank_select_ins0: blank_select
	PORT MAP(
		state		=> sync_output(9 downto 8),
		num1		=> Num_Hex3,
		num2		=> Num_Hex2,
		blank_out=> blank
	);
					
SevenSegment_ins: SevenSegment
	PORT MAP( 
		Num_Hex0 => Num_Hex0,
		Num_Hex1 => Num_Hex1,
		Num_Hex2 => Num_Hex2,
		Num_Hex3 => Num_Hex3,
		Num_Hex4 => Num_Hex4,
		Num_Hex5 => Num_Hex5,
		Hex0     => Hex0,
		Hex1     => Hex1,
		Hex2     => Hex2,
		Hex3     => Hex3,
		Hex4     => Hex4,
		Hex5     => Hex5,
		DP_in    => DP_in(5 downto 0),
		Blank    => Blank,
		enable => module_output
	);
	
LEDR_PWM : PWM_DAC
	PORT MAP(
		reset_n    => reset_n,
      clk        => clk,
      duty_cycle => ADC_distance,
		inverted_pwm_out	  => PWM_LED_OUT
	);
	
module_ins : module
	PORT MAP(
	reset_n => reset_n,
	clk     => clk,
	distance => ADC_distance,
	output  => module_output
	);
	

module_buzz : module2
	PORT MAP(
	reset_n => reset_n,
	clk     => clk,
	distance => ADC_distance,
	output  => buzzer_in

	);
buzz_out <=  buzzer_in;

LEDR(9 downto 0) <= PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT & PWM_LED_OUT; -- gives visual display of the switch inputs to the LEDs on board

--LEDR(9 downto 0) <= sw(9 downto 0);

end Behavioral;
