----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.01.2022 11:53:24
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port ( RESET        : in std_logic;
           CLK          : in std_logic;    
           PUSHBUTTON_L : in std_logic;
           PUSHBUTTON_R : in std_logic;
           PUSHBUTTON_U : in std_logic;
           PUSHBUTTON_D : in std_logic;   
           SERIAL_IN    : in std_logic;
           PULSE_OUT_R  : out std_logic;
           PULSE_OUT_L  : out std_logic;
           STATE_LED    : out std_logic_vector(3 downto 0);
           DIGSEL_N     : out std_logic_vector(2 downto 0);
           SEGMENT_N    : out std_logic_vector(6 downto 0)
    );
end top;

architecture Behavioral of top is
    
    signal s_Reset_n            : std_logic;
    signal s_Clk                : std_logic;
    signal s_button_debounced   : std_logic_vector(3 downto 0);
    signal s_Parallel_Data_UART : std_logic_vector (7 downto 0);
    signal s_Parallel_Data_Reg  : std_logic_vector (7 downto 0);
    signal s_RX_Done            : std_logic;
    
    component button_processing is
        Port ( UP    : in STD_LOGIC;
               DOWN  : in STD_LOGIC;
               LEFT  : in STD_LOGIC;
               RIGHT : in STD_LOGIC;
               CLK   : in std_logic;
               BCODE : out STD_LOGIC_VECTOR (3 downto 0));
    end component button_processing;
    
    component fsm is 
        port ( 
            RESET_N    : in std_logic; 
            CLK        : in std_logic; 
            PUSHBUTTON : in std_logic_vector(3 downto 0); -- Left, Down, Right, Up
            TURN_R     : out std_logic ; 
            TURN_L     : out std_logic;
            LED        : out std_logic_vector(3 downto 0) -- Left, Down, Right, Up (Indica el Estado)
        );
    end component fsm;
    
    component uart_rx is
        generic (g_CLK_Freq       : integer := 100000000;
                 g_UART_Baud_Rate : integer := 115200
        );
        Port ( i_CLK            : in STD_LOGIC;
               i_RX_Serial      : in STD_LOGIC;
               o_RX_Done        : out STD_LOGIC; -- Emits a pulse (during one clock cycle) 
                                                 -- when reception is over and parallel bus can be read
               o_RX_Parallel    : out STD_LOGIC_VECTOR (7 downto 0)
               );
    end component uart_rx; 
    
    component count_reg is
        Generic( g_word_length : positive := 8);
        Port ( i_CLK     : in STD_LOGIC;
               i_Reset_N : in std_logic;
               i_Data    : in STD_LOGIC_VECTOR ((g_word_length - 1) downto 0);
               i_Capture : in STD_LOGIC; -- Pulso
               o_Data    : out STD_LOGIC_VECTOR ((g_word_length - 1) downto 0));
    end component count_reg;  
    
    component display_ctrl is
        generic(
            clk_freq     : positive := 100000000;
            refresh_freq : positive := 30; -- Hz
            n_bits       : positive := 8; -- Number of bits of input value bus
            n_digits     : positive := 3 -- Number of digits represented
        );
        PORT ( 
            CLK       : in std_logic;
            RST_N     : in std_logic;
            value     : in std_logic_vector(n_bits - 1 downto 0);
            digsel_n  : OUT std_logic_vector(n_digits - 1 downto 0);
            segment_n : OUT std_logic_vector(6 DOWNTO 0)
        );
    end component display_ctrl;

begin
    
    s_Clk <= CLK;
    s_Reset_n <= not RESET;
    
    u1_btnprcss : button_processing
        port map(  UP    => PUSHBUTTON_U,
                   DOWN  => PUSHBUTTON_D,
                   LEFT  => PUSHBUTTON_L,
                   RIGHT => PUSHBUTTON_R,
                   CLK   => s_Clk,
                   BCODE => s_button_debounced
        );
    
    u2_fsm : fsm
        port map( RESET_N    => s_reset_n, 
                  CLK        => s_Clk,
                  PUSHBUTTON => s_button_debounced,
                  TURN_R     => PULSE_OUT_R,
                  TURN_L     => PULSE_OUT_L,
                  LED        => STATE_LED
        );
        
    u3_uart : uart_rx
        port map( i_CLK         => s_Clk,
                  i_RX_Serial   => SERIAL_IN,
                  o_RX_Done     => s_RX_Done,
                  o_RX_Parallel => s_Parallel_Data_UART
        );
        
    u4_reg : count_reg
        port map( i_CLK     => s_Clk,
                  i_Reset_N => s_Reset_n,
                  i_Data    => s_Parallel_Data_UART,
                  i_Capture => s_RX_Done,
                  o_Data    => s_Parallel_Data_Reg
        );             
    
    u5_dspl_ctrl : display_ctrl
        port map( CLK       => s_Clk,
                  RST_N     => s_reset_n,
                  value     => s_Parallel_Data_Reg,
                  digsel_n  => DIGSEL_N,
                  segment_n => SEGMENT_N
        );
        
end Behavioral;
