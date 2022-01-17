library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tb_button_processing is
end;

architecture tb of tb_button_processing is

    component button_processing is
        Port ( UP : in STD_LOGIC;
               DOWN : in STD_LOGIC;
               LEFT : in STD_LOGIC;
               RIGHT : in STD_LOGIC;
               CLK : in std_logic;
               BCODE : out STD_LOGIC_VECTOR (3 downto 0));
    end component button_processing;

    signal UP: STD_LOGIC := '0';
    signal DOWN: STD_LOGIC := '0';
    signal LEFT: STD_LOGIC := '0';
    signal RIGHT: STD_LOGIC := '0';
    signal CLK: std_logic := '1';
    signal BCODE: STD_LOGIC_VECTOR (3 downto 0);

    constant clock_period: time := 10 ns;
 
begin
    
    CLK <= not CLK after clock_period / 2;

    uut: button_processing port map ( UP    => UP,
                                      DOWN  => DOWN,
                                      LEFT  => LEFT,
                                      RIGHT => RIGHT,
                                      CLK   => CLK,
                                      BCODE => BCODE );

    stimulus: process
    begin
        
        wait for clock_period * 4;
        UP<='1';
        RIGHT<='0';
        DOWN <='0';
        LEFT<='0';
        --wait for clock_period /4;
        --assert BCODE = "0001" report "FAIL" severity failure;
        wait for clock_period * 3 * 9 / 7;
        UP<='0';
        wait for clock_period * 2 * 9 / 7;
        UP<='1';
        wait for clock_period * 10 * 9 / 7;
        UP<='0';
        wait for clock_period * 3 * 9 / 7;
        UP<='1';
        wait for clock_period * 2 * 9 / 7;
        UP<='0';
        --wait for clock_period / 4;
        --assert BCODE = "0000" report "FAIL" severity failure;
    
        wait for clock_period * 5 * 9 / 7;
        UP<='0';
        RIGHT<='1';
        DOWN <='0';
        LEFT<='0';
        --wait for clock_period / 4;
        --assert BCODE = "0010"report "FAIL" severity failure;
        wait for clock_period * 3 * 9 / 7;
        RIGHT<='0';
        wait for clock_period * 2 * 9 / 7;
        RIGHT<='1';
        wait for clock_period * 10 * 9 / 7;
        RIGHT<='0';
        wait for clock_period * 3 * 9 / 7;
        RIGHT<='1';
        wait for clock_period * 2 * 9 / 7;
        RIGHT<='0';
        --wait for clock_period / 4;
        --assert BCODE = "0000" report "FAIL" severity failure;
    
        wait for clock_period * 5 * 9 / 7;
        UP<='0';
        RIGHT<='0';
        DOWN <='1';
        LEFT<='0';
        --wait for clock_period / 4;
        --assert BCODE = "0100" report "FAIL" severity failure;
        wait for clock_period * 3 * 9 / 7;
        DOWN<='0';
        wait for clock_period * 2 * 9 / 7;
        DOWN<='1';
        wait for clock_period * 10 * 9 / 7;
        DOWN<='0';
        wait for clock_period * 3 * 9 / 7;
        DOWN<='1';
        wait for clock_period * 2 * 9 / 7;
        DOWN<='0';
        --wait for clock_period / 4;
        --assert BCODE = "0000" report "FAIL" severity failure;
    
        wait for clock_period * 5 * 9 / 7;
        UP<='0';
        RIGHT<='0';
        DOWN <='0';
        LEFT<='1';
        --wait for clock_period / 4;
        --assert BCODE = "1000" report "FAIL" severity failure;
        wait for clock_period * 3 * 9 / 7;
        LEFT<='0';
        wait for clock_period * 2 * 9 / 7;
        LEFT<='1';
        wait for clock_period * 10 * 9 / 7;
        LEFT<='0';
        wait for clock_period * 3 * 9 / 7;
        LEFT<='1';
        wait for clock_period * 2 * 9 / 7;
        LEFT<='0';
        --wait for clock_period / 4;
        --assert BCODE = "0000" report "FAIL" severity failure;
        
        assert false report "Test Complete" severity failure;
    end process;

end tb;
