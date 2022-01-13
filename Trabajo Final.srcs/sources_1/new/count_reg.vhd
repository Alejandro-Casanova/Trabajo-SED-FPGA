----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.01.2022 10:41:55
-- Design Name: 
-- Module Name: count_reg - Behavioral
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

-- Stores an 8 bit value when i_Capture receives a pulse 

entity count_reg is
    Generic( g_word_length : positive := 8);
    Port ( i_CLK : in STD_LOGIC;
           i_Reset_N : in std_logic;
           i_Data : in STD_LOGIC_VECTOR ((g_word_length - 1) downto 0);
           i_Capture : in STD_LOGIC; -- Pulso
           o_Data : out STD_LOGIC_VECTOR ((g_word_length - 1) downto 0));
end count_reg;

architecture Behavioral of count_reg is
    signal count : unsigned((g_word_length - 1) downto 0) := (others => '0');
begin
    o_Data <= std_logic_vector(count);
    process(i_Clk, i_Reset_N) is
    begin
        if i_Reset_N = '0' then
            count <= (others => '0');
        elsif rising_edge(i_CLK) then
            if i_Capture = '1' then
                count <= unsigned(i_Data);
            end if;
        end if; 
    end process;
end Behavioral;
