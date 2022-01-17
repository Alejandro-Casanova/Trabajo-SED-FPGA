----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 21:10:58
-- Design Name: 
-- Module Name: edge_dtctr - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity edge_dtctr is
    Port ( clk : in STD_LOGIC;
           sync_in : in STD_LOGIC;
           edge : out STD_LOGIC);
end edge_dtctr;

architecture Behavioral of edge_dtctr is
    signal sreg : std_logic_vector(2 downto 0);
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            sreg <= sreg(1 downto 0) & SYNC_IN;
        end if;
    end process;
    
    with sreg select
        EDGE <= '1' when "001",
        '0' when others;

end Behavioral;
