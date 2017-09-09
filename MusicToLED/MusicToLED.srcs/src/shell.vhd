----------------------------------------------------------------------------------
-- Company: 			Engs 31 16X
-- Engineer: 			Nicholas Corrente and Kenan Akin
-- 
-- Create Date:    	 	08/17/2017
-- Design Name: 		
-- Module Name:    		MusicToLED  (shell)
-- Project Name: 		MusicToLED
-- Target Devices: 		Digilent Basys3 (Artix 7)
-- Tool versions: 		Vivado 2016.1
-- Description: 		SPI Bus lab
--				
-- Dependencies:    pmod_ad1, SPI bus interface to Pmod AD1
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing

library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity MusicToLED is
port (mclk		: in std_logic;	    -- FPGA board master clock (100 MHz)

	-- SPI bus interface to Pmod AD1
      spi_sclk : out std_logic;
      spi_cs : out std_logic;
      spi_sdata : in std_logic;
      
      --
      seg : out std_logic_vector(0 to 9);
      an : out std_logic_vector(2 downto 0)
      );

end MusicToLED; 

architecture Behavioral of MusicToLED is

-- COMPONENT DECLARATIONS

-- pmod component
component pmod_ad1 is
   Port (
    sclk: in std_logic;
    take_sample: in std_logic;
    spi_sdata: in std_logic;
    ad_data: out std_logic_vector(11 downto 0);
    spi_sclk: out std_logic;
    spi_cs: out std_logic
    );
end component;

-- lowpass filter
component lowpassFilter is
    Port(
    clk : in std_logic;
    take_sample : in std_logic;
    data_in : in std_logic_vector (11 downto 0);
    data_out : out std_logic_vector (11 downto 0)
    );
end component;

-- highpass filter
component highpassFilter is
    Port(
    clk : in std_logic;
    take_sample : in std_logic;
    data_in : in std_logic_vector (11 downto 0);
    data_out : out std_logic_vector (11 downto 0)
    );
end component;

-- highpass filter
component bandpassFilter is
    Port(
    clk : in std_logic;
    take_sample : in std_logic;
    data_in : in std_logic_vector (11 downto 0);
    data_out : out std_logic_vector (11 downto 0)
    );
end component;

-- the decoder
component amplitudeDecoder is
    Port ( 
      amp_data_in : in std_logic_vector(11 downto 0);
      amp_data_out : out std_logic_vector(3 downto 0)
    );
end component;

-- the leds
component mux10seg is
    Port ( clk : in  STD_LOGIC;									-- runs on a fast (1 MHz or so) clock
           y0, y1, y2 : in  STD_LOGIC_VECTOR (3 downto 0);	-- digits
           seg : out  STD_LOGIC_VECTOR(0 to 9);				    -- segments (a...g)
           an : out  STD_LOGIC_VECTOR (2 downto 0) );	      -- anodes
end component;

---- filter  component 
COMPONENT digital_filter is
    port(
    clk: in std_logic;
    new_sample: in std_logic;
    x_in: in std_logic_vector(11 downto 0);
    y: out std_logic_vector(11 downto 0)
    );
end COMPONENT;


-------------------------------------------------
-- SIGNAL DECLARATIONS 
-- Signals for the serial clock divider, which divides the 100 MHz clock down to 10 MHz
constant SCLK_DIVIDER_VALUE: integer := 100/20;
constant COUNT_LEN: integer := integer(ceil( log2( real(SCLK_DIVIDER_VALUE) ) ));
signal sclkdiv: unsigned(COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter
signal sclk_unbuf: std_logic := '0';    -- unbuffered serial clock 
signal sclk: std_logic := '0';          -- internal serial clock

-- SIGNAL DECLARATIONS FOR YOUR CODE GO HERE
signal ad_data: std_logic_vector(11 downto 0) := (others => '0');	-- A/D output

-- Signals for the sampling clock, which ticks at 12 kHz
signal take_sample : std_logic := '0';
constant M: integer := 833;
constant SAMPLE_COUNT_LEN: integer := integer(ceil( log2( real(M) ) ));
signal sample_count: unsigned(SAMPLE_COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter

-- lowpass singal
signal lowpass_data_out : std_logic_vector(11 downto 0) := (others => '0');
signal lowpass_digital_filter_data_out : std_logic_vector(11 downto 0) := (others => '0');
signal lowpass_amp_data_out : std_logic_vector(3 downto 0) := (others => '0');

-- highpass singal
signal highpass_data_out : std_logic_vector(11 downto 0) := (others => '0');
signal highpass_digital_filter_data_out : std_logic_vector(11 downto 0) := (others => '0');
signal highpass_amp_data_out : std_logic_vector(3 downto 0) := (others => '0');

-- bandpass singal
signal bandpass_data_out : std_logic_vector(11 downto 0) := (others => '0');
signal bandpass_digital_filter_data_out : std_logic_vector(11 downto 0) := (others => '0');
signal bandpass_amp_data_out : std_logic_vector(3 downto 0) := (others => '0');

-------------------------------------------------
begin

-- Clock buffer for sclk
-- The BUFG component puts the signal onto the FPGA clocking network
Slow_clock_buffer: BUFG
	port map (I => sclk_unbuf,
		      O => sclk );
		         
-- Divide the 100 MHz clock down to 10 MHz, then toggling a flip flop gives the final 
Serial_clock_divider: process(mclk)
begin
  if rising_edge(mclk) then
         if sclkdiv = SCLK_DIVIDER_VALUE-1 then 
          sclkdiv <= (others => '0');
          sclk_unbuf <= NOT(sclk_unbuf);
      else
          sclkdiv <= sclkdiv + 1;
      end if;
  end if;
end process Serial_clock_divider;

-- Further divide the 10 MHz clock down to a 12 kHz take_sample tick
SampleCounter: process (sclk) is
begin
    if rising_edge(sclk) then
        if sample_count < M-1 then
             sample_count <= sample_count + 1;
             take_sample <= '0';
        else 
            sample_count <= (others => '0');
            take_sample <= '1';
         end if;
    end if;
end process;
            
-- INSTANTIATE THE A/D CONVERTER SPI BUS INTERFACE COMPONENT
pmod: pmod_ad1 port map(
    sclk => sclk,
    take_sample => take_sample,
    ad_data => ad_data,
    spi_sclk => spi_sclk,
    spi_cs => spi_cs,
    spi_sdata => spi_sdata
);

-- lowpass controls
lowpass: lowpassFilter port map(
    clk => sclk,
    take_sample => take_sample,
    data_in => ad_data,
    data_out => lowpass_data_out
);    

-- filter
lowpass_digital_filter: digital_filter port map (
      clk => sclk,
      new_sample => take_sample,
      x_in => lowpass_data_out,
      y => lowpass_digital_filter_data_out
);

lowpassAmp: amplitudeDecoder port map(
    amp_data_in => lowpass_digital_filter_data_out,
    amp_data_out => lowpass_amp_data_out
); 

-- highpass controls
highpass: highpassFilter port map(
    clk => sclk,
    take_sample => take_sample,
    data_in => ad_data,
    data_out => highpass_data_out
);    

-- filter
highpass_digital_filter: digital_filter port map (
      clk => sclk,
      new_sample => take_sample,
      x_in => highpass_data_out,
      y => highpass_digital_filter_data_out
);

highpassAmp: amplitudeDecoder port map(
    amp_data_in => highpass_digital_filter_data_out,
    amp_data_out => highpass_amp_data_out
); 

-- bandpass controls
bandpass: bandpassFilter port map(
    clk => sclk,
    take_sample => take_sample,
    data_in => ad_data,
    data_out => bandpass_data_out
);    

-- filter
bandpass_digital_filter: digital_filter port map (
      clk => sclk,
      new_sample => take_sample,
      x_in => bandpass_data_out,
      y => bandpass_digital_filter_data_out
);

bandpassAmp: amplitudeDecoder port map(
    amp_data_in => bandpass_digital_filter_data_out,
    amp_data_out => bandpass_amp_data_out
); 

leds: mux10seg port map(
    clk => sclk,
    y0 => lowpass_amp_data_out,
    y1 => bandpass_amp_data_out,
    y2 => highpass_amp_data_out,
    seg => seg,
    an => an
);
        
end Behavioral; 