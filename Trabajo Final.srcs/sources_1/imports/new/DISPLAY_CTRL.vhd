library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity display_ctrl is
    generic(
        clk_freq : positive := 100000000;
        refresh_freq : positive := 30; -- Hz
        n_bits : positive := 8; -- Number of bits of input value bus
        n_digits : positive := 3 -- Number of digits represented
    );
    PORT ( 
        CLK : in std_logic;
        RST_N : in std_logic;
        value : in std_logic_vector(n_bits - 1 downto 0);
        digsel_n : OUT std_logic_vector(n_digits - 1 downto 0);
        segment_n : OUT std_logic_vector(6 DOWNTO 0)
    );
end display_ctrl;

architecture Behavioral of display_ctrl is

    component decoder is
    port (
        code  : IN std_logic_vector(3 DOWNTO 0);
        led_n : OUT std_logic_vector(6 DOWNTO 0)
    );
    end component decoder;

    subtype digit_type is integer range 0 to 9;
    type digits_type is array(n_digits - 1 downto 0) of digit_type;
    
    signal digit : digit_type;  --holds the number currently being shown
    signal digits : digits_type;   --holds the complete decimal number
    
    signal int_value : natural range 0 to (10**n_digits - 1) := 0; -- Holds the input value in integer form
    
    constant max_clk_count : natural := clk_freq / refresh_freq / n_digits; -- Ticks for each digit to stay on
    --signal clk_count : positive := 0; -- Counter for clk ticks
    signal digit_index : natural range 0 to (n_digits - 1) := 0;

begin
    -- Stores the value in integer form
    int_value <= to_integer(unsigned(value)) when RST_N = '1' else 
                 0;
      
    -- Splits int_value into units, tens, hundreds...           
    digit_partition : for i in (n_digits - 1) downto 0 generate
        digits(i) <= int_value mod (10**(i + 1)) / (10**i) when RST_N = '1' else
        0; 
    end generate;   
    
    -- Selects current digit
    digit <= digits(digit_index) when RST_N = '1' else 
             0;
    -- Selects current digit selection line
    select_digit : for i in 0 to n_digits - 1 generate
        digsel_n(i) <= '0' when digit_index = i and RST_N = '1' else '1';
    end generate;
    -- No sintetizable:
    --digsel_n <= (digit_index => '0', others => '1') when RST_N = '1' else 
    --          (others => '1');
    
    digit_select : process(CLK , RST_N)
        variable clk_count : natural := 0;
    begin
        if RST_N = '0' then
            clk_count := 0;
        elsif rising_edge(CLK) then
            clk_count := (clk_count + 1) mod max_clk_count;
            if clk_count = 0 then
                digit_index <= (digit_index + 1) mod 3;
            end if;
        end if;
    end process;

    inst_decoder : decoder
        port map (
            code  => std_logic_vector(to_unsigned(digit, 4)),
            led_n => segment_n
        );
    
end Behavioral;
