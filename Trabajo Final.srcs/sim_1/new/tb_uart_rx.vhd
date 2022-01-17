----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2022 14:12:53
-- Design Name: 
-- Module Name: tb_uart_tx - Behavioral
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

entity tb_uart_rx is
--  Port ( );
end tb_uart_rx;

architecture Behavioral of tb_uart_rx is
    component uart_rx is
        generic (g_CLK_Freq : integer := 100000000;
                 g_UART_Baud_Rate : integer := 115000
        );
        Port ( i_CLK            : in STD_LOGIC;
               i_RX_Serial      : in STD_LOGIC;
               o_RX_Done        : out STD_LOGIC; -- Emits a pulse (during one clock cycle) when reception is over and parallel bus can be read
               o_RX_Parallel    : out STD_LOGIC_VECTOR (7 downto 0)
               );
    end component uart_rx;
    
    -- Test Bench uses a 10 MHz Clock
    -- Want to interface to 115200 baud UART
    constant c_CLK_FREQ : integer := 100000000;
    constant c_UART_BAUD_RATE : integer := 115200;
    
    constant c_BIT_PERIOD : time := 8680 ns; -- (1 / c_UART_BAUD_RATE)
    
    signal r_CLOCK          : std_logic := '0';
    signal w_RX_DONE        : std_logic;
    signal w_RX_PARALLEL    : std_logic_vector(7 downto 0);
    signal r_RX_SERIAL      : std_logic := '1';
    
    type t_test_vector is array(9 downto 0) of std_logic_vector(7 downto 0);
    constant c_test_vector : t_test_vector := (X"00", X"19", X"32", X"4B", X"64", 
                                               X"96", X"AF", X"C8", X"E1", X"FA"); 
                                               
    
    -- Writes byte on serial line to test receiver
    procedure UART_WRITE_BYTE (
        i_data_in       : in  std_logic_vector(7 downto 0);
        signal o_serial : out std_logic) is
    begin
        -- Send Start Bit
        o_serial <= '0';
        wait for c_BIT_PERIOD;
        
        -- Send Data Byte
        for ii in 0 to 7 loop
            o_serial <= i_data_in(ii);
            wait for c_BIT_PERIOD;
        end loop;  -- ii
        
        -- Send Stop Bit
        o_serial <= '1';
        wait for c_BIT_PERIOD;
    end UART_WRITE_BYTE;
  
begin

    -- Instantiate UART Receiver
    uut : uart_rx
        generic map(
            g_CLK_Freq => c_CLK_FREQ,
            g_UART_Baud_Rate => c_UART_BAUD_RATE
        )
        port map (
            i_CLK           => r_CLOCK,
            i_RX_SERIAL     => r_RX_SERIAL,
            o_RX_DONE       => w_RX_DONE,
            o_RX_PARALLEL   => w_RX_PARALLEL
        );

    r_CLOCK <= not r_CLOCK after 5 ns; -- Clk signal for 100 MHz
    
    stimuli : process 
    begin   
        for i in 0 to c_test_vector'length - 1 loop
            -- Send a command to the UART
            wait until rising_edge(r_CLOCK);
            UART_WRITE_BYTE(c_test_vector(i), r_RX_SERIAL);
        end loop;
        
    end process;
    
    test : process
    begin
        for i in 0 to c_test_vector'length - 1 loop
       
            wait until w_RX_DONE = '1';
        
            -- Check that the correct command was received
            if w_RX_PARALLEL = c_test_vector(i) then
                report "Test Passed - Correct Byte Received" severity note;
            else
                report "Test Failed - Incorrect Byte Received" severity note;
            end if;
            
        end loop;
        
        assert false report "Tests Complete" severity failure;
    
    end process;

end Behavioral;
