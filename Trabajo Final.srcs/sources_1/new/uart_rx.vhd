----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2022 12:02:03
-- Design Name: 
-- Module Name: uart_rx - Behavioral
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

-- The receiver generates a pulse at the middle of the stop bit to indicate
-- that reception is over and parallel bus can be read

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (g_CLK_Freq : integer := 100000000;
             g_UART_Baud_Rate : integer := 115200
    );
    Port ( i_CLK            : in STD_LOGIC;
           i_RX_Serial      : in STD_LOGIC;
           o_RX_Done        : out STD_LOGIC; -- Emits a pulse (during one clock cycle) 
                                             -- when reception is over and parallel bus can be read
           o_RX_Parallel    : out STD_LOGIC_VECTOR (7 downto 0);
           o_RX_Error       : out STD_LOGIC
           );
end uart_rx;

architecture Behavioral of uart_rx is
    
    constant c_CLKS_PER_BIT : integer := g_CLK_Freq / g_UART_Baud_Rate; 
    
    component synchrnzr is
        Port ( clk : in STD_LOGIC;
               async_in : in STD_LOGIC;
               sync_out : out STD_LOGIC);
    end component synchrnzr;
 
    type t_FSM is (s_Idle, s_RX_Start_Bit,  -- Finite State Machine
                   s_RX_Data_Bits, s_RX_Stop_Bit, 
                   s_Cleanup);
    signal r_FSM : t_FSM := s_Idle; 
 
    signal r_RX_Serial_Data   : std_logic := '0'; -- Serial data already synchronized
   
    signal r_Clk_Count : integer range 0 to c_CLKS_PER_BIT - 1 := 0;
    signal r_Bit_Index : integer range 0 to 7 := 0; -- Keeps count of which bit is being read
    signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0'); -- Saves the whole byte being read
    signal r_RX_Done   : std_logic := '0';
    signal r_RX_Error  : std_logic := '0';
    
begin
    -- The synchronizer samples the input serial data allowing its use 
    -- in the clock domain (reduces problems caused by metastability)
    sample_serial : synchrnzr
        port map(
            clk      => i_CLK,
            async_in => i_RX_Serial,
            sync_out => r_RX_Serial_Data
        );
    
    -- This process manages state transitions, data reading and outputs
    p_UART_RX : process (i_Clk)
    begin
        if rising_edge(i_Clk) then     
            case r_FSM is
 
                when s_Idle => 
                    r_RX_Done   <= '0';
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 0;
                    
                    if r_RX_Serial_Data = '0' then   -- Start bit detected
                        r_FSM <= s_RX_Start_Bit;
                    else
                        r_FSM <= s_Idle;
                    end if;
                    
                when s_RX_Start_Bit => -- Waits until half of start bit
                    if r_Clk_Count < (c_CLKS_PER_BIT -1) / 2 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_FSM     <= s_RX_Start_Bit;
                    else  
                        if r_RX_Serial_Data = '0' then -- Checks serial data is still 0
                            r_Clk_Count <= 0;  -- reset counter since we found the middle
                            r_FSM   <= s_RX_Data_Bits;
                        else
                            r_FSM      <= s_Idle; -- Restart communication, start condition failed
                            r_RX_Error <= '1'; -- Signal ERROR
                        end if;    
                    end if;         
          
                -- Reading Data Bits
                when s_RX_Data_Bits =>
                    if r_Clk_Count < c_CLKS_PER_BIT - 1 then -- Waits until middle of data bit
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_FSM   <= s_RX_Data_Bits;
                    else                                     -- Finds middle of next data bit
                        r_Clk_Count            <= 0;         -- Resets Counter
                        r_RX_Byte(r_Bit_Index) <= r_RX_Serial_Data; -- Saves value read
                    
                        -- Checks bit progress
                        if r_Bit_Index < 7 then                 -- Are there more bits left? Keep on reading
                            r_Bit_Index <= r_Bit_Index + 1;
                            r_FSM   <= s_RX_Data_Bits;
                        else                                    -- Last bit read
                            r_Bit_Index <= 0;
                            r_FSM   <= s_RX_Stop_Bit;
                        end if;
                    end if;
                    
                -- Receive Stop bit.  Stop bit = 1
                when s_RX_Stop_Bit =>
                    -- Wait c_CLKS_PER_BIT - 1 clock cycles for Stop bit 
                    if r_Clk_Count < c_CLKS_PER_BIT - 1 then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_FSM       <= s_RX_Stop_Bit;
                    else -- Stop Bit Arrives
                        if r_RX_Serial_Data = '1' then -- Checks serial data is 1
                            r_Clk_Count <= 0;
                            r_FSM   <= s_Cleanup;
                        else
                            r_FSM      <= s_Idle; -- Restart communication, stop condition failed
                            r_RX_Error <= '1';    -- Signal ERROR
                        end if;
                    end if;
     
                -- Stay here 1 clock
                when s_Cleanup =>
                    r_FSM   <= s_Idle;
                    r_RX_Done   <= '1'; -- Signal operation finished with a pulse
                    r_RX_Error  <= '0';
                
                when others =>
                    r_FSM <= s_Idle;
          
            end case;
        end if;
    end process p_UART_RX;
    
    o_RX_Done       <= r_RX_Done;
    o_RX_Parallel   <= r_RX_Byte;
    o_RX_Error      <= r_RX_Error;
    
end Behavioral;
