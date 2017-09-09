----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Nicholas Corrente and Kenan Akin
-- 
-- Create Date: 07/25/2017 12:23:22 AM
-- Design Name: 
-- Module Name: pmod_ad1 - Behavioral
-- Project Name: MusicToLED
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
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity pmod_ad1 is
    port(
    sclk: in std_logic;
    take_sample: in std_logic;
    ad_data: out std_logic_vector(11 downto 0);
    spi_sclk: out std_logic;
    spi_cs: out std_logic;
    spi_sdata: in std_logic);
end entity;

architecture behavior of pmod_ad1 is

-- controller signals
signal counter_reset: std_logic := '0';
signal shift_en, load_en: std_logic := '0';

-- data path signals
signal ser_data_reg: std_logic_vector(11 downto 0) := (others => '0');

-- controller states and state ty
type state_type is (idle, shifting, load);
signal PS, NS: state_type;

-- counter signals
signal counter_count: unsigned(3 downto 0) := x"0";
signal counter_tc: std_logic := '0';

begin

spi_sclk <= sclk;

ShiftRegister: process (sclk, shift_en, spi_sdata) is
begin
    if rising_edge(sclk) then
        if shift_en = '1' then
            ser_data_reg <= ser_data_reg(10 downto 0) & spi_sdata;
        end if;
    end if;
end process;

OutoutRegister: process (sclk, load_en, ser_data_reg)
begin
    if rising_edge(sclk) then
        if load_en = '1' then
            ad_data <= not(ser_data_reg(11)) & ser_data_reg(10 downto 0);
        end if;
    end if;
end process;

StateUpdate: process(sclk) is
begin
    if rising_edge(sclk) then
        PS <= NS;
    end if;
end process;

-- state machine logic

CombLogic: process(PS, take_sample, counter_tc) is
begin
    NS <= PS;
    counter_reset <= '0';
    load_en <= '0';
    shift_en <= '0';
    spi_cs <= '0';

    case PS is
        when idle =>
            counter_reset <= '1';
            spi_cs <= '1';
            if take_sample = '1' then
                NS <= shifting;
            end if;
        when shifting =>
            shift_en <= '1';
            if counter_tc = '1' then
                NS <= load;
            end if;
        when load =>
            spi_cs <= '1';
            load_en <= '1';
            NS <= idle;
        when others =>
            NS <= idle;
            counter_reset <= '0';
            load_en <= '0';
            shift_en <= '0';
    end case;
end process;

Counter: process(sclk, counter_count, counter_reset) is
begin
    if rising_edge(sclk) then
        counter_count <= counter_count + 1;
        if counter_reset = '1' then
            counter_count <= x"0";
        end if;
    end if;

    if counter_count = 14 then -- check if 13 or 14
        counter_tc <= '1';
    else
        counter_tc <= '0';
    end if;
end process;

end behavior;

