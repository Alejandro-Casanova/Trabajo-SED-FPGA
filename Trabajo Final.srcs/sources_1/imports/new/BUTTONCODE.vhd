----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.01.2022 10:43:08
-- Design Name: 
-- Module Name: BUTTONCODE - Behavioral
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

entity button_processing is
    Port ( UP : in STD_LOGIC;
           DOWN : in STD_LOGIC;
           LEFT : in STD_LOGIC;
           RIGHT : in STD_LOGIC;
           CLK : in std_logic;
           BCODE : out STD_LOGIC_VECTOR (3 downto 0));
end button_processing;

architecture Behavioral of button_processing is

    component debouncer is
        Generic( clockFreq   : integer range 0 to integer'high := 100000000;
                 deadTime_ns : integer range 0 to integer'high := 1000); -- Nanosegundos
        Port(    pulse_in    : in STD_LOGIC;
                 CLK         : in STD_LOGIC;
                 pulse_out   : out STD_LOGIC);
    end component debouncer;
    
    component edge_dtctr is
        Port ( clk     : in STD_LOGIC;
               sync_in : in STD_LOGIC;
               edge    : out STD_LOGIC);
    end component edge_dtctr;
    
    component synchrnzr is
        Port ( clk      : in STD_LOGIC;
               async_in : in STD_LOGIC;
               sync_out : out STD_LOGIC);
    end component synchrnzr;

    signal async_in      : std_logic_vector(3 downto 0) := (others => '0');
    signal sync_out      : std_logic_vector(3 downto 0) := (others => '0');
    signal edge_out      : std_logic_vector(3 downto 0) := (others => '0');
    signal debounced_out : std_logic_vector(3 downto 0) := (others => '0');
begin

    async_in <= (LEFT & DOWN & RIGHT & UP);
    BCODE <= debounced_out;
    
    components : for i in BCODE'range generate
        sync_comp : synchrnzr 
            port map( clk => CLK,
                      async_in => async_in(i),
                      sync_out => sync_out(i) 
            );
        edge_comp : edge_dtctr 
            port map( clk => CLK,
                      sync_in => sync_out(i),
                      edge => edge_out(i)
            );
        deb_comp : debouncer
            generic map( clockFreq => 100000000,
                         deadTime_ns => 1000000 )
            port map( pulse_in => edge_out(i),
                      clk => CLK,
                      pulse_out => debounced_out(i)
            );

    end generate;

end Behavioral;
