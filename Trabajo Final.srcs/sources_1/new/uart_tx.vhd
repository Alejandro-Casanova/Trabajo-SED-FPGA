----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2022 12:02:03
-- Design Name: 
-- Module Name: uart_tx - Behavioral
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

entity uart_tx is
    Port ( i_Clk : in STD_LOGIC;
           i_TX_Start : in STD_LOGIC;
           i_TX_Parallel : in STD_LOGIC_VECTOR (7 downto 0);
           o_TX_Serial : out STD_LOGIC;
           o_TX_Done : out STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is

begin


end Behavioral;
