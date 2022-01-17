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

entity tb_uart_tx is
--  Port ( );
end tb_uart_tx;

architecture Behavioral of tb_uart_tx is

    component uart_tx is
        generic (g_CLK_Freq       : integer := 100000000;
                 g_UART_Baud_Rate : integer := 115200
        );
        Port ( i_Clk            : in STD_LOGIC;
               i_TX_Start       : in STD_LOGIC; -- Receives a pulse to start transmition
               i_TX_Parallel    : in STD_LOGIC_VECTOR (7 downto 0);
               o_TX_Serial      : out STD_LOGIC;
               o_TX_Done        : out STD_LOGIC); -- Sends pulse to signal transmition end
    end component uart_tx;
    
    component uart_rx is
        generic (g_CLK_Freq : integer := 100000000;
                 g_UART_Baud_Rate : integer := 115200
        );
        Port ( i_CLK            : in STD_LOGIC;
               i_RX_Serial      : in STD_LOGIC;
               o_RX_Done        : out STD_LOGIC; -- Emits a pulse (during one clock cycle) when reception is over and parallel bus can be read
               o_RX_Parallel    : out STD_LOGIC_VECTOR (7 downto 0)
               );
    end component uart_rx;
    
    constant c_CLK_FREQ : integer := 100000000;
    constant c_UART_BAUD_RATE : integer := 115200;
    constant c_BIT_PERIOD : time := 8680 ns; -- (1 / c_UART_BAUD_RATE)
    constant c_CLK_PERIOD : time := 10 ns;
    
    signal r_CLOCK          : std_logic := '0';
    signal w_RX_DONE        : std_logic;
    signal w_RX_PARALLEL    : std_logic_vector(7 downto 0);
    signal r_RX_SERIAL      : std_logic := '1';
    signal r_TX_START       : std_logic;
    signal r_TX_PARALLEL    : std_logic_vector(7 downto 0);
    signal w_TX_SERIAL      : std_logic;
    signal w_TX_DONE        : std_logic;
    
    type t_test_vector is array(9 downto 0) of std_logic_vector(7 downto 0);
    constant c_test_vector : t_test_vector := (X"00", X"19", X"32", X"4B", X"64", 
                                               X"96", X"AF", X"C8", X"E1", X"FA");
                                               
begin
    
    -- Instantiate UART Transceiver
    uut : uart_tx
        generic map(
            g_CLK_Freq => c_CLK_FREQ,
            g_UART_Baud_Rate => c_UART_BAUD_RATE
        )
        port map (
            i_CLK           => r_CLOCK,
            i_TX_Start      => r_TX_START,
            i_TX_Parallel   => r_TX_PARALLEL,
            o_TX_Serial     => w_TX_SERIAL,
            o_TX_Done       => w_TX_DONE
        );
        
    -- Instantiate UART Receiver
    receiver : uart_rx
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
    
    r_CLOCK <= not r_CLOCK after 5 ns; -- Clk signal for 10 MHz
    r_RX_SERIAL <= w_TX_SERIAL; -- Connect Serial Lines
    
    stimuli : process 
    begin   
        for i in 0 to c_test_vector'length - 1 loop
            -- Send a command to the UART
            r_TX_PARALLEL <= c_test_vector(i);
            
            r_TX_START <= '1'; -- Send start pulse
            wait for c_CLK_PERIOD;
            r_TX_START <= '0';
            
            wait until rising_edge(w_TX_DONE);
           
        end loop;
        
    end process;
    
    test : process
    begin
        for i in 0 to c_test_vector'length - 1 loop
       
            wait until rising_edge(w_RX_DONE);
        
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
