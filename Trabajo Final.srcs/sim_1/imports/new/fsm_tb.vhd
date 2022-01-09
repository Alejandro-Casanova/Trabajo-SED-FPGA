----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2021 00:46:08
-- Design Name: 
-- Module Name: fsm_tb - Behavioral
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

entity tb_fsm is
end tb_fsm;

architecture tb of tb_fsm is

    component fsm
        port (RESET      : in std_logic;
              CLK        : in std_logic;
              PUSHBUTTON : in std_logic;
              LIGHT      : out std_logic_vector (0 to 3));
    end component;

    signal RESET      : std_logic;
    signal CLK        : std_logic;
    signal PUSHBUTTON : std_logic;
    signal LIGHT      : std_logic_vector (0 to 3);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : fsm
    port map (RESET      => RESET,
              CLK        => CLK,
              PUSHBUTTON => PUSHBUTTON,
              LIGHT      => LIGHT);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that CLK is really your main clock signal
    CLK <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RESET <= '1';
        PUSHBUTTON <= '0';

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Count test
        for i in 1 to 6 loop
            PUSHBUTTON <= '1';
            wait for TbPeriod;
            PUSHBUTTON <= '0';
            wait for 10 * TbPeriod;
        end loop;
        
        -- Reset Test
        RESET <= '0';
        wait for 10 * TbPeriod;
        RESET <= '1';
            
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

