----------------------------------------------------------------------------------
-- Company:
-- Engineer: Nicholas Corrente
--
-- Create Date: 08/22/2017 03:43:39 PM
-- Design Name:
-- Module Name: MusicToLED_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MusicToLED_tb is
--  Port ( );
end MusicToLED_tb;

architecture Behavioral of MusicToLED_tb is

component MusicToLED is
port (mclk		: in std_logic;	    -- FPGA board master clock (100 MHz)

	-- SPI bus interface to Pmod AD1
      spi_sclk : out std_logic;
      spi_cs : out std_logic;
      spi_sdata : in std_logic;

      --
      seg : out std_logic_vector(0 to 9);
      an : out std_logic_vector(2 downto 0)
      );
end component;

signal clk : std_logic := '0';
signal sclk: std_logic := '0';

signal spi_cs, spi_sdata : std_logic := '0';

signal seg : std_logic_vector (0 to 9) := (others => '0');
signal an : std_logic_vector (2 downto 0) := (others => '0');


-- signals
constant clk_period : time := 10 ns;

begin

uut: MusicToLED port map (
    mclk => clk,
    spi_sclk => sclk,
    spi_cs => spi_cs,
    spi_sdata => spi_sdata,
    seg => seg,
    an => an
);

clk_gen: process
begin
loop
    clk <= not(clk);
    wait for clk_period/2;
end loop;
end process;

stim: process
begin
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '0';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '0';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '0';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '0';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '0';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '0';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
spi_sdata <= '1';
wait for 23000 ns;
end process;

end Behavioral;
