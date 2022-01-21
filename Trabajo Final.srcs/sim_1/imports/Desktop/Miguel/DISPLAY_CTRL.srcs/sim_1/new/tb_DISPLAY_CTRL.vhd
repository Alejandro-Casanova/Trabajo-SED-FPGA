library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_display_ctrl is
end tb_display_ctrl;

architecture tb of tb_display_ctrl is

    component display_ctrl is
        generic(
            clk_freq : positive := 100000000; -- Hz
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
    end component display_ctrl;

    signal CLK       : std_logic;
    signal RST_N     : std_logic;
    signal value     : std_logic_vector(7 downto 0);
    signal digsel_n  : std_logic_vector(2 downto 0);
    signal segment_n : std_logic_vector (6 downto 0);

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';

begin

    uut : display_ctrl
    generic map ( refresh_freq => 90 )
    port map (CLK       => CLK,
              RST_N     => RST_N,
              value     => value,
              digsel_n  => digsel_n,
              segment_n => segment_n);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2;
    CLK <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        RST_N <= '0';
        value <= std_logic_vector(to_unsigned(45, 8));
        wait for 10 ms;
        
        RST_N <= '1';
        wait for 20 ms;
        
        value <= std_logic_vector(to_unsigned(123, 8));
        wait for 20 ms;

        assert false report "Fin Test" severity failure;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.
