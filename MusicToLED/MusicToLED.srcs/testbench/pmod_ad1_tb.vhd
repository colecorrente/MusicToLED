--------------------------------------------------------------------------------
-- Engineer:        Eric Hansen modified by Nicholas Corrente
-- Course:	 		Engs 31 16X
--
-- Create Date:     07/22/2016
-- Design Name:
-- Module Name:     pmod_ad1_tb.vhd
-- Project Name:    Lab5
-- Target Device:
-- Tool versions:
-- Description:     VHDL Test Bench for module: pmod_ad1
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
use IEEE.MATH_REAL.ALL;

ENTITY pmod_ad1_tb IS
END pmod_ad1_tb;

ARCHITECTURE behavior OF pmod_ad1_tb IS

component pmod_ad1
port (-- interface to top level
        sclk		: in std_logic;	    -- serial clock
        take_sample : in STD_LOGIC;
        ad_data : out STD_LOGIC_VECTOR (11 downto 0);

      -- SPI bus interface to Pmod AD1
        spi_sclk : out std_logic;
        spi_cs : out std_logic;
        spi_sdata : in std_logic );
end component;

   --Inputs
    signal sclk : std_logic := '0';
    signal take_sample : std_logic := '0';
    signal spi_sdata : std_logic := '0' ;

 	--Outputs
    signal spi_sclk : std_logic := '0' ;
    signal spi_cs : std_logic := '1';
    signal ad_data : std_logic_vector(11 downto 0) := (others => '0');

    -- Clock period definitions
    constant sclk_period : time := 1 us;		   -- 1 MHz serial clock
    constant sampling_count_tc : integer := 25;    -- to achieve a 40 kHz sampling rate, for testing

	-- Data definitions
	constant TxData : std_logic_vector(14 downto 0) := "111000001101001";
	signal bit_count : integer := 14;

	-- Internal definitions
	signal sampling_count : integer := 0;

BEGIN
	-- Instantiate the Unit Under Test (UUT)

uut: pmod_ad1 port map(
        sclk => sclk,
        take_sample => take_sample,
        ad_data => ad_data,

        -- SPI bus interface to Pmod AD1
        spi_sclk => spi_sclk,
        spi_cs => spi_cs,
        spi_sdata => spi_sdata );

   -- Clock process definitions
   clk_process: process
   begin
		sclk <= '0';
		wait for sclk_period/2;
		sclk <= '1';
		wait for sclk_period/2;
   end process;

   -- Stimulus process:  testbench pretends to the top level
   stim_proc_1: process(sclk)
   begin
    if rising_edge(sclk) then
        if sampling_count < sampling_count_tc-1 then
            sampling_count <= sampling_count + 1;
            take_sample <= '0';
        else
            sampling_count <= 0;
            take_sample <= '1';      -- push take_sample to interface to initiate a conversion
        end if;
    end if;
   end process stim_proc_1;

   -- Stimulus process:  testbench pretends to be the A/D converter
   stim_proc_2: process(spi_sclk)
   begin
    if falling_edge(spi_sclk) then   -- clock data out on falling edge, MSB first
        if spi_cs = '0' then		 -- watch for SPI interface to activate the A/D
			spi_sdata <= TxData(bit_count);
			if bit_count = 0 then bit_count <= 14;
			else bit_count <= bit_count - 1;
			end if;
		end if;
    end if;
   end process stim_proc_2;
END;
