----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Nicholas Corrente
-- 
-- Create Date: 08/21/2017 09:20:21 PM
-- Design Name: 
-- Module Name: bandpassFilter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:   Subtracts the high and low frequencies from the signal
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bandpassFilter is
 Port ( clk : in std_logic;
          take_sample : in std_logic;
          data_in : in std_logic_vector (11 downto 0);
          data_out : out std_logic_vector (11 downto 0));
end bandpassFilter;

architecture Behavioral of bandpassFilter is

component highpassFilter is
   Port ( clk : in std_logic;
        take_sample : in std_logic;
        data_in : in std_logic_vector (11 downto 0);
        data_out : out std_logic_vector (11 downto 0));
end component;

component lowpassFilter is
   Port ( clk : in std_logic;
        take_sample : in std_logic;
        data_in : in std_logic_vector (11 downto 0);
        data_out : out std_logic_vector (11 downto 0));
end component;

    signal lowpass_out : std_logic_vector (11 downto 0);
    signal highpass_out : std_logic_vector (11 downto 0);

begin

lowpass: lowpassFilter port map (
    clk => clk,
    take_sample => take_sample,
    data_in => data_in,
    data_out => lowpass_out
);

highpass: highpassFilter port map (
    clk => clk,
    take_sample => take_sample,
    data_in => data_in,
    data_out => highpass_out
);

data_out <= std_logic_vector(signed(data_in) - signed(highpass_out) - signed(lowpass_out));

end Behavioral;
