----------------------------------------------------------------------------------
-- Company: 			Engs 31 16X
-- Engineer: 			E.W. Hansen -- modified by Nicholas Corrente
-- 
-- Create Date:    	    17:56:35 07/25/2008
-- Design Name: 	
-- Module Name:    	    mux7seg - Behavioral 
-- Project Name: 		
-- Target Devices: 	    Digilent Basys 3 board (Artix 7)
-- Tool versions: 	    Vivado 2016.1
-- Description: 		Multiplexed 10-segment decoder
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 1.00 (07/17/2015) --- drop the clock divider, run on a 1000 Hz clock
-- Revision 2.00 (07/17/2016) --- put the clock divider back in
-- Revision 3.00 (08/18/2017) --- converted from 8 seg 4 an to 10 seg 3 an.
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mux10seg is
    Port ( clk : in  STD_LOGIC;									-- runs on a fast (1 MHz or so) clock
           y0, y1, y2 : in  STD_LOGIC_VECTOR (3 downto 0);	-- digits
           seg : out  STD_LOGIC_VECTOR(0 to 9);				    -- segments (a...g)
           an : out  STD_LOGIC_VECTOR (2 downto 0) );	      -- anodes
end mux10seg;

architecture Behavioral of mux10seg is
	constant NCLKDIV:     integer := 15;                     -- 10 MHz / 2^18 = 390 Hz
    constant MAXCLKDIV:   integer := 2**NCLKDIV-1;           -- max count of clock divider
    signal cdcount:       unsigned(NCLKDIV-1 downto 0);      -- clock divider counter register
    signal CE :           std_logic;                         -- clock enable

	signal adcount : unsigned(1 downto 0) := "00";		     -- anode / mux selector count
	signal anb: std_logic_vector(2 downto 0);
	signal muxy : std_logic_vector(3 downto 0);			     -- mux output
	signal segh : std_logic_vector(0 to 9);				     -- segments (high true)

begin			
-- Clock divider sets the rate at which the display hops from one digit to the next.  A larger value of
-- MAXCLKDIV results in a slower clock-enable (CE)
ClockDivider:
process(clk)		
begin 
	if rising_edge(clk) then 
	   if cdcount < MAXCLKDIV then
	        CE <= '0';
			cdcount <= cdcount+1;	
	   else CE <= '1';
	        cdcount <= (others => '0');
	   end if;
	end if;
end process ClockDivider;

AnodeDriver:
process(clk, adcount)
begin	
	if rising_edge(clk) then
	   if CE='1' then
		  adcount <= adcount + 1;
	   end if;
	end if;
	
	case adcount is
		when "00" => anb <= "001"; 
		when "01" => anb <= "010"; 
		when "10" => anb <= "100"; 
		when "11" => anb <= "000"; 
		when others => anb <= "000";
	end case;
end process AnodeDriver;

an <= anb;   --- blank digit 3

Multiplexer:
process(adcount, y0, y1, y2)
begin
	case adcount is
		when "00" => muxy <= y0;
		when "01" => muxy <= y1;
		when "10" => muxy <= y2;
		when others => muxy <= x"0";
	end case;
end process Multiplexer;

-- 8 segment decoder
with muxy select segh <=
	"0000000000" when x"0",		-- active-high definitions
	"0000000001" when x"1",
	"0000000011" when x"2",
	"0000000111" when x"3",
	"0000001111" when x"4",
	"0000011111" when x"5",
	"0000111111" when x"6",
	"0001111111" when x"7",
	"0011111111" when x"8",
	"0111111111" when x"9",	
	"1111111111" when x"a",	

	"0000000000" when others;	
	
seg <= not(segh);				-- Convert to active-low

end Behavioral;

