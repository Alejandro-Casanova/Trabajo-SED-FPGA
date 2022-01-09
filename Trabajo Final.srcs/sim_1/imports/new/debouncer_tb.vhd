----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.11.2021 20:34:40
-- Design Name: 
-- Module Name: debouncer_tb - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity tb_debouncer is
end tb_debouncer;

architecture tb of tb_debouncer is

    component debouncer
        Generic( clockFreq : integer range 0 to integer'high := 100000000;
             deadTime_ns : integer range 0 to integer'high := 1000); -- Nanosegundos
        Port ( pulse_in : in STD_LOGIC;
               CLK : in STD_LOGIC;
               pulse_out : out STD_LOGIC);
    end component;

    signal pulse_in  : std_logic;
    signal CLK       : std_logic;
    signal pulse_out : std_logic;

    constant TbPeriod : time := 10 ns; -- Reloj de 100 MHz
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : debouncer
    port map (pulse_in  => pulse_in,
              CLK       => CLK,
              pulse_out => pulse_out);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that CLK is really your main clock signal
    CLK <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        pulse_in <= '0';

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod + 3 ns;
        pulse_in <= '1';
        wait for 10 * TbPeriod;
        pulse_in <= '0';
        wait for 2 * TbPeriod;
        pulse_in <= '1';
        wait for 25 * TbPeriod;
        pulse_in <= '0';
        wait for 4 * TbPeriod;
        pulse_in <= '1';
        wait for 30 * TbPeriod;
        pulse_in <= '0';
        wait for 15 * TbPeriod;
        pulse_in <= '1';
        wait for 2 * TbPeriod;
        pulse_in <= '0';
        wait for 25 * TbPeriod;
        pulse_in <= '1';
        wait for 2 * TbPeriod;
        pulse_in <= '0';
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
