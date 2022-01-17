library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
end tb_top;

architecture tb of tb_top is

    component top
        port (RESET        : in std_logic;
              CLK          : in std_logic;
              PUSHBUTTON_L : in std_logic;
              PUSHBUTTON_R : in std_logic;
              PUSHBUTTON_U : in std_logic;
              PUSHBUTTON_D : in std_logic;
              SERIAL_IN    : in std_logic;
              PULSE_OUT_R  : out std_logic;
              PULSE_OUT_L  : out std_logic;
              STATE_LED    : out std_logic_vector (3 downto 0);
              DIGSEL_N     : out std_logic_vector (2 downto 0);
              SEGMENT_N    : out std_logic_vector (6 downto 0));
    end component;
    
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

    signal RESET        : std_logic;
    signal CLK          : std_logic;
    signal PUSHBUTTON_L : std_logic;
    signal PUSHBUTTON_R : std_logic;
    signal PUSHBUTTON_U : std_logic;
    signal PUSHBUTTON_D : std_logic;
    signal SERIAL_IN    : std_logic := '0';
    signal PULSE_OUT_R  : std_logic;
    signal PULSE_OUT_L  : std_logic;
    signal STATE_LED    : std_logic_vector (3 downto 0);
    signal DIGSEL_N     : std_logic_vector (2 downto 0);
    signal SEGMENT_N    : std_logic_vector (6 downto 0);
    
    signal TX_START     : std_logic := '0';
    signal TX_PARALLEL  : std_logic_vector(7 downto 0) := (others => '0');
    signal TX_DONE      : std_logic := '0';

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0';

begin
    
    uartTX : uart_tx
        port map(  i_Clk           => CLK,
                   i_TX_Start      => TX_START,
                   i_TX_Parallel   => TX_PARALLEL,
                   o_TX_Serial     => SERIAL_IN,
                   o_TX_Done       => TX_DONE
        );
    
    uut : top
    port map (RESET        => RESET,
              CLK          => CLK,
              PUSHBUTTON_L => PUSHBUTTON_L,
              PUSHBUTTON_R => PUSHBUTTON_R,
              PUSHBUTTON_U => PUSHBUTTON_U,
              PUSHBUTTON_D => PUSHBUTTON_D,
              SERIAL_IN    => SERIAL_IN,
              PULSE_OUT_R  => PULSE_OUT_R,
              PULSE_OUT_L  => PULSE_OUT_L,
              STATE_LED    => STATE_LED,
              DIGSEL_N     => DIGSEL_N,
              SEGMENT_N    => SEGMENT_N);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2;
    CLK <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RESET <= '0';
        PUSHBUTTON_L <= '0';
        PUSHBUTTON_R <= '0';
        PUSHBUTTON_U <= '0';
        PUSHBUTTON_D <= '0';
        
        wait for TbPeriod * 1000;
        -- Check state transitions
        -- Empieza hacia arriba
        PUSHBUTTON_R <= '1';
        wait for TbPeriod * 500;
        PUSHBUTTON_R <= '0';
        wait for TbPeriod * 500;
        PUSHBUTTON_D <= '1';
        wait for TbPeriod * 500;
        PUSHBUTTON_D <= '0';
        wait for TbPeriod * 500;
        PUSHBUTTON_L <= '1';
        wait for TbPeriod * 500;
        PUSHBUTTON_L <= '0';
        wait for TbPeriod * 500;
        PUSHBUTTON_U <= '1';
        wait for TbPeriod * 500;
        PUSHBUTTON_U <= '0';
        wait for TbPeriod * 1000;
        
        -- Send points
        TX_PARALLEL <= std_logic_vector(to_unsigned(123, 8));
        TX_START <= '1';
        wait for TbPeriod;
        TX_START <= '0';
        wait until rising_edge(TX_DONE);
        
        -- Check display
        wait for 100 ms; 

        -- Reset generation
        -- EDIT: Check that RESET is really your reset signal
        RESET <= '1';
        wait for TbPeriod * 1000;
        RESET <= '0';
        wait for TbPeriod * 100;

        assert false report "Test Complete" severity failure;
    end process;

end tb;
