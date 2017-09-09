----------------------------------------------------------------------------------
-- Company:     Engs 31, 17X
-- Engineer:    E.W. Hansen modified by Nicholas Corrente
--
-- Create Date: 07/30/2016 05:53:43 AM
-- Design Name:
-- Module Name: digital_filter_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Testbench for Lab 6 digital filter module
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity digital_filter_tb is
--  Port ( );
end digital_filter_tb;

architecture Behavioral of digital_filter_tb is
    constant K: integer := 6;
    constant M: integer := 12;

    component digital_filter is
        Port ( clk : in STD_LOGIC;
               new_sample : in STD_LOGIC;
               x : in STD_LOGIC_VECTOR (M-1 downto 0);
               y : out STD_LOGIC_VECTOR (M-1 downto 0));
    end component;

    signal sclk, take_sample : std_logic := '0';
    signal x : std_logic_vector(M-1 downto 0) := (others => '0');
    signal y : std_logic_vector(M-1 downto 0) := (others => '0');

   -- Clock period definitions
    constant sclk_period : time := 500 ns;		   -- 2 MHz serial clock
    constant sampling_count_tc : integer := 25;    -- to achieve a 80 kHz sampling rate, for testing

begin

uut: digital_filter
    port map ( clk => sclk, new_sample => take_sample, x => x, y => y );

-- Clock process definitions
clk_process: process
begin
    sclk <= '0';
    wait for sclk_period/2;
    sclk <= '1';
    wait for sclk_period/2;
end process;

-- Stimulus process
stim_process:  process
begin
    wait for 10.25*sclk_period;

    -- unit sample respo;nse
    -- If we put 64 in, 1 comes out
    x <= x"040";
    take_sample <= '1';
    wait for sclk_period;
    take_sample <= '0';
    wait for (sampling_count_tc-1) * sclk_period;
    x <= x"000";

    for n in 1 to 2**K-1 loop
        take_sample <= '1';
        wait for sclk_period;
        take_sample <= '0';
        wait for (sampling_count_tc-1) * sclk_period;
    end loop;

    -- step response
    -- If we put 2048 in, 2048 comes out
    x <= x"800";
    for n in 0 to 2**K-1 loop
        take_sample <= '1';
        wait for sclk_period;
        take_sample <= '0';
        wait for (sampling_count_tc-1) * sclk_period;
    end loop;

    x <= x"000";
    wait;

end process stim_process;

end Behavioral;
