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

-- Design based on code at "www.nandland.com"
-- https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    generic (g_CLK_Freq       : integer := 100000000;
             g_UART_Baud_Rate : integer := 115200
    );
    Port ( i_Clk            : in STD_LOGIC;
           i_TX_Start       : in STD_LOGIC; -- Receives a pulse to start transmition
           i_TX_Parallel    : in STD_LOGIC_VECTOR (7 downto 0);
           o_TX_Serial      : out STD_LOGIC;
           o_TX_Done        : out STD_LOGIC); -- Sends pulse to signal transmition end
end uart_tx;

architecture Behavioral of uart_tx is

    constant c_CLKS_PER_BIT : integer := g_CLK_Freq / g_UART_Baud_Rate;
    
    type t_FSM is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
                   s_TX_Stop_Bit, s_Cleanup);
    signal r_FSM : t_FSM := s_Idle;
 
    signal r_Clk_Count : integer range 0 to c_CLKS_PER_BIT - 1 := 0;
    signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
    signal r_TX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
    signal r_TX_Done   : std_logic := '0';
    
begin

    p_UART_TX : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            case r_FSM is
            
                when s_Idle =>
                    o_TX_Serial <= '1';    -- Drive Line High for Idle
                    r_TX_Done   <= '0';
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 0;
                
                    if i_TX_Start = '1' then -- Transmition Starts
                        r_TX_Byte <= i_TX_Parallel; -- Stores Byte to be sent
                        r_FSM <= s_TX_Start_Bit;
                    else
                        r_FSM <= s_Idle;
                    end if;
                    
                -- Send out Start Bit. Start bit = 0
                when s_TX_Start_Bit =>
                    o_TX_Serial <= '0';
                    
                    -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
                    if r_Clk_Count < c_CLKS_PER_BIT - 1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_FSM       <= s_TX_Start_Bit;
                    else -- Start Data transmition
                        r_Clk_Count <= 0;
                        r_FSM       <= s_TX_Data_Bits;
                    end if;
                    
                -- Send all Data bits      
                when s_TX_Data_Bits =>
                    o_TX_Serial <= r_TX_Byte(r_Bit_Index); -- Writes current bit on serial line
                
                    if r_Clk_Count < c_CLKS_PER_BIT - 1 then -- Waits 1 UART cycle
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_FSM       <= s_TX_Data_Bits;
                    else -- Bit transmition finished
                        r_Clk_Count <= 0;
                    
                        -- Check if there are bits left to send
                        if r_Bit_Index < 7 then
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_FSM   <= s_TX_Data_Bits;
                        else -- No bits left to send
                            r_Bit_Index <= 0;
                            r_FSM   <= s_TX_Stop_Bit;
                        end if;
                    end if;
          
                -- Send Stop bit.  Stop bit = 1
                when s_TX_Stop_Bit =>
                    o_TX_Serial <= '1';
                
                    -- Wait CLKS_PER_BIT - 1 clock cycles for Stop bit to finish
                    if r_Clk_Count < c_CLKS_PER_BIT - 1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_FSM   <= s_TX_Stop_Bit;
                    else
                        -- r_TX_Done   <= '1';
                        r_Clk_Count <= 0;
                        r_FSM   <= s_Cleanup;
                    end if;
          
                -- Stay here 1 clock
                when s_Cleanup =>
                    r_TX_Done   <= '1';
                    r_FSM   <= s_Idle;
                
                when others =>
                    r_FSM <= s_Idle;
          
            end case;
        end if;   
    end process;
    
    o_TX_Done <= r_TX_Done;
    
end Behavioral;
