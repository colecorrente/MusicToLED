----------------------------------------------------------------------------------
-- Company:
-- Engineer: Nicholas Corrente
--
-- Create Date: 08/15/2017 10:27:24 PM
-- Design Name:
-- Module Name: lowpassFilter_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lowpassFilter_tb is
--  Port ( );
end lowpassFilter_tb;

architecture Behavioral of lowpassFilter_tb is


component lowpassFilter is
  Port ( clk : in std_logic;
         take_sample : in std_logic;
         data_in : in std_logic_vector (11 downto 0);
         data_out : out std_logic_vector (11 downto 0));
end component;

-- signals
signal clk: std_logic := '0';
signal take_sample: std_logic := '0';
signal data_in :  std_logic_vector (11 downto 0) := (others => '0');
signal data_out : std_logic_vector (11 downto 0) := (others => '0');

constant clk_period : time := 100 ns;

constant take_sample_period : real := 1.0/12000.0;                     -- Sampling period (sec)
signal t : real := 0.0 ;

 signal analog_sin : std_logic_vector(11 downto 0) := "000000000000";   -- 14-bit A/D converter
 signal SIN_FREQ : real := 20.0;                           -- Hz
 constant SIN_AMPL : real := 2047.0;                                      -- 2^13 - 1

begin

uut: lowpassFilter port map (
    clk => clk,
    take_sample => take_sample,
    data_in => data_in,
    data_out => data_out
);

clk_gen: process
begin
loop
    clk <= not(clk);
    wait for clk_period/2;
end loop;
end process;

stim_procc: process
begin
    t <= t + take_sample_period;
    analog_sin <= std_logic_vector(to_signed(integer( SIN_AMPL*sin(math_2_pi*SIN_FREQ*t) ), analog_sin'length));


    take_sample <= '1';
    wait for clk_period;
    take_sample <= '0';
    wait for take_sample_period *  (1e6 us) - clk_period;

end process;

data_in <= analog_sin;

end Behavioral;
