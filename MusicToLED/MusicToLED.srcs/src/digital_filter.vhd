----------------------------------------------------------------------------------
-- Company: 			Engs 31 16X
-- Engineer: 		 Nicholas Corrente and Kenan Akin
-- 
-- Create Date:    	 	08/01/2017
-- Design Name: 		
-- Module Name:    		digital_fitler 
-- Project Name: 		MusictoLED
-- Target Devices: 		Digilent Basys3 (Artix 7)
-- Tool versions: 		Vivado 2016.1
-- Description: 		SPI Bus lab
--				
-- Dependencies: 		mux10seg, multiplexed 10 segment display
--						pmod_ad1, SPI bus interface to Pmod AD1
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_filter is
    port(
    clk: in std_logic;
    new_sample: in std_logic;
    x_in: in std_logic_vector(11 downto 0);
    y: out std_logic_vector(11 downto 0)
    );
end entity;

architecture behavior of digital_filter is

    -- accumulator signals
    signal accumulator_en: std_logic := '0';
    signal accumulator_clr: std_logic := '0';
    signal accumulated_value: signed(30 downto 0) := (others => '0');
    signal shifted_output: std_logic_vector(30 downto 0) := (others => '0');
    
    signal x : signed (23 downto 0) := (others => '0');

    constant AVERAGE_AMOUNT : integer := 128;
    
    -- output singal
    signal output_en: std_logic := '0';
    
    -- counter signals
    signal counter_tc: std_logic := '0';
    signal counter_count: integer := 0;
    signal counter_reset: std_logic := '0';
    
    -- controller states and state typs
    type state_type is (accum, load);
    signal PS, NS: state_type;

    begin

    x <= signed(x_in) * signed(x_in);
    
-- accumulator
    accumulator: process (clk, x, new_sample, accumulator_en, accumulator_clr) is
    begin
        if rising_edge(clk) then
            if accumulator_clr = '1' then
                accumulated_value <= (others => '0');
            else
                if new_sample = '1' then
                    accumulated_value <= x + accumulated_value;
                end if;
            end if;
        end if;
    end process;

-- counter
    counter: process (clk, new_sample, counter_count, counter_reset) is
    begin
        if rising_edge(clk) then
            if new_sample = '1' then
                counter_count <= counter_count + 1;
            end if;
            
            if counter_reset = '1' then
                counter_count <= 0;
            end if;
        end if;

        counter_tc <= '0';
        if counter_count = AVERAGE_AMOUNT then
            counter_tc <= '1';
        end if;
    end process;

-- output register
    output_register: process (clk, shifted_output, accumulated_value, output_en) is
    begin
    
        shifted_output <= std_logic_vector(accumulated_value/AVERAGE_AMOUNT);
        
        if rising_edge(clk) then
            if output_en = '1' then
                y <= shifted_output(16 downto 5);
            end if;
        end if;
    end process;

-- state update for controller
    StateUpdate: process(clk) is
    begin
        if rising_edge(clk) then
            PS <= NS;
        end if;
    end process;

-- contoller logic
    CombLogic: process(PS, new_sample, counter_tc) is
    begin
        NS <= PS;
        accumulator_en <= '0';
        output_en <= '0';
        accumulator_clr <= '0';
        counter_reset <= '0';

        case PS is
            when accum =>
                accumulator_en <= '1';
                if counter_tc = '1' then
                    NS <= load;
                end if;
            when load =>
                output_en <= '1';
                accumulator_clr <= '1';
                counter_reset <= '1';
                NS <= accum;
            when others =>
                NS <= accum;
                accumulator_clr <= '1';
                accumulator_en <= '1';
        end case;
    end process;


end behavior;
