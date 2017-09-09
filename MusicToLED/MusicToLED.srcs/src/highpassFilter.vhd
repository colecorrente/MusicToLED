----------------------------------------------------------------------------------
-- Company:     ENGS 31 Final Project
-- Engineer:  Nicholas Corrente
-- 
-- Create Date: 08/15/2017 09:47:18 PM
-- Design Name: 
-- Module Name: highpassFilter - Behavioral
-- Project Name:   
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:b n------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity highpassFilter is
    Port ( clk : in std_logic;
           take_sample : in std_logic;
           data_in : in std_logic_vector (11 downto 0);
           data_out : out std_logic_vector (11 downto 0));
end highpassFilter;

architecture Behavioral of highpassFilter is

-- N constant which determines number of samples in Fifo, thus sample rate/N = filter cutoff.
constant N : integer  := 8;

-- unsigned in and out
signal data_in_signed : signed (11 downto 0) := (others => '0');

-- fifo array
type fifo256 is array (N-1 downto 0) of signed(11 downto 0);
signal fifo : fifo256 := (others => (others => '0'));

-- fifo sum register
signal fifo_sum : signed(20 downto 0) := (others => '0');
-- fifo average register
signal fifo_average : signed(20 downto 0) := (others => '0');

-- state machine sginals
type state_type is (idle, fifo_load, sum, load_clear);
signal PS, NS: state_type;
-- state machine counter                 
signal counter_tc: std_logic := '0';
signal count: unsigned(7 downto 0) := (others => '0');
signal counter_reset: std_logic := '0';
signal count_en: std_logic := '0';

signal fifo_load_en: std_logic := '0';
signal sum_en: std_logic := '0';
signal accum_clr: std_logic := '0';
signal output_load_en: std_logic := '0';

begin

data_in_signed <= signed(data_in);

fifo_proc: process (clk, fifo_load_en) is
begin
if rising_edge(clk) then
       if fifo_load_en = '1' then  
            for i in 1 to N-1 loop
                fifo(i) <= fifo(i-1);
            end loop;
            fifo(0) <= data_in_signed;
      end if;
end if;
end process;

accum: process (clk, sum_en, accum_clr) is
begin
if rising_edge(clk) then
       if accum_clr = '1' then
            fifo_sum <= (others => '0');
       elsif sum_en = '1' then  
           fifo_sum <= fifo_sum + fifo(to_integer(count)) - fifo(to_integer(count+1));
       end if;
     end if;
end process;

output: process (clk, fifo_sum) is
begin
    fifo_average <= fifo_sum / N;
    if rising_edge(clk) then
        if output_load_en = '1' then
            data_out <= std_logic_vector(fifo_average(11 downto 0));
        end if;
    end if;
end process;

counter: process (clk, count, counter_reset) is
begin
    if rising_edge(clk) then
        if count_en = '1' then
            count <= count + 2;
        end if;
        
        if counter_reset = '1' then
            count <= (others => '0');
        end if;
    end if;

    counter_tc <= '0';
    if count = N-2 then
        counter_tc <= '1';
    end if;
end process;

-- state machine - controller
StateUpdate: process(clk) is
begin
    if rising_edge(clk) then
        PS <= NS;
    end if;
end process;

CombLogic: process(PS, take_sample, counter_tc, clk) is
begin
    NS <= PS;
    
    fifo_load_en <= '0';
    sum_en <= '0';
    accum_clr <= '0';
    count_en <= '0';
    counter_reset <= '0';
    output_load_en <= '0';
    
    case PS is
        when idle =>
            if take_sample = '1' then
                NS <= fifo_load;
            end if;
        when fifo_load =>
            fifo_load_en <= '1';
             NS <= sum;
        when sum =>
            count_en <= '1';
            sum_en <= '1';
            if counter_tc = '1' then
             NS <= load_clear;
            end if;
        when load_clear =>
            accum_clr <= '1';
            output_load_en <= '1';
            counter_reset <= '1';
            NS <= idle;
        when others =>
            NS <= idle;
    end case;
end process;

end Behavioral;