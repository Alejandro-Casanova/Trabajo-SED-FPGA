----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.01.2022 11:22:21
-- Design Name: 
-- Module Name: tb_count_reg - Behavioral
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
use IEEE.std_logic_arith.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_count_reg is
--  Port ( );
end tb_count_reg;

architecture Behavioral of tb_count_reg is
    constant n_bits : positive := 8;
    
    component count_reg is
        Generic( g_word_length : positive := n_bits);
        Port ( i_CLK : in STD_LOGIC;
               i_Reset_N : in std_logic;
               i_Data : in STD_LOGIC_VECTOR ((g_word_length - 1) downto 0);
               i_Capture : in STD_LOGIC; -- Pulso
               o_Data : out STD_LOGIC_VECTOR ((g_word_length - 1) downto 0));
    end component count_reg;

    signal i_CLK     : std_logic;
    signal i_Reset_N   : std_logic := '1';
    signal i_Data    : std_logic_vector (n_bits - 1 downto 0);
    signal i_Capture : std_logic;
    signal o_Data    : std_logic_vector (n_bits - 1 downto 0);

    constant TbPeriod : time := 100 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    
begin
    uut : count_reg
    port map (i_CLK     => i_CLK,
              i_Reset_N   => i_Reset_N,
              i_Data    => i_Data,
              i_Capture => i_Capture,
              o_Data    => o_Data);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2;
    -- EDIT: Check that i_CLK is really your main clock signal
    i_CLK <= TbClock;

    stimuli : process
    begin
        for i in 0 to 255 loop
            i_Data <= std_logic_vector(to_unsigned(integer(i), n_bits));
            i_Capture <= '1';
            wait for TbPeriod;
            i_Capture <= '0';
            
            if o_Data /= std_logic_vector(to_unsigned(integer(i), n_bits)) then
                report "Test Failed - Incorrect Value" severity failure;
            end if;
        end loop; 
        
        i_Reset_N <= '0';
        wait for TbPeriod; 
        if o_Data /= std_logic_vector(to_unsigned(0, n_bits)) then
            report "Test Failed - Reset" severity failure;
        end if;
        
        assert false report "Tests Complete" severity failure;
    end process;
    
end Behavioral;
