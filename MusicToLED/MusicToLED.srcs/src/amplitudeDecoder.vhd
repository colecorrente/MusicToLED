----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Nicholas Corrente
-- 
-- Create Date: 08/21/2017 07:46:06 PM
-- Design Name: 
-- Module Name: amplitudeDecoder - Behavioral
-- Project Name:  MusicToLED
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

entity amplitudeDecoder is
  Port ( 
  amp_data_in : in std_logic_vector(11 downto 0);
  amp_data_out : out std_logic_vector(3 downto 0)
  );
end amplitudeDecoder;

architecture Behavioral of amplitudeDecoder is

begin
-- decode input bits from 11 bits to 4
process(amp_data_in) is
begin
if amp_data_in(11) = '1' then
   amp_data_out <= x"a";
elsif amp_data_in(10) = '1' then
   amp_data_out <= x"9";
elsif amp_data_in(9) = '1' then
   amp_data_out <= x"8";
elsif amp_data_in(8) = '1' then
   amp_data_out <= x"7";
elsif amp_data_in(7) = '1' then
   amp_data_out <= x"6";
elsif amp_data_in(6) = '1' then
   amp_data_out <= x"5";
elsif amp_data_in(5) = '1' then
  amp_data_out <= x"4";
elsif amp_data_in(4) = '1' then
  amp_data_out <= x"3";
elsif amp_data_in(3) = '1' then
  amp_data_out <= x"2";
elsif amp_data_in(2) = '1' then
  amp_data_out <= x"1";
elsif amp_data_in(1) = '1' then
  amp_data_out <= x"0";
else 
  amp_data_out <= x"0";  
end if;
end process;

end Behavioral;
