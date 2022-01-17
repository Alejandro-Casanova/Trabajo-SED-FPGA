----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.11.2021 20:05:28
-- Design Name: 
-- Module Name: debouncer - Behavioral
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
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
    Generic( clockFreq : integer range 0 to integer'high := 100000000;
             deadTime_ns : integer range 0 to integer'high := 1000); -- Nanosegundos
    Port ( pulse_in : in STD_LOGIC;
           CLK : in STD_LOGIC;
           pulse_out : out STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
    signal s_pulse_out : std_logic := '0';
begin

    pulse_out <= s_pulse_out;
    
    process(CLK)
        constant max_count : integer := (clockFreq * deadTime_ns / 1000000000);
        variable counter : integer := max_count;
    begin
        if rising_edge(CLK) then
            s_pulse_out <= '0';
            if pulse_in = '1' and counter = max_count then
                s_pulse_out <= '1';
                counter := 0;        
            elsif counter < max_count then
                counter := counter + 1;
            end if;
        end if;    
    end process;
        
end architecture Behavioral;
